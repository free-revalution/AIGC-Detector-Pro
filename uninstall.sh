#!/usr/bin/env bash
# AIGC-Detector Skill Uninstaller
# Usage: curl -sL https://raw.githubusercontent.com/free-revalution/AIGC-Killer-Pro/main/uninstall.sh | bash -s -- [OPTIONS]

set -e

SKILL_DIR="$HOME/.claude/skills/aigc-detector"
DIR="."

while [[ $# -gt 0 ]]; do
    case $1 in
        --dir) DIR="$2"; shift 2 ;;
        *) shift ;;
    esac
done

MARKER_START="<!-- AIGC-Detector-Start -->"
MARKER_END="<!-- AIGC-Detector-End -->"

echo "==> 正在卸载 AIGC-Detector Skill..."

# Remove core content
if [ -d "$SKILL_DIR" ]; then
    rm -rf "$SKILL_DIR"
    echo "    已删除 $SKILL_DIR"
else
    echo "    核心内容不存在 $SKILL_DIR（已删除或未安装）"
fi

# Remove marker-wrapped content from agent files
remove_markers() {
    local filepath="$1"
    if [ -f "$filepath" ] && grep -q "$MARKER_START" "$filepath"; then
        local tmpfile
        tmpfile=$(mktemp)
        awk -v start="$MARKER_START" -v end="$MARKER_END" '
            $0 == start { skip = 1; next }
            $0 == end { skip = 0; next }
            !skip { print }
        ' "$filepath" > "$tmpfile"
        mv "$tmpfile" "$filepath"
        # Remove file if empty or only whitespace
        if [ ! -s "$filepath" ] || [ "$(tr -d '[:space:]' < "$filepath")" = "" ]; then
            rm -f "$filepath"
            echo "    已删除 $filepath（空文件）"
        else
            echo "    已清理 $filepath 中的 AIGC-Detector 内容"
        fi
    fi
}

remove_markers "$HOME/.codex/AGENTS.md"
remove_markers "$DIR/.cursor/rules/aigc-detector.mdc"
remove_markers "$DIR/.windsurfrules"
remove_markers "$DIR/GEMINI.md"
remove_markers "$DIR/.github/copilot-instructions.md"

# Remove empty parent directories
rmdir "$HOME/.codex" 2>/dev/null && echo "    已删除 $HOME/.codex/" || true
rmdir "$DIR/.cursor/rules" 2>/dev/null && echo "    已删除 $DIR/.cursor/rules/" || true
rmdir "$DIR/.cursor" 2>/dev/null && echo "    已删除 $DIR/.cursor/" || true
rmdir "$DIR/.github" 2>/dev/null && echo "    已删除 $DIR/.github/" || true

echo "==> 卸载完成!"
