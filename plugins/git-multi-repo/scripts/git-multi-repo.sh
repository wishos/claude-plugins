#!/bin/bash

# Git 多仓库管理脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 默认目录（当前工作目录）
TARGET_DIR="${1:-$(pwd)}"
BRANCH="$2"

# 查找所有 git 仓库
find_git_repos() {
    find "$TARGET_DIR" -type d -name ".git" 2>/dev/null
}

# 执行 git pull
do_pull() {
    local repo_dir="$1"
    local repo_name
    repo_name=$(basename "$(dirname "$repo_dir")")

    cd "$repo_dir/.." || return 1

    # 检查是否有未提交的更改
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo -e "${RED}✗ $repo_name${NC} │ ${RED}本地有未提交的更改${NC}"
        return 1
    fi

    # 执行 pull
    pull_result=$(git pull 2>&1)
    pull_exit=$?

    if [ $pull_exit -eq 0 ]; then
        if echo "$pull_result" | grep -q "Already up to date"; then
            echo -e "${GREEN}✓ $repo_name${NC} │ Already up to date"
        else
            echo -e "${GREEN}✓ $repo_name${NC} │ $pull_result"
        fi
        return 0
    else
        echo -e "${RED}✗ $repo_name${NC} │ $pull_result"
        return 1
    fi
}

# 执行分支切换
do_checkout_pull() {
    local repo_dir="$1"
    local branch="$2"
    local repo_name
    repo_name=$(basename "$(dirname "$repo_dir")")

    cd "$repo_dir/.." || return 1

    # 先 fetch 获取最新
    git fetch --all >/dev/null 2>&1

    # 检查是否有未提交的更改
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo -e "${RED}✗ $repo_name${NC} │ ${RED}本地有未提交的更改${NC}"
        return 1
    fi

    # 切换分支
    checkout_result=$(git checkout "$branch" 2>&1)
    checkout_exit=$?

    if [ $checkout_exit -ne 0 ]; then
        echo -e "${RED}✗ $repo_name${NC} │ ${RED}切换失败: $checkout_result${NC}"
        return 1
    fi

    # 执行 pull
    pull_result=$(git pull 2>&1)
    pull_exit=$?

    if [ $pull_exit -eq 0 ]; then
        if echo "$pull_result" | grep -q "Already up to date\|Updating\|Fast-forward"; then
            echo -e "${GREEN}✓ $repo_name${NC} │ 切换成功"
        else
            echo -e "${GREEN}✓ $repo_name${NC} │ $pull_result"
        fi
        return 0
    else
        echo -e "${RED}✗ $repo_name${NC} │ ${RED}拉取失败: $pull_result${NC}"
        return 1
    fi
}

# 主函数
main() {
    if [ -z "$BRANCH" ]; then
        # 批量更新模式
        echo "=========================================="
        echo "  批量更新 Git 仓库"
        echo "  目录: $TARGET_DIR"
        echo "=========================================="
        echo ""

        success=0
        fail=0

        while IFS= read -r repo; do
            if do_pull "$repo"; then
                ((success++))
            else
                ((fail++))
            fi
        done < <(find_git_repos)

        echo ""
        echo "-------------------------------------------"
        echo -e "总计: $((success + fail)) 个仓库 | ${GREEN}成功: $success${NC} | ${RED}失败: $fail${NC}"
    else
        # 批量切换分支模式
        echo "=========================================="
        echo "  批量切换 Git 分支"
        echo "  目录: $TARGET_DIR"
        echo "  分支: $BRANCH"
        echo "=========================================="
        echo ""

        success=0
        fail=0
        failed_repos=()

        while IFS= read -r repo; do
            if do_checkout_pull "$repo" "$BRANCH"; then
                ((success++))
            else
                ((fail++))
                repo_name=$(basename "$(dirname "$repo")")
                failed_repos+=("$repo_name")
            fi
        done < <(find_git_repos)

        echo ""
        echo "-------------------------------------------"
        echo -e "总计: $((success + fail)) 个仓库 | ${GREEN}成功: $success${NC} | ${RED}失败: $fail${NC}"

        if [ $fail -gt 0 ]; then
            echo ""
            echo "失败仓库:"
            for repo in "${failed_repos[@]}"; do
                echo "  • $repo"
            done
        fi
    fi
}

main
