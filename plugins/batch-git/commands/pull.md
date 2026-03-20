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
- 提取仓库名称（目录名）和路径
- 向用户报告：找到 N 个 git 仓库

### 3. 逐个执行 git pull

对每个找到的 git 仓库，依次执行：

1. **检查未提交更改**：用 Bash 执行 `git -C <repo-path> diff-index --quiet HEAD -- 2>/dev/null`
   - 如果退出码非 0，说明有未提交更改，跳过该仓库并报告：`✗ <repo-name> │ 本地有未提交的更改`
   - 继续处理下一个仓库

2. **执行 pull**：用 Bash 执行 `git -C <repo-path> pull 2>&1`
   - 成功且输出包含 "Already up to date"：报告 `✓ <repo-name> │ Already up to date`
   - 成功且有更新：报告 `✓ <repo-name> │ <更新信息>`
   - 失败：报告 `✗ <repo-name> │ <错误信息>`

### 4. 输出汇总报告

完成所有仓库处理后，输出统计：
- 总计 N 个仓库
- 成功 X 个
- 失败 Y 个（有未提交更改或 pull 失败）
- 如果有失败仓库，列出失败清单

## 注意事项

- 所有 git 命令使用 `git -C <path>` 指定仓库目录，不需要 cd
- 保持输出美观清晰
- 不修改任何仓库内容，只执行 git pull
