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

### translate-github

翻译 GitHub 项目文档（英文→中文），支持增量翻译。

| 功能 | 触发语句 |
|------|----------|
| 翻译文档 | `/translate-github` · `翻译文档` · `translate github docs` |
| 增量更新 | `更新翻译` · `增量翻译` · `update translation` |
| 查看状态 | `翻译状态` · `translation status` |

**使用**

通过 Claude Code 触发，直接说 `/translate-github` 并指定要翻译的目录即可。
插件会自动处理目录创建、文件发现、增量检测和状态保存。

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
