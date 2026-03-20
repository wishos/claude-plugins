# Claude Plugins

A collection of custom Claude plugins for wishos.

## Plugins

### batch-git

A plugin for batch operating on multiple git repositories.

#### Features

- Batch update all git repositories (git pull)
- Batch switch branches

#### Trigger Phrases

**Batch Update** (`/batch-git:pull`):
- 帮我批量更新 git 库
- 批量更新所有 git 仓库
- update all git repos
- pull all git

**Batch Switch Branch** (`/batch-git:switch`):
- 批量切换到 xxx 分支
- 切换所有 git 库到某分支
- switch all git repos to branch

#### Usage

Triggered through Claude Code:
- `/batch-git:pull` — Batch update all git repositories
- `/batch-git:switch` — Batch switch branches for all git repositories

The plugin automatically finds all git repositories under the target directory and operates on each one.

#### Notes

- Default directory is current working directory `$PWD`
- If branch name is not specified, prompt user to enter
- Skip repositories with uncommitted changes and show warning
- Output uses Unicode symbols and table format for clarity

### translate-github

A plugin for translating GitHub project documentation (English to Chinese) with incremental translation support.

#### Features

- Translate English documents in specified directories to Chinese
- Output translations to `wishos-docs/` directory in project root, preserving original directory structure
- Git version-based incremental translation - only translates changed files
- Persistent translation state with interrupt recovery support

#### Trigger Phrases

**Translate Docs**:
- /translate-github
- 翻译文档
- 翻译这个项目
- translate github docs
- translate this project

**Incremental Update**:
- 更新翻译
- 增量翻译
- update translation

**Check Status**:
- 翻译状态
- translation status

#### Usage

Triggered through Claude Code. Simply say `/translate-github` and specify the directories to translate.

```
# Example conversation
User: /translate-github
Claude: Please confirm the project root and directories to translate
User: Translate the docs and guides directories
Claude: (automatically performs init, file discovery, translation, state save)
```

The plugin automatically handles:
- Creating `wishos-docs/` output directory with mirrored directory structure
- Detecting git version differences to determine files needing translation
- Reading, translating, and writing each file
- Saving translation state (git commit hash) for incremental translation

#### Translation Rules

- Code blocks and inline code are not translated
- URLs and link addresses are not translated (link text is translated)
- Naming identifiers (variable names, function names, class names, etc.) are not translated
- Brand names and proper nouns are not translated
- Markdown format structure is preserved
- Technical terms annotated with English original in parentheses on first occurrence

#### Notes

- Supports `.md`, `.txt`, `.rst` file types
- Translation state stored in `wishos-docs/.translate-state`
- Re-running after interruption automatically recovers (idempotent design)
- Automatically excludes `node_modules`, `.git` and other directories

## Adding a New Plugin

Refer to existing plugin structures:

```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── commands/
│   └── <plugin-name>.md     # Command definitions and trigger patterns
└── scripts/                   # Optional
    └── <plugin-name>.sh     # Implementation script
```

### plugin.json

Plugin metadata JSON file, containing:
- name: Plugin name
- version: Version number
- description: Description
- author: Author

### commands/<plugin-name>.md

Defines when to trigger the plugin and how to execute it. Contains trigger phrase list and execution steps.
Plugin logic can be embedded directly in the command file (executed by Claude's native tools) or call external scripts.

### scripts/<plugin-name>.sh (Optional)

Shell script (usually bash) that implements the actual functionality. Not required if the plugin logic is fully embedded in the command file.
