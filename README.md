# Claude Plugins

wishos 自用的 Claude 插件集合。

[English](./docs/README-en.md)

---

## 插件列表

### batch-git

批量操作多个 git 仓库的插件。

| 功能 | 命令 | 触发语句 |
|------|------|----------|
| 批量更新 | `/batch-git:pull` | `帮我批量更新 git 库` · `update all git repos` |
| 分支切换 | `/batch-git:switch` | `批量切换到 xxx 分支` · `switch all git repos` |

**使用**

通过 Claude Code 触发，直接说 `/batch-git:pull` 或 `/batch-git:switch` 即可。
插件会自动查找目录下的所有 git 仓库并逐个执行操作。

### translate-github

翻译 GitHub 项目文档（英文→中文），支持增量翻译。

| 功能 | 命令 | 触发语句 |
|------|------|----------|
| 翻译文档 | `/translate-github:run` | `翻译文档` · `translate github docs` |
| 增量更新 | `/translate-github:run` | `更新翻译` · `增量翻译` |
| 查看状态 | `/translate-github:run` | `翻译状态` · `translation status` |

**使用**

通过 Claude Code 触发，直接说 `/translate-github:run` 并指定要翻译的目录即可。
插件会自动处理目录创建、文件发现、增量检测和状态保存。

---

## 目录结构

```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── <plugin-name>.md
└── scripts/                    # 可选
    └── <plugin-name>.sh
```

---

## 添加新插件

参考现有插件的结构创建新插件。

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

定义触发语句和执行步骤。插件逻辑可以直接写在命令文件中（由 Claude 原生工具执行），也可以调用外部脚本。

### scripts/<plugin-name>.sh（可选）

实现具体功能的 shell 脚本。如果插件逻辑已完全内嵌在命令文件中，则不需要此目录。
