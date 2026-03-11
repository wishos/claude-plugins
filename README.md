# Claude Plugins

wishos 自用的 Claude 插件集合。

[English](./docs/README-en.md)

---

## 插件列表

### git-multi-repo

批量管理多个 git 仓库的插件。

| 功能 | 触发语句 |
|------|----------|
| 批量更新 | `帮我批量更新 git 库` · `update all git repos` |
| 分支切换 | `批量切换到 xxx 分支` · `switch all git repos` |

**使用**

```bash
# 批量更新（当前目录）
./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD"

# 批量更新（指定目录）
./plugins/git-multi-repo/scripts/git-multi-repo.sh /path/to/dir

# 批量切换分支
./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD" branch-name
```

---

## 目录结构

```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── <plugin-name>.md
└── scripts/
    └── <plugin-name>.sh
```

---

## 添加新插件

参考 `plugins/git-multi-repo` 的结构创建新插件。

### plugin.json

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "插件描述",
  "author": "wishos"
}
```

### commands/<plugin-name>.md

定义触发语句和执行步骤。

### scripts/<plugin-name>.sh

实现具体功能的 shell 脚本。
