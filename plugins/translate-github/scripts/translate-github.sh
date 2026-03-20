#!/bin/bash

# translate-github 辅助脚本
# 负责文件系统操作和 git 版本管理，翻译工作由 Claude Code 完成

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 常量
STATE_DIR="wishos-docs"
STATE_FILE=".translate-state"
FILE_EXTENSIONS="md|txt|rst"

# 排除目录
EXCLUDE_DIRS="wishos-docs|node_modules|\.git|\.svn|\.hg|vendor|dist|build|__pycache__"

# ===================== 公共函数 =====================

usage() {
    echo "Usage: $0 <command> <project-root> [dirs...]"
    echo ""
    echo "Commands:"
    echo "  init   <project-root> <dir1> [dir2...]  - 初始化翻译目录"
    echo "  list   <project-root> <dir1> [dir2...]  - 列出所有可翻译文件"
    echo "  diff   <project-root> <dir1> [dir2...]  - 列出需要翻译的变更文件"
    echo "  save   <project-root> <dir1> [dir2...]  - 保存翻译状态"
    echo "  status <project-root>                    - 查看翻译状态"
    exit 1
}

# 验证项目根目录是 git 仓库
validate_git_repo() {
    local project_root="$1"
    if [ ! -d "$project_root/.git" ]; then
        echo -e "${RED}Error: $project_root is not a git repository${NC}" >&2
        exit 2
    fi
}

# 验证指定目录存在
validate_dirs() {
    local project_root="$1"
    shift
    for dir in "$@"; do
        if [ ! -d "$project_root/$dir" ]; then
            echo -e "${RED}Error: Directory '$dir' does not exist in $project_root${NC}" >&2
            exit 3
        fi
    done
}

# 获取 state 文件路径
get_state_path() {
    local project_root="$1"
    echo "$project_root/$STATE_DIR/$STATE_FILE"
}

# 读取上次 commit hash
read_last_commit() {
    local state_path="$1"
    if [ -f "$state_path" ]; then
        grep "^LAST_COMMIT=" "$state_path" 2>/dev/null | head -1 | cut -d'=' -f2
    fi
}

# 读取已翻译的目录列表
read_state_dirs() {
    local state_path="$1"
    if [ -f "$state_path" ]; then
        grep "^DIR=" "$state_path" 2>/dev/null | cut -d'=' -f2
    fi
}

# 检查文件扩展名是否匹配
is_translatable_file() {
    local file="$1"
    echo "$file" | grep -qiE "\.(${FILE_EXTENSIONS})$"
}

# 查找目录下所有可翻译文件
find_translatable_files() {
    local project_root="$1"
    shift
    for dir in "$@"; do
        find "$project_root/$dir" -type f \( -iname "*.md" -o -iname "*.txt" -o -iname "*.rst" \) 2>/dev/null | while read -r file; do
            # 排除不需要的目录
            if ! echo "$file" | grep -qE "/(${EXCLUDE_DIRS})/"; then
                # 输出相对路径
                echo "${file#$project_root/}"
            fi
        done
    done | sort
}

# ===================== 子命令实现 =====================

