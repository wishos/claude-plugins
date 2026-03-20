# Batch Git Switch Branch Command

## Usage

当用户说"批量切换到 xxx 分支"、"切换所有 git 库到某分支"、"switch all git repos to branch"时，按以下工作流执行。

## 工作流

### 1. 确认参数

- 确认目标分支名（如果用户没有指定，提示用户输入）
- 确认要操作的根目录 `<TARGET>`（默认使用当前工作目录 `$PWD`）

### 2. 查找所有 git 仓库

- 使用 Glob 工具查找 `<TARGET>` 下所有 `.git` 目录：`**/.git`
- 每个 `.git` 目录的父目录即为一个 git 仓库
- 提取仓库名称（目录名）和路径，记录为列表

### 3. 一次性执行所有分支切换操作

**重要：将所有仓库的操作合并到一条 Bash 命令中执行，避免多次确认。**

将步骤 2 中找到的所有仓库路径拼接成一个 Bash 脚本，用**单次 Bash 调用**执行所有操作。将 `<BRANCH>` 替换为目标分支名，将 `<repo-path-N>` 替换为实际仓库路径。脚本模板如下：

```bash
branch="<BRANCH>"; success=0; fail=0; total=0; fail_list=""
for repo in "<repo-path-1>" "<repo-path-2>" "<repo-path-3>"; do
  total=$((total+1))
  name=$(basename "$repo")
  git -C "$repo" fetch --all 2>/dev/null
  if ! git -C "$repo" diff-index --quiet HEAD -- 2>/dev/null; then
    echo "✗ $name │ 本地有未提交的更改"
    fail=$((fail+1))
    fail_list="$fail_list\n  - $name (未提交更改)"
    continue
  fi
  checkout_output=$(git -C "$repo" checkout "$branch" 2>&1)
  if [ $? -ne 0 ]; then
    echo "✗ $name │ 切换失败: $checkout_output"
    fail=$((fail+1))
    fail_list="$fail_list\n  - $name (切换失败: $checkout_output)"
    continue
  fi
  pull_output=$(git -C "$repo" pull 2>&1)
  if [ $? -eq 0 ]; then
    echo "✓ $name │ 切换成功"
    success=$((success+1))
  else
    echo "✗ $name │ 拉取失败: $pull_output"
    fail=$((fail+1))
    fail_list="$fail_list\n  - $name (拉取失败: $pull_output)"
  fi
done
echo ""; echo "===== 汇总 ====="
echo "总计: $total 个仓库"
echo "成功: $success 个"
echo "失败: $fail 个"
if [ -n "$fail_list" ]; then echo -e "失败清单:$fail_list"; fi
```

### 4. 展示结果

将 Bash 输出直接展示给用户即可，脚本已包含汇总信息。

## 注意事项

- 所有 git 命令使用 `git -C <path>` 指定仓库目录，不需要 cd
- **关键：必须将所有仓库操作合并为单次 Bash 调用，不能逐个仓库单独调用 Bash**
- 如果用户没有指定分支名，必须先询问
- 保持输出美观清晰
