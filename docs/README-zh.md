# Claude Plugins

wishos 自用的 Claude 插件集合。

## 插件列表

### batch-git

批量操作多个 git 仓库的插件。

#### 功能

- 批量更新所有 git 仓库（git pull）
- 批量切换分支

#### 触发语句

**批量更新**（`/batch-git:pull`）：
- 帮我批量更新 git 库
- 批量更新所有 git 仓库
- update all git repos
- pull all git

**批量切换分支**（`/batch-git:switch`）：
- 批量切换到 xxx 分支
- 切换所有 git 库到某分支
- switch all git repos to branch

#### 使用方式

通过 Claude Code 触发：
- `/batch-git:pull` — 批量更新所有 git 仓库
- `/batch-git:switch` — 批量切换所有 git 仓库的分支

插件会自动查找目标目录下的所有 git 仓库并逐个执行操作。

#### 注意事项

- 默认目录为当前工作目录 `$PWD`
- 如果用户没有指定分支名，会提示用户输入
- 本地有未提交的更改时，会跳过该仓库并提示
- 输出使用 Unicode 符号和表格格式，美观清晰

### translate-github

翻译 GitHub 项目文档的插件（英文→中文），支持增量翻译。

#### 功能

- 将指定目录下的英文文档翻译为中文
- 译文输出到项目根目录的 `wishos-docs/` 目录，保持原始目录结构
- 基于 git 版本的增量翻译，只翻译有变更的文件
- 翻译状态持久化，支持中断恢复

#### 触发语句

**翻译文档**：
- /translate-github
- 翻译文档
- 翻译这个项目
- translate github docs
- translate this project

**增量更新翻译**：
- 更新翻译
- 增量翻译
- update translation

**查看翻译状态**：
- 翻译状态
- translation status

#### 使用方式

通过 Claude Code 触发，直接说 `/translate-github` 并指定要翻译的目录即可。

```
# 示例对话
用户：/translate-github
Claude：请确认项目根目录和要翻译的目录
用户：翻译 docs 和 guides 目录
Claude：（自动执行初始化、文件发现、逐文件翻译、保存状态）
```

插件会自动处理：
- 创建 `wishos-docs/` 输出目录及镜像目录结构
- 检测 git 版本差异，确定需要翻译的文件
- 逐文件读取、翻译、写入
- 保存翻译状态（git commit hash），支持增量翻译

#### 翻译规则

- 代码块和行内代码不翻译
- URL 和链接地址不翻译（链接文字翻译）
- 命名标识符（变量名、函数名、类名等）不翻译
- 品牌和专有名词不翻译
- 保持 Markdown 格式结构不变
- 技术术语首次出现括号标注英文原文

#### 注意事项

- 支持 `.md`、`.txt`、`.rst` 文件类型
- 翻译状态存储在 `wishos-docs/.translate-state` 文件中
- 翻译中断后重新运行会自动恢复（幂等设计）
- 自动排除 `node_modules`、`.git` 等目录

## Skills

同时提供 SKILL.md 格式的技能文件，支持 Qoder 等其他 AI 编码工具使用。

| 技能 | 说明 | 路径 |
|------|------|------|
| batch-git | 批量 git pull 和分支切换 | `skills/batch-git/SKILL.md` |
| translate-github | 翻译 GitHub 项目文档（英→中），支持增量翻译 | `skills/translate-github/SKILL.md` |

Skills 是插件的通用版本，不依赖 Claude Code 特定工具，可在任何支持 SKILL.md 规范的 AI 编码工具中使用。

## 添加新插件

参考现有插件的结构：

```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json          # 插件元信息
├── commands/
│   └── <plugin-name>.md    # 命令定义和触发模式
└── scripts/                  # 可选
    └── <plugin-name>.sh    # 实现脚本
```

创建新插件时，必须同步在 `skills/` 下创建对应的 SKILL.md 技能文件。

```
skills/<skill-name>/
├── SKILL.md                  # 技能定义（YAML frontmatter + 工作流）
└── references/               # 可选：大型参考文档
    └── *.md
```

### plugin.json

插件元信息 JSON 文件，包含：
- name: 插件名称
- version: 版本号
- description: 描述
- author: 作者

### commands/<plugin-name>.md

定义何时触发插件以及如何执行。包含触发语句列表和执行步骤。
插件逻辑可以直接写在命令文件中（由 Claude 原生工具执行），也可以调用外部脚本。

### scripts/<plugin-name>.sh（可选）

实现具体功能的 shell 脚本（通常为 bash）。如果插件逻辑已完全内嵌在命令文件中，则不需要此目录。
