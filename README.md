# README

这是一个面向python学习者的 Notebook 课程仓库，采用 annotated 风格组织内容：

- 先讲直觉，再讲公式，最后落到代码。
- 每节尽量给出最小可运行示例。
- 强调可解释性，不只给结论，也解释为什么。

如果你是 Python 初学者，可以从第一课直接开始，边跑边看、边改边学。

当前仓库包含的主要内容：

- 教学型 Notebook：位于 books 目录，用于组织课程正文。

## 目录结构

```text
.
├── books/
│   └── 01_基础知识/
│       ├── 01_python示例.ipynb
│       ├── 02_python变量与基本数据类型.ipynb
│       └── 03_python控制结构-顺序与选择结构.ipynb
├── book_generate.sh
├── book_start.sh
└── README.md
```

各目录用途如下：

- books：课程正文与教学型 Notebook。
- _build：站点构建输出目录，不纳入版本控制。

## Python 初学者从这里开始

推荐先打开：

- books/01_基础知识/01_python示例.ipynb

这个 Notebook 的特点：

- 内容轻量，适合 20-30 分钟上手。
- 用中文解释输入 input 与输出 print 的核心概念。
- 提供可直接运行的输入/输出示例，打开就能看到效果。

建议学习顺序：

1. 先顺序运行每个代码单元。
2. 再修改变量值，观察输出变化。
3. 最后把“模拟输入”改成真实 input，体验交互式程序。

## 代码下载

```bash
git clone https://www.modelscope.cn/SuibeAI/python_book.git
cd python_book
```

## 环境要求

建议使用 Python 3.10 及以上版本。

安装构建依赖：

```bash
python3 -m pip install -U jupyter-book
```

如果你需要在 Notebook 中运行模型训练或数据处理，建议额外安装对应章节依赖，例如 PyTorch、torchvision、matplotlib 等。


## 构建书籍

仓库根目录提供了统一构建脚本 [book_generate.sh](book_generate.sh)。默认会扫描 `books/` 下的 notebook，并生成一个聚合的 Jupyter Book 站点，HTML 输出到 `_build/books`。

直接构建：

```bash
bash book_generate.sh
```

指定输入目录与输出目录：

```bash
./book_generate.sh ./books ./_build/books
```

如果 Myst 在线下载主题不稳定，可以先把当前使用的站点主题缓存到项目本地：

```bash
mkdir -p .myst-templates
myst templates download --site book-theme .myst-templates/book-theme
```

构建脚本会优先使用项目内的 `.myst-templates/book-theme`，因此下载一次后即可复用本地模板，避免每次构建都访问 GitHub。

构建完成后，聚合站点入口位于：

- `_build/books/index.html`

## 本地预览

开发时推荐直接使用 [book_start.sh](book_start.sh)，它会生成聚合 Jupyter Book 源目录，并交给 `jupyter-book start` 原生预览服务：

```bash
./book_start.sh
```

默认访问地址：

```text
http://127.0.0.1:8000
```

也可以用 `PORT` 指定端口：

```bash
PORT=8765 ./book_start.sh
```

如果只想预览已经构建好的静态文件，也可以启动一个静态文件服务器：

```bash
python3 -m http.server 8000 --directory _build/books
```

启动后可在浏览器中访问：

```text
http://localhost:8000
```

## GitHub Pages 访问

```text
https://suibeai.github.io/computer_vision_book/
```

## Jupyter Notebook 本地访问

在仓库根目录启动 Jupyter：

```bash
jupyter notebook
```

或使用更现代的界面：

```bash
jupyter lab
```

默认访问地址（以终端实际输出为准）：

```text
http://localhost:8888
```

如果在远程机器上运行，可使用：

```bash
jupyter notebook --ip 0.0.0.0 --port 8888 --no-browser
```
