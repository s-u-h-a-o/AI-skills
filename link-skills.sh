#!/usr/bin/env bash
# link-skills.sh — 将分类目录下的所有 skill 平铺 symlink 到 AI 工具目录
#
# 用法：
#   bash link-skills.sh          # 自动检测可用工具
#   bash link-skills.sh claude   # 仅链接 Claude Code
#   bash link-skills.sh cursor   # 仅链接 Cursor
#   bash link-skills.sh codex    # 仅链接 Codex / Copilot CLI

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 工具 → 目标目录映射
declare -A TOOL_DIRS=(
  ["claude"]=".claude"
  ["cursor"]=".cursor"
  ["codex"]=".codex"
)

link_for_tool() {
  local tool="$1"
  local target_dir="${TOOL_DIRS[$tool]}"

  if [ ! -d "$SCRIPT_DIR" ]; then
    echo "❌ 未找到 skills 目录: $SCRIPT_DIR"
    exit 1
  fi

  echo "🔗 为 $tool 创建 symlink → $target_dir/skills/"
  mkdir -p "$target_dir"

  local count=0
  for category in "$SCRIPT_DIR"/*/; do
    [ -d "$category" ] || continue
    for skill in "$category"*/; do
      [ -d "$skill" ] || continue
      local skill_name
      skill_name="$(basename "$skill")"
      local link_path="$target_dir/skills/$skill_name"

      # 计算相对路径
      local rel_path
      rel_path=$(realpath --relative-to="$target_dir/skills" "$skill" 2>/dev/null || python3 -c "import os, sys; print(os.path.relpath('$skill', '$target_dir/skills'))" 2>/dev/null)

      if [ -L "$link_path" ] || [ ! -e "$link_path" ]; then
        ln -sfn "$rel_path" "$link_path"
        echo "  ✓ $skill_name"
        ((count++)) || true
      else
        echo "  ⚠ $skill_name 已存在且非 symlink，跳过"
      fi
    done
  done

  echo "✅ 已链接 $count 个 skill 到 $target_dir/skills/"
}

# 解析参数
if [ $# -ge 1 ]; then
  if [ -n "${TOOL_DIRS[$1]:-}" ]; then
    link_for_tool "$1"
  else
    echo "❌ 未知工具: $1，支持: ${!TOOL_DIRS[*]}"
    exit 1
  fi
else
  # 自动检测已安装的工具
  found=0
  for tool in "${!TOOL_DIRS[@]}"; do
    if command -v "$tool" &>/dev/null || [ -n "${TOOL_DIRS[$tool]:-}" ]; then
      link_for_tool "$tool"
      ((found++)) || true
    fi
  done
  # 如果都没检测到，默认链接所有三个
  if [ "$found" -eq 0 ]; then
    echo "📦 未检测到已安装工具，默认创建所有 symlink"
    for tool in "${!TOOL_DIRS[@]}"; do
      link_for_tool "$tool"
    done
  fi
fi
