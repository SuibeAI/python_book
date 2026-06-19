# Python Notebook 教程

这是一个面向 Python 初学者的中文 Notebook 课程仓库。课程以教学型 Jupyter Notebook 为主要形式，强调从直觉出发，逐步落到可运行代码。

课程写作遵循三点：

- 先解释概念，再展示代码。
- 示例尽量小而完整，便于直接运行和观察结果。
- 习题采用简答题和代码填空题，代码题会在未完成时提示继续作答。

## 当前内容

当前已组织的主线课程位于 `books/01_基础知识/`，按学习顺序包括：

| 顺序 | Notebook | 主题 |
|---:|---|---|
| 1 | `01_python示例.ipynb` | 第一个 Python Notebook，认识 `print`、变量和简单输入输出 |
| 2 | `02_python变量与基本数据类型.ipynb` | 变量、整数、浮点数、字符、类型转换与底层表示直觉 |
| 3 | `03_python控制结构-顺序与选择结构.ipynb` | 顺序结构、`if`、`elif`、`else` 与会员折扣示例 |
| 4 | `04_python控制结构-循环结构.ipynb` | `for`、`while`、循环中的条件判断与累加计算 |
| 5 | `05_python列表与元组.ipynb` | 列表、元组、索引、遍历与销售记录建模 |

推荐按上表顺序学习。前几节会逐步引入变量、数据类型、控制结构和组合数据结构，后续 Notebook 默认读者已经掌握这些基础。

## 目录结构

```text
.
├── books/
│   └── 01_基础知识/
│       ├── 01_python示例.ipynb
│       ├── 02_python变量与基本数据类型.ipynb
│       ├── 03_python控制结构-顺序与选择结构.ipynb
│       ├── 04_python控制结构-循环结构.ipynb
│       └── 05_python列表与元组.ipynb
└── README.md
```

各目录用途：

- `books/`：课程正文与教学型 Notebook。
- `_build/`：站点构建输出目录，不纳入版本控制。

## 学习建议

如果你是 Python 初学者，建议从 `books/01_基础知识/01_python示例.ipynb` 开始：

1. 顺序运行每个代码单元，先观察输出。
2. 修改变量值或示例数据，再运行一次。
3. 完成每节末尾习题，尤其是代码填空题。
4. 如果看到 `请完成题目后再运行`，说明该题仍有 `...` 占位没有替换。

学习时不要急着记 API 名称。更重要的是理解：数据如何表示、代码按什么顺序执行、条件和循环如何改变执行过程。

## 环境要求

建议使用 Python 3.10 及以上版本。

安装 Jupyter：

```bash
python3 -m pip install -U notebook jupyterlab
```

在仓库根目录启动：

```bash
jupyter lab
```

或使用传统 Notebook 界面：

```bash
jupyter notebook
```

默认访问地址以终端输出为准，通常类似：

```text
http://localhost:8888
```

## 构建书籍

如果本地已安装 Jupyter Book，可以将 `books/` 构建为静态站点：

```bash
python3 -m pip install -U jupyter-book
./book_generate.sh ./books ./_build/books directory
```

构建输出通常位于：

```text
_build/books/index.html
```

## GitHub Pages

发布后的课程站点地址：

```text
https://suibeai.github.io/python_book/
```

本仓库使用 GitHub Actions 构建并部署 Pages。相关配置位于 `.github/workflows/pages.yml`，构建脚本为 `book_generate.sh`。

## 代码下载

仓库地址：[SuibeAI/python_book](https://github.com/SuibeAI/python_book)

```bash
git clone https://github.com/SuibeAI/python_book.git
cd python_book
```
