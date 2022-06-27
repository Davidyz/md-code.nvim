# md-code.nvim

[English](./README.md)  
一个用于提高 markdown 代码块码字效率的插件。

## 致谢

本插件的初版来自[此配置文件](https://github.com/denstiny/nvim-nanny).

## 使用方法

本插件可以识别如下的代码块：

<pre>
```python
print('hello world')
```
</pre>

_`python`可以替换为任意其他文件格式以触发相关的 vim 插件，如 lsp 和
tree-sitter。_

在`Normal`模式下将光标置于代码块中，然后执行`:EditBufferCodeBlock`命令。该命令会
创建一个临时文件并把该代码块中的代码复制进这个临时文件里，如图：
![](docs/demo.png)

写完代码后，在`Normal`模式下执行`:CloseMdCode`命令或按`q`键，本插件会把代码插入
源 markdown 文件中。

一些 markdown 处理软件（如[pandoc](https://pandoc.org/)）支持使用类
似`{.python .number}`语法添加行号，本插件对此做了适配，能够正确识别语言种类。
