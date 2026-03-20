# Batch Git Pull Command

## Usage

当用户说"帮我批量更新 git 库"、"批量更新所有 git 仓库"、"update all git repos"、"pull all git"时，按以下工作流执行。

## 工作流

### 1. 确认目标目录

- 确认要操作的根目录 `<TARGET>`（默认使用当前工作目录 `$PWD`）
- 该目录下的所有包含 `.git` 的子目录都将被视为 git 仓库

### 2. 查找所有 git 仓库

- 使用 Glob 工具查找 `<TARGET>` 下所有 `.git` 目录：`**/.git`
- 每个 `.git` 目录的父目录即为一个 git 仓库
- 提取仓库名称（目录名）和路径，记录为列表

### 3. 一次性执行所有 git pull 操作

**重要：将所有仓库的操作合并到一条 Bash 命令中执行，避免多次确认。**

将步骤 2 中找到的所有仓库路径拼接成一个 Bash 脚本，用**单次 Bash 调用**执行所有操作。脚本模板如下：

```bash
success=0; fail=0; total=0; fail_list=""
for repo in "<repo-path-1>" "<repo-path-2>" "<repo-path-3>"; do
  total=$((total+1))
  name=$(basename "$repo")
  if ! git -C "$repo" diff-index --quiet HEAD -- 2>/dev/null; then
    echo "✗ $name │ 本地有未提交的更改"
    fail=$((fail+1))
    fail_list="$fail_list\n  - $name (未提交更改)"
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
echo ""; echo "===== 汇总 ====="
echo "总计: $total 个仓库"
echo "成功: $success 个"
echo "失败: $fail 个"
if [ -n "$fail_list" ]; then echo -e "失败清单:$fail_list"; fi
```

将 `<repo-path-1>` `<repo-path-2>` 等替换为步骤 2 中发现的实际仓库绝对路径。

### 4. 展示结果

将 Bash 输出直接展示给用户即可，脚本已包含汇总信息。

## 注意事项

- 所有 git 命令使用 `git -C <path>` 指定仓库目录，不需要 cd
- **关键：必须将所有仓库操作合并为单次 Bash 调用，不能逐个仓库单独调用 Bash**
- 保持输出美观清晰
- 不修改任何仓库内容，只执行 git pull