# init: 初始化翻译环境
cmd_init() {
    local project_root="$1"
    shift
    local dirs=("$@")

    if [ ${#dirs[@]} -eq 0 ]; then
        echo -e "${RED}Error: At least one directory is required${NC}" >&2
        exit 1
    fi

    validate_git_repo "$project_root"
    validate_dirs "$project_root" "${dirs[@]}"

    # 创建 wishos-docs 根目录
    if [ ! -d "$project_root/$STATE_DIR" ]; then
        mkdir -p "$project_root/$STATE_DIR"
        echo -e "${GREEN}✓${NC} Created $STATE_DIR/"
    else
        echo -e "${YELLOW}→${NC} $STATE_DIR/ already exists"
    fi

    # 递归镜像目录结构
    for dir in "${dirs[@]}"; do
        # 找到源目录下所有子目录并在 wishos-docs 下镜像创建
        find "$project_root/$dir" -type d 2>/dev/null | while read -r src_dir; do
            # 排除不需要的目录
            if echo "$src_dir" | grep -qE "/(${EXCLUDE_DIRS})/"; then
                continue
            fi
            relative="${src_dir#$project_root/}"
            target="$project_root/$STATE_DIR/$relative"
            if [ ! -d "$target" ]; then
                mkdir -p "$target"
                echo -e "${GREEN}✓${NC} Created $STATE_DIR/$relative/"
            fi
        done
    done

    # 创建初始 state 文件（如果不存在）
    local state_path
    state_path=$(get_state_path "$project_root")
    if [ ! -f "$state_path" ]; then
        {
            echo "# translate-github state file"
            echo "# DO NOT EDIT MANUALLY"
        } > "$state_path"
        echo -e "${GREEN}✓${NC} Created $STATE_FILE"
    fi

    echo "READY"
}

# list: 列出所有可翻译文件
cmd_list() {
    local project_root="$1"
    shift
    local dirs=("$@")

    if [ ${#dirs[@]} -eq 0 ]; then
        echo -e "${RED}Error: At least one directory is required${NC}" >&2
        exit 1
    fi

    validate_git_repo "$project_root"
    validate_dirs "$project_root" "${dirs[@]}"

    local count=0
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            echo "FILE:$file"
            ((count++))
        fi
    done < <(find_translatable_files "$project_root" "${dirs[@]}")

    echo "---"
    echo "TOTAL=$count"
}

# diff: 检测需要翻译的变更文件
cmd_diff() {
    local project_root="$1"
    shift
    local dirs=("$@")

    if [ ${#dirs[@]} -eq 0 ]; then
        echo -e "${RED}Error: At least one directory is required${NC}" >&2
        exit 1
    fi

    validate_git_repo "$project_root"
    validate_dirs "$project_root" "${dirs[@]}"

    local state_path
    state_path=$(get_state_path "$project_root")
    local last_commit
    last_commit=$(read_last_commit "$state_path")

    local new_count=0
    local modified_count=0
    local deleted_count=0

    # 如果没有状态文件或没有 LAST_COMMIT，走全量模式
    if [ -z "$last_commit" ]; then
        while IFS= read -r file; do
            if [ -n "$file" ]; then
                echo "FILE:$file"
                ((new_count++))
            fi
        done < <(find_translatable_files "$project_root" "${dirs[@]}")
    else
        # 检查 LAST_COMMIT 是否可达
        if ! git -C "$project_root" cat-file -t "$last_commit" >/dev/null 2>&1; then
            echo "WARNING:COMMIT_UNREACHABLE"
            # 回退全量模式
            while IFS= read -r file; do
                if [ -n "$file" ]; then
                    echo "FILE:$file"
                    ((new_count++))
                fi
            done < <(find_translatable_files "$project_root" "${dirs[@]}")
        else
            # 读取已翻译的目录
            local state_dirs
            state_dirs=$(read_state_dirs "$state_path")

            for dir in "${dirs[@]}"; do
                # 检查该目录是否在已翻译目录中
                local is_known=false
                while IFS= read -r sd; do
                    if [ "$sd" = "$dir" ]; then
                        is_known=true
                        break
                    fi
                done <<< "$state_dirs"

                if [ "$is_known" = true ]; then
                    # 已知目录：走增量模式
                    # 获取变更的文件（新增 + 修改）
                    while IFS= read -r file; do
                        if [ -n "$file" ] && is_translatable_file "$file"; then
                            # 检查文件是否仍然存在
                            if [ -f "$project_root/$file" ]; then
                                echo "FILE:$file"
                                ((modified_count++))
                            fi
                        fi
                    done < <(git -C "$project_root" diff --name-only "$last_commit" HEAD -- "$dir" 2>/dev/null)

                    # 获取已删除的文件
                    while IFS= read -r file; do
                        if [ -n "$file" ] && is_translatable_file "$file"; then
                            echo "DELETED:$file"
                            ((deleted_count++))
                        fi
                    done < <(git -C "$project_root" diff --name-only --diff-filter=D "$last_commit" HEAD -- "$dir" 2>/dev/null)
                else
                    # 新增目录：走全量模式
                    while IFS= read -r file; do
                        if [ -n "$file" ]; then
                            echo "NEW_DIR:$file"
                            ((new_count++))
                        fi
                    done < <(find_translatable_files "$project_root" "$dir")
                fi
            done
        fi
    fi

    echo "---"
    echo "NEW=$new_count MODIFIED=$modified_count DELETED=$deleted_count"
}

# save: 保存翻译状态
cmd_save() {
    local project_root="$1"
    shift
    local dirs=("$@")

    if [ ${#dirs[@]} -eq 0 ]; then
        echo -e "${RED}Error: At least one directory is required${NC}" >&2
        exit 1
    fi

    validate_git_repo "$project_root"

    local state_path
    state_path=$(get_state_path "$project_root")
    local commit_hash
    commit_hash=$(git -C "$project_root" rev-parse HEAD 2>/dev/null)
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S" 2>/dev/null)

    # 写入 state 文件
    {
        echo "# translate-github state file"
        echo "# DO NOT EDIT MANUALLY"
        echo "LAST_COMMIT=$commit_hash"
        echo "LAST_RUN=$timestamp"
        for dir in "${dirs[@]}"; do
            echo "DIR=$dir"
        done
    } > "$state_path"

    echo -e "${GREEN}✓${NC} Saved state"
    echo "COMMIT=$commit_hash"
    echo "DIRS=$(IFS=,; echo "${dirs[*]}")"
    echo "TIME=$timestamp"
}

# status: 查看翻译状态
cmd_status() {
    local project_root="$1"

    validate_git_repo "$project_root"

    local state_path
    state_path=$(get_state_path "$project_root")

    if [ ! -f "$state_path" ]; then
        echo -e "${YELLOW}Status: Not initialized${NC}"
        echo "Run 'init' first to set up translation."
        return
    fi

    local last_commit
    last_commit=$(read_last_commit "$state_path")
    local last_run
    last_run=$(grep "^LAST_RUN=" "$state_path" 2>/dev/null | head -1 | cut -d'=' -f2)
    local state_dirs
    state_dirs=$(read_state_dirs "$state_path")

    echo "=== Translate GitHub Status ==="

    if [ -z "$last_commit" ]; then
        echo -e "Last commit: ${YELLOW}(none - not yet translated)${NC}"
    else
        echo "Last commit: $last_commit"
    fi

    if [ -n "$last_run" ]; then
        echo "Last run:    $last_run"
    fi

    if [ -n "$state_dirs" ]; then
        echo -n "Directories: "
        echo "$state_dirs" | tr '\n' ',' | sed 's/,$/\n/' | sed 's/,/, /g'
    fi

    # 如果有上次 commit，显示待翻译变更数量
    if [ -n "$last_commit" ]; then
        if git -C "$project_root" cat-file -t "$last_commit" >/dev/null 2>&1; then
            local pending=0
            while IFS= read -r sd; do
                if [ -n "$sd" ]; then
                    local count
                    count=$(git -C "$project_root" diff --name-only "$last_commit" HEAD -- "$sd" 2>/dev/null | grep -ciE "\.(${FILE_EXTENSIONS})$")
                    pending=$((pending + count))
                fi
            done <<< "$state_dirs"
            echo "Pending:     $pending files changed since last translation"
        else
            echo -e "Pending:     ${RED}Last commit unreachable (force push?)${NC}"
        fi
    fi
}

# ===================== 主入口 =====================

COMMAND="${1:-}"
PROJECT_ROOT="${2:-}"

if [ -z "$COMMAND" ]; then
    usage
fi

if [ -z "$PROJECT_ROOT" ] && [ "$COMMAND" != "help" ]; then
    echo -e "${RED}Error: Project root is required${NC}" >&2
    usage
fi

# 转换为绝对路径
if [ -n "$PROJECT_ROOT" ]; then
    PROJECT_ROOT=$(cd "$PROJECT_ROOT" 2>/dev/null && pwd)
    if [ -z "$PROJECT_ROOT" ]; then
        echo -e "${RED}Error: Cannot access project root directory${NC}" >&2
        exit 1
    fi
fi

# 提取目录参数（第3个参数开始）
shift 2 2>/dev/null
DIRS=("$@")

case "$COMMAND" in
    init)
        cmd_init "$PROJECT_ROOT" "${DIRS[@]}"
        ;;
    list)
        cmd_list "$PROJECT_ROOT" "${DIRS[@]}"
        ;;
    diff)
        cmd_diff "$PROJECT_ROOT" "${DIRS[@]}"
        ;;
    save)
        cmd_save "$PROJECT_ROOT" "${DIRS[@]}"
        ;;
    status)
        cmd_status "$PROJECT_ROOT"
        ;;
    help)
        usage
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$COMMAND'${NC}" >&2
        usage
        ;;
esac
