# Claude Plugins

wishos 自用的 Claude 插件集合。

## 插件列表

### git-multi-repo

批量管理多个 git 仓库的插件。

#### 功能

- 批量更新所有 git 仓库（git pull）
- 批量切换分支

#### 触发语句

**批量更新**：
- 帮我批量更新 git 库
- 批量更新所有 git 仓库
- update all git repos
- pull all git

**批量切换分支**：
- 批量切换到 xxx 分支
- 切换所有 git 库到某分支
- switch all git repos to branch

#### 使用方式

```bash
# 批量更新（默认当前目录）
./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD"

# 批量更新指定目录
./plugins/git-multi-repo/scripts/git-multi-repo.sh /path/to/dir

# 批量切换分支
./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD" branch-name
```

#### 注意事项

- 默认目录为当前工作目录 `$PWD`
- 如果用户没有指定分支名，会提示用户输入
- 本地有未提交的更改时，会跳过该仓库并提示
- 输出使用 Unicode 符号和表格格式，美观清晰

## 添加新插件

参考 `plugins/git-multi-repo` 的结构：

```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json          # 插件元信息
├── commands/
│   └── <plugin-name>.md    # 命令定义和触发模式
└── scripts/
    └── <plugin-name>.sh    # 实现脚本
```

### plugin.json

插件元信息 JSON 文件，包含：
- name: 插件名称
- version: 版本号
- description: 描述
- author: 作者

### commands/<plugin-name>.md

定义何时触发插件以及如何执行。包含触发语句列表和执行步骤。

### scripts/<plugin-name>.sh

实现具体功能的 shell 脚本（通常为 bash）。
