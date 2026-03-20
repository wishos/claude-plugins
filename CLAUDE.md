# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is the wishos repository for managing Claude plugins. It contains custom Claude plugins used by wishos.

## Plugin Structure

Each plugin follows a standard structure:

```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata (name, version, description, author)
├── commands/
│   └── <plugin-name>.md     # Command definitions and trigger patterns
└── scripts/
    └── <plugin-name>.sh     # Implementation scripts (usually bash)
```

### Plugin Files

- **plugin.json**: Contains plugin metadata in JSON format with fields: name, version, description, author
- **commands/*.md**: Defines when to trigger the plugin and how to execute it. Uses pattern matching on user input
- **scripts/*.sh**: Shell scripts (usually bash) that implement the actual functionality

## Adding a New Plugin

1. Create the plugin directory structure under `plugins/<plugin-name>/`
2. Add `plugin.json` with metadata
3. Add command definition in `commands/<plugin-name>.md`
4. Add implementation script in `scripts/<plugin-name>.sh`
5. Add plugin documentation in `docs/README-zh.md` and `docs/README-en.md` (Chinese and English versions)
6. Update `README.md` to include the new plugin
7. The script will be executed with arguments extracted from user input

## Existing Plugins

- **git-multi-repo**: Batch manage multiple git repositories (pull all, switch branches)
- **translate-github**: Translate GitHub project docs (EN→CN) with incremental translation support

## Common Patterns

- Scripts use color codes for output formatting (RED, GREEN, YELLOW)
- Default working directory is current working directory (`$PWD`)
- Commands are triggered by specific phrases in user input (Chinese or English)
- Documentation: Maintain both Chinese (`docs/README-zh.md`) and English (`docs/README-en.md`) versions
- README.md: Pure Markdown in Chinese, with link to English version at top
