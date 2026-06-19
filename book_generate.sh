#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOKS_DIR="${1:-"$SCRIPT_DIR/books"}"
OUTPUT_DIR="${2:-"$SCRIPT_DIR/_build/books"}"
BUILD_MODE="${3:-directory}"
GENERATED_ROOT="$SCRIPT_DIR/.jupyter-book-generated"
AGGREGATE_SOURCE_DIR="$GENERATED_ROOT/books-directory"
LOCAL_MYST_TEMPLATE_DIR="${MYST_SITE_TEMPLATE_DIR:-"$SCRIPT_DIR/.myst-templates/book-theme"}"
ANNBOOK_BOOK_TITLE="${ANNBOOK_BOOK_TITLE:-Python 教程 Notebook}"
ANNBOOK_BOOK_AUTHOR="${ANNBOOK_BOOK_AUTHOR:-SUIBE Python Book}"
BASE_URL="${BASE_URL:-}"

usage() {
  cat <<'EOF'
Usage: ./book_generate.sh [BOOKS_DIR] [OUTPUT_DIR] [MODE]

MODE:
  directory  Build one Jupyter Book that contains all notebooks under BOOKS_DIR.
  source     Generate the aggregate Jupyter Book source only; do not build HTML.
  books      Build each direct child directory under BOOKS_DIR as a separate book.

Defaults:
  BOOKS_DIR  ./books
  OUTPUT_DIR ./_build/books
  MODE       directory

Environment:
  ANNBOOK_BOOK_TITLE   Book title for aggregate directory/source builds.
  ANNBOOK_BOOK_AUTHOR  Author name written into generated MyST config.
  BASE_URL             GitHub Pages subpath, for example /python_book.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if command -v jupyter-book >/dev/null 2>&1; then
  JB_CMD=(jupyter-book)
elif python3 -c 'import jupyter_book' >/dev/null 2>&1; then
  JB_CMD=(python3 -m jupyter_book)
else
  echo "Error: jupyter-book is not installed." >&2
  echo "Install it with: python3 -m pip install -U jupyter-book" >&2
  exit 1
fi

if [[ ! -d "$BOOKS_DIR" ]]; then
  echo "Error: books directory not found: $BOOKS_DIR" >&2
  exit 1
fi

site_template_for() {
  local book_dir="$1"

  if [[ -f "$LOCAL_MYST_TEMPLATE_DIR/template.yml" ]]; then
    python3 - "$LOCAL_MYST_TEMPLATE_DIR" "$book_dir" <<'PY'
from pathlib import Path
import os
import sys

template_dir = Path(sys.argv[1]).resolve()
book_dir = Path(sys.argv[2]).resolve()
print(Path(os.path.relpath(template_dir, book_dir)).as_posix())
PY
  else
    printf '%s\n' "book-theme"
  fi
}

generate_aggregate_source() {
  local source_dir="$AGGREGATE_SOURCE_DIR"
  local site_template

  rm -rf "$source_dir"
  mkdir -p "$source_dir"

  site_template="$(site_template_for "$source_dir")"
  if [[ "$site_template" != "book-theme" ]]; then
    echo "Using local MyST template: $LOCAL_MYST_TEMPLATE_DIR" >&2
  fi

  python3 - "$source_dir" "$BOOKS_DIR" "$site_template" "$ANNBOOK_BOOK_TITLE" "$ANNBOOK_BOOK_AUTHOR" "$BASE_URL" <<'PY'
from collections import defaultdict
from pathlib import Path
import re
import shutil
import sys

source_dir = Path(sys.argv[1])
input_books_dir = Path(sys.argv[2])
site_template = sys.argv[3]
book_title = sys.argv[4]
book_author = sys.argv[5]
base_url = sys.argv[6]
generated_books_dir = source_dir / "books"

def safe_component(value: str, fallback: str) -> str:
    value = re.sub(r"[^A-Za-z0-9._-]+", "-", value).strip("-._")
    return value or fallback

def unique_path(path: Path, used: set[Path]) -> Path:
    if path not in used:
        used.add(path)
        return path

    stem = path.stem
    suffix = path.suffix
    parent = path.parent
    index = 2
    while True:
        candidate = parent / f"{stem}-{index}{suffix}"
        if candidate not in used:
            used.add(candidate)
            return candidate
        index += 1

pages = sorted(
    p for p in input_books_dir.rglob("*")
    if p.suffix.lower() in {".ipynb", ".md", ".rst"}
    and not any(part.startswith((".", "_")) for part in p.relative_to(input_books_dir).parts)
)

if not pages:
    raise SystemExit(f"No notebooks or markdown pages found under {input_books_dir}")

groups = defaultdict(list)
used_paths = set()
for page in pages:
    rel_parent = page.parent.relative_to(input_books_dir)
    group_name = rel_parent.as_posix() if rel_parent.parts else "books"
    safe_parts = [
        safe_component(part, f"group-{index + 1}")
        for index, part in enumerate(rel_parent.parts)
    ]
    safe_name = safe_component(page.stem, "page") + page.suffix
    generated_page = unique_path(generated_books_dir.joinpath(*safe_parts, safe_name), used_paths)
    generated_page.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(page, generated_page)
    groups[group_name].append((page, generated_page))

index_lines = [
    f"# {book_title} 目录",
    "",
    "本页自动汇总 `books/` 目录下的课程 Notebook。左侧目录保留原始文件夹层次，便于同时浏览多个 annotated notebook。",
    "",
]

for group_name in sorted(groups):
    index_lines.extend([f"## {group_name}", ""])
    for original_page, generated_page in groups[group_name]:
        rel = generated_page.relative_to(source_dir).as_posix()
        index_lines.append(f"- [{original_page.stem}]({rel})")
    index_lines.append("")

(source_dir / "index.md").write_text("\n".join(index_lines), encoding="utf-8")

def rel(path: Path) -> str:
    return path.relative_to(source_dir).as_posix()

myst = [
    "version: 1",
    "project:",
    f"  title: {book_title}",
    "  authors:",
    f"    - name: {book_author}",
    "  toc:",
    "    - file: index.md",
]

for group_name in sorted(groups):
    myst.append(f"    - title: {group_name}")
    myst.append("      children:")
    for original_page, generated_page in groups[group_name]:
        myst.append(f"        - file: {rel(generated_page)}")

myst.extend([
    "site:",
    "  options:",
    "    folders: true",
])

if base_url:
    myst.append(f"    base_url: {base_url}")

myst.extend([
    f"  template: {site_template}",
    "",
])

(source_dir / "myst.yml").write_text("\n".join(myst), encoding="utf-8")
PY

  printf '%s\n' "$source_dir"
}

build_site() {
  local source_dir="$1"
  local output_dir="$2"

  (
    cd "$source_dir"
    "${JB_CMD[@]}" build --html --force
  )

  rm -rf "$output_dir"
  mkdir -p "$output_dir"
  cp -R "$source_dir/_build/html"/. "$output_dir"
}

generate_single_book_source() {
  local book_dir="$1"
  local book_name="$2"
  local source_dir="$GENERATED_ROOT/$book_name"
  local site_template

  rm -rf "$source_dir"
  mkdir -p "$GENERATED_ROOT"
  cp -R "$book_dir" "$source_dir"

  site_template="$(site_template_for "$source_dir")"

  python3 - "$source_dir" "$book_name" "$site_template" "$ANNBOOK_BOOK_AUTHOR" "$BASE_URL" <<'PY'
from pathlib import Path
import sys

book_dir = Path(sys.argv[1])
book_name = sys.argv[2]
site_template = sys.argv[3]
book_author = sys.argv[4]
base_url = sys.argv[5]

pages = sorted(
    p for p in book_dir.rglob("*")
    if p.suffix.lower() in {".ipynb", ".md", ".rst"}
    and not any(part.startswith(("_", ".")) for part in p.relative_to(book_dir).parts)
)

if not pages:
    raise SystemExit(f"No notebook or markdown pages found in {book_dir}")

myst = [
    "version: 1",
    "project:",
    f"  title: {book_name}",
    "  authors:",
    f"    - name: {book_author}",
    "  toc:",
]

for page in pages:
    myst.append(f"    - file: {page.relative_to(book_dir).as_posix()}")

myst.extend([
    "site:",
    "  options:",
    "    folders: true",
])

if base_url:
    myst.append(f"    base_url: {base_url}")

myst.extend([
    f"  template: {site_template}",
    "",
])

(book_dir / "myst.yml").write_text("\n".join(myst), encoding="utf-8")
PY

  printf '%s\n' "$source_dir"
}

case "$BUILD_MODE" in
  directory)
    source_dir="$(generate_aggregate_source)"
    echo "Building notebook directory ..."
    build_site "$source_dir" "$OUTPUT_DIR"
    echo "Done. HTML output is under: $OUTPUT_DIR"
    ;;
  source)
    source_dir="$(generate_aggregate_source)"
    echo "Done. Jupyter Book source is under: $source_dir"
    ;;
  books)
    shopt -s nullglob
    book_dirs=("$BOOKS_DIR"/*/)

    if (( ${#book_dirs[@]} == 0 )); then
      echo "Error: no book directories found under $BOOKS_DIR" >&2
      exit 1
    fi

    for book_dir in "${book_dirs[@]}"; do
      book_dir="${book_dir%/}"
      book_name="$(basename "$book_dir")"
      source_dir="$(generate_single_book_source "$book_dir" "$book_name")"

      echo "Building $book_name ..."
      build_site "$source_dir" "$OUTPUT_DIR/$book_name"
    done

    echo "Done. HTML output is under: ${2:-"$SCRIPT_DIR/_build/books"}"
    ;;
  *)
    echo "Error: unknown build mode: $BUILD_MODE" >&2
    usage >&2
    exit 1
    ;;
esac
