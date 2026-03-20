---
name: translate-github
description: Translate GitHub project documentation from English to Chinese with incremental translation support. This skill should be used when the user says "translate docs", "translate this project", "translate github docs", "update translation", "incremental translate", "translation status", or mentions translating project documentation.
version: 1.0.0
---

# Translate GitHub Documentation

Translate GitHub project documentation from English to Chinese. Outputs translated files to a `wishos-docs/` directory that mirrors the source directory structure. Supports incremental translation based on git commit history — only new and modified files are translated on subsequent runs.

## When to Activate

- **Full/incremental translation**: "translate docs", "translate this project", "translate github docs", "update translation", "incremental translate"
- **Check status**: "translation status"

## Key Conventions

- **Project root** `<PROJECT>`: the target project's root directory (default: current working directory)
- **Output directory**: `<PROJECT>/wishos-docs/`, mirrors source directory structure
- **State file**: `<PROJECT>/wishos-docs/.translate-state`, records translation version state
- **Translatable files**: `.md`, `.txt`, `.rst`
- **Excluded directories**: `wishos-docs`, `node_modules`, `.git`, `vendor`, `dist`, `build`

### State File Format

`wishos-docs/.translate-state` is a plain text file:

```
# translate-github state file
LAST_COMMIT=<40-char git commit hash>
LAST_RUN=<timestamp>
DIR=<directory1>
DIR=<directory2>
```

---

## Full Workflow

### Phase 1: Parameter Collection and Initialization

1. Confirm the project root directory `<PROJECT>` (default: current working directory)
2. Verify `<PROJECT>` is a git repository (check if `<PROJECT>/.git` exists)
3. Ask the user which directories to translate (e.g. `docs`, `guides`, `content`)
4. Verify each specified directory exists under `<PROJECT>`
5. Create `<PROJECT>/wishos-docs/` directory if it doesn't exist
6. For each specified directory, recursively mirror its subdirectory structure under `wishos-docs/`, excluding `node_modules`, `.git`, `vendor`, `dist`, `build`

### Phase 2: File Discovery and Translation Plan

7. Read the state file `<PROJECT>/wishos-docs/.translate-state` (if it exists), extract `LAST_COMMIT` and `DIR=` list
8. Determine files to translate:

   **Case A — First-time translation** (no state file or no LAST_COMMIT):
   - Find all `.md`, `.txt`, `.rst` files in each specified directory (excluding `wishos-docs/`, `node_modules/`, `.git/`, etc.)
   - Mark all found files as "new" — full translation required

   **Case B — Incremental translation** (LAST_COMMIT exists):
   - Verify LAST_COMMIT is reachable: `git -C <PROJECT> cat-file -t <LAST_COMMIT>`
   - If unreachable, fall back to Case A and inform user
   - If reachable, for each specified directory:
     - **Previously recorded directories**: use `git diff --name-only --diff-filter=A/M/D <LAST_COMMIT> HEAD -- <dir>` to detect new/modified/deleted files
     - **Newly added directories**: use full-scan mode, find all translatable files, mark as "new"
   - Detect deleted files via `git diff --name-only --diff-filter=D`

9. If no files need translation, inform user and exit
10. Show translation plan to user (new files count, modified files count, deleted files) and wait for confirmation

### Phase 3: Translate Files

#### 3a. New Files — Full Translation

For each "new" file:
- Read the source file content
- Translate the full content following the rules in `references/translation-rules.md`
- Write translated result to `<PROJECT>/wishos-docs/<file-path>`
- Report progress: `[3/15] done docs/new-guide.md (new, full translation)`

#### 3b. Modified Files — Partial Translation

For each "modified" file:
- Get specific changes: `git -C <PROJECT> diff <LAST_COMMIT> HEAD -- <file-path>`
- Analyze diff output: new lines (`+`), deleted lines (`-`), context lines (space prefix)
- Read existing translation file from `wishos-docs/`
- Apply partial updates to the existing translation:
  - New paragraphs/lines: translate per rules and insert at corresponding position
  - Deleted paragraphs/lines: remove from translation
  - Modified paragraphs/lines: replace with new translation
  - Use diff hunk headers (`@@ -a,b +c,d @@`) and context lines for precise positioning
- Edit the translation file with targeted modifications (not full rewrite)
- **Fallback**: if changes are too complex (major restructuring), fall back to full re-translation

#### 3c. Deleted Files

- Prompt user: source file has been deleted, delete corresponding translation?
- If confirmed, delete `<PROJECT>/wishos-docs/<file-path>`

#### Special Cases

- Empty source file: skip and report
- Source file already in Chinese: skip and report
- Very large file: read and translate in segments

### Phase 4: Save State and Summary

- Get current commit hash: `git -C <PROJECT> rev-parse HEAD`
- Write state file with current commit, timestamp, and directory list
- Output summary: total files, new translations, updates, deletions, saved commit hash

---

## Status Check Workflow

1. Confirm project root `<PROJECT>`
2. Read `<PROJECT>/wishos-docs/.translate-state`
3. If not found: inform user "translation not initialized yet"
4. If found: display last commit hash, last run time, translated directories, and pending changes count via `git diff --name-only <LAST_COMMIT> HEAD -- <dirs>`

---

## Error Handling

- Project root is not a git repository: inform user and stop
- Specified directory does not exist: inform user which directory is missing
- Single file translation fails: log failure, continue with other files, report failures at end
- Translation interrupted: state not saved, next run auto-recovers (already translated files are overwritten, ensuring idempotency)

## Important Notes

- All git commands use `git -C <PROJECT>` to specify the project directory
- The `wishos-docs/` directory maintains the exact same directory structure as the source
- Keep output clean and readable with Unicode progress markers
- When translating, strictly follow the complete rules in `references/translation-rules.md`
