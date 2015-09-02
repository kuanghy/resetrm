RestRM
======

Linux 下用 shell 脚本实现的删除命令。主要是对 rm 命令进行重新封装，实现将文件删除到回收站，必要时将其恢复。

### 主要功能
- 1. 删除文件到回收站（~/.trash/），并支持恢复文件到原位置
- 2. 删除到回收站中的文件的文件名以`原文件+删除时间`的形式保存，恢复文件时应提供此新的文件名
- 3. 删除文件时创建删除日志，日志的每一行记录一个文件的新名、原名、删除时间和原位置信息
- 4. 支持清空回收站，永久删除回收站中文件，删除时给出确认提示
- 5. 删除大于 2G 文件时可直接删除，也可删除到回收站

### 安装方式
将项目中的 delete.sh 拷贝到系统环境变量所配置的目录中，前提是给该文件加上可执行权限，例如：

> chmod a+x delete.sh

> cp delete.sh /usr/bin/delete

或者做软链接：

> ln -s $PWD/delete.sh /usr/bin/delete

### 效果展示
![resetrm](http://ww1.sinaimg.cn/mw690/c3c88275jw1evnvjex7a0j20n907qtag.jpg)

### 作者
[Huoty](http://kuanghy.github.io/about/)<br>
sudohuoty@163.com<br>
2015.09.02<br>
