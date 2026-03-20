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
- 提取仓库名称（目录名）和路径
- 向用户报告：找到 N 个 git 仓库，将切换到 `<branch>` 分支

### 3. 逐个执行分支切换

对每个找到的 git 仓库，依次执行：

1. **Fetch 最新引用**：用 Bash 执行 `git -C <repo-path> fetch --all 2>/dev/null`

2. **检查未提交更改**：用 Bash 执行 `git -C <repo-path> diff-index --quiet HEAD -- 2>/dev/null`
   - 如果退出码非 0，跳过该仓库并报告：`✗ <repo-name> │ 本地有未提交的更改`

3. **切换分支**：用 Bash 执行 `git -C <repo-path> checkout <branch> 2>&1`
   - 如果失败，报告：`✗ <repo-name> │ 切换失败: <错误信息>`
   - 继续处理下一个仓库

4. **执行 pull**：用 Bash 执行 `git -C <repo-path> pull 2>&1`
   - 成功：报告 `✓ <repo-name> │ 切换成功`
   - 失败：报告 `✗ <repo-name> │ 拉取失败: <错误信息>`

### 4. 输出汇总报告

完成所有仓库处理后，输出统计：
- 总计 N 个仓库
- 成功 X 个
- 失败 Y 个
- 如果有失败仓库，列出失败清单及失败原因

## 注意事项

- 所有 git 命令使用 `git -C <path>` 指定仓库目录，不需要 cd
- 如果用户没有指定分支名，必须先询问
- 保持输出美观清晰
