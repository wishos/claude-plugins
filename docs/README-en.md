# Claude Plugins

A collection of custom Claude plugins for wishos.

## Plugins

### git-multi-repo

A plugin for batch managing multiple git repositories.

#### Features

- Batch update all git repositories (git pull)
- Batch switch branches

#### Trigger Phrases

**Batch Update**:
- 帮我批量更新 git库 (帮我批量更新 git 库)
- 批量更新所有 git 仓库
- update all git repos
- pull all git

**Batch Switch Branch**:
- 批量切换到 xxx 分支 (批量切换到 xxx 分支)
- 切换所有 git 库到某分支
- switch all git repos to branch

#### Usage

```bash
# Batch update (default: current directory)
./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD"

# Batch update specified directory
./plugins/git-multi-repo/scripts/git-multi-repo.sh /path/to/dir

# Batch switch branch
./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD" branch-name
```

#### Notes

- Default directory is current working directory `$PWD`
- If branch name is not specified, prompt user to enter
- Skip repositories with uncommitted changes and show warning
- Output uses Unicode symbols and table format for clarity

## Adding a New Plugin

Refer to the structure of `plugins/git-multi-repo`:

```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── commands/
│   └── <plugin-name>.md     # Command definitions and trigger patterns
└── scripts/
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

### scripts/<plugin-name>.sh

Shell script (usually bash) that implements the actual functionality.
