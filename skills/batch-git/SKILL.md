---
name: batch-git
description: Batch operate on multiple git repositories. This skill should be used when the user asks to "batch pull", "pull all git", "update all git repos", "batch switch branch", "switch all git repos to branch", or mentions batch operations across multiple git repositories.
version: 1.0.0
---

# Batch Git Operations

Batch operate on multiple git repositories under a directory. Supports two operations: batch pull (update all repos) and batch switch branch (switch all repos to a specified branch). Automatically skips repos with uncommitted changes and reports a summary of results.

## When to Activate

- User wants to update all git repositories: "batch pull", "pull all git", "update all git repos"
- User wants to switch branches for all repos: "batch switch to xxx branch", "switch all git repos to branch"

## Operation 1: Batch Pull

### Workflow

1. **Confirm target directory**: Ask the user for the root directory `<TARGET>` (default: current working directory). All subdirectories containing `.git` under this directory are treated as git repositories.

2. **Find all git repositories**: Recursively find all `.git` directories under `<TARGET>`. Each `.git` directory's parent is a git repository. Extract repository names and absolute paths into a list.

3. **Execute all pull operations at once**: Construct and execute a single shell script that processes all repositories in one run. Replace `<repo-path-N>` placeholders with the actual repository paths found in step 2:

```bash
success=0; fail=0; total=0; fail_list=""
for repo in "<repo-path-1>" "<repo-path-2>" "<repo-path-3>"; do
  total=$((total+1))
  name=$(basename "$repo")
  if ! git -C "$repo" diff-index --quiet HEAD -- 2>/dev/null; then
    echo "✗ $name │ uncommitted changes"
    fail=$((fail+1))
    fail_list="$fail_list\n  - $name (uncommitted changes)"
    continue
  fi
  output=$(git -C "$repo" pull 2>&1)
  if [ $? -eq 0 ]; then
    echo "✓ $name │ $output"
    success=$((success+1))
  else
    echo "✗ $name │ $output"
    fail=$((fail+1))
    fail_list="$fail_list\n  - $name ($output)"
  fi
done
echo ""; echo "===== Summary ====="
echo "Total: $total repos"
echo "Success: $success"
echo "Failed: $fail"
if [ -n "$fail_list" ]; then echo -e "Failed list:$fail_list"; fi
```

4. **Show results**: Display the shell output to the user directly.

## Operation 2: Batch Switch Branch

### Workflow

1. **Confirm parameters**: Ask for the target branch name (must ask if not specified). Confirm the root directory `<TARGET>` (default: current working directory).

2. **Find all git repositories**: Same as batch pull step 2 - recursively find all `.git` directories and extract repo paths.

3. **Execute all switch operations at once**: Construct and execute a single shell script. Replace `<BRANCH>` with the target branch name and `<repo-path-N>` with actual paths:

```bash
branch="<BRANCH>"; success=0; fail=0; total=0; fail_list=""
for repo in "<repo-path-1>" "<repo-path-2>" "<repo-path-3>"; do
  total=$((total+1))
  name=$(basename "$repo")
  git -C "$repo" fetch --all 2>/dev/null
  if ! git -C "$repo" diff-index --quiet HEAD -- 2>/dev/null; then
    echo "✗ $name │ uncommitted changes"
    fail=$((fail+1))
    fail_list="$fail_list\n  - $name (uncommitted changes)"
    continue
  fi
  checkout_output=$(git -C "$repo" checkout "$branch" 2>&1)
  if [ $? -ne 0 ]; then
    echo "✗ $name │ switch failed: $checkout_output"
    fail=$((fail+1))
    fail_list="$fail_list\n  - $name (switch failed: $checkout_output)"
    continue
  fi
  pull_output=$(git -C "$repo" pull 2>&1)
  if [ $? -eq 0 ]; then
    echo "✓ $name │ switched successfully"
    success=$((success+1))
  else
    echo "✗ $name │ pull failed: $pull_output"
    fail=$((fail+1))
    fail_list="$fail_list\n  - $name (pull failed: $pull_output)"
  fi
done
echo ""; echo "===== Summary ====="
echo "Total: $total repos"
echo "Success: $success"
echo "Failed: $fail"
if [ -n "$fail_list" ]; then echo -e "Failed list:$fail_list"; fi
```

4. **Show results**: Display the shell output to the user directly.

## Important Notes

- All git commands use `git -C <path>` to specify the repository directory, no need to cd
- **Critical: all repository operations must be combined into a single shell script execution, not executed one by one per repository**
- Do not modify any repository content, only perform git operations
- If the user does not specify a branch name (for switch operation), ask before proceeding
