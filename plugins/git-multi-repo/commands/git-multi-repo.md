# Git Multi-Repo Command

## Usage

### 批量更新 git 库

当用户说"帮我批量更新 git 库"、"批量更新所有 git 仓库"、"update all git repos"、"pull all git"时：

1. 首先确认要操作的根目录（默认使用当前工作目录 `$PWD`）
2. 执行脚本：
   ```
   ./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD"
   ```
3. 美观地输出结果

### 批量切换分支

当用户说"批量切换到 xxx 分支"、"切换所有 git 库到某分支"、"switch all git repos to branch"时：

1. 首先确认目标分支名
2. 执行脚本：
   ```
   ./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD" <分支名>
   ```
3. 美观地输出结果

## 注意事项

- 如果用户没有指定目录，默认使用当前工作目录 `$PWD`
- 如果用户没有指定分支名，提示用户输入
- 保持输出美观清晰，使用 Unicode 符号和表格格式
