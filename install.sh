#!/usr/bin/env bash
# AIGC-Detector Skill Installer
# Supports: Claude Code, Codex, Cursor, Windsurf, Gemini CLI, GitHub Copilot
# Usage: curl -sL https://raw.githubusercontent.com/free-revalution/AIGC-Killer-Pro/main/install.sh | bash -s -- [OPTIONS]

set -e

SKILL_NAME="aigc-detector"
INSTALL_DIR="$HOME/.claude/skills/$SKILL_NAME"
REPO_URL="https://raw.githubusercontent.com/free-revalution/AIGC-Killer-Pro/main/.claude/skills/$SKILL_NAME"

# Defaults
AGENT="claude"
DIR="."

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --agent) AGENT="$2"; shift 2 ;;
        --dir) DIR="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

MARKER_START="<!-- AIGC-Detector-Start -->"
MARKER_END="<!-- AIGC-Detector-End -->"

echo "==> 正在安装 AIGC-Detector Skill..."

# --- Step 1: Download core content (always) ---
mkdir -p "$INSTALL_DIR/scripts" "$INSTALL_DIR/references"

echo "==> 下载核心内容..."
curl -fsSL "$REPO_URL/SKILL.md" -o "$INSTALL_DIR/SKILL.md"
curl -fsSL "$REPO_URL/scripts/docx_io.py" -o "$INSTALL_DIR/scripts/docx_io.py"
curl -fsSL "$REPO_URL/references/detection_principles.md" -o "$INSTALL_DIR/references/detection_principles.md"
curl -fsSL "$REPO_URL/references/rewrite_methods.md" -o "$INSTALL_DIR/references/rewrite_methods.md"

# --- Step 2: Check python-docx ---
echo "==> 检查 python-docx 依赖..."
if ! python3 -c "import docx" 2>/dev/null; then
    echo "==> 正在安装 python-docx..."
    pip3 install python-docx -q
fi

# --- Step 3: Generate agent entry pointers ---
SKILL_CONTENT=$(cat "$INSTALL_DIR/SKILL.md")

# Append mode: insert between markers, or append if markers don't exist
append_entry() {
    local filepath="$1"
    local content="$2"
    local dirpath
    dirpath=$(dirname "$filepath")
    mkdir -p "$dirpath"

    if [ -f "$filepath" ] && grep -q "$MARKER_START" "$filepath"; then
        # Upgrade: replace between markers using temp file
        local tmpfile
        tmpfile=$(mktemp)
        awk -v start="$MARKER_START" -v end="$MARKER_END" -v new="$content" '
            BEGIN { printing = 1; found = 0 }
            $0 == start { printing = 0; found = 1; print; print new; next }
            $0 == end { printing = 1; print; next }
            printing { print }
        ' "$filepath" > "$tmpfile"
        mv "$tmpfile" "$filepath"
    else
        # Fresh install: append
        {
            echo ""
            echo "$MARKER_START"
            echo "$content"
            echo "$MARKER_END"
        } >> "$filepath"
    fi
    echo "    -> $filepath"
}

# File mode: overwrite entirely
file_entry() {
    local filepath="$1"
    local content="$2"
    local dirpath
    dirpath=$(dirname "$filepath")
    mkdir -p "$dirpath"
    printf '%s\n' "$content" > "$filepath"
    echo "    -> $filepath"
}

install_codex() {
    echo "==> 配置 Codex CLI..."
    append_entry "$HOME/.codex/AGENTS.md" "$SKILL_CONTENT"
}

install_cursor() {
    echo "==> 配置 Cursor..."
    local mdc_content
    mdc_content="---
description: AIGC detection and rewriting assistant for academic papers. Analyzes text for AI-generated characteristics, provides detailed rewrite suggestions. Supports .docx files, outputs reports and rewritten documents. Bilingual: Chinese & English.
globs: *.md, *.docx, *.txt
alwaysApply: false
---

$MARKER_START
$SKILL_CONTENT
$MARKER_END"
    file_entry "$DIR/.cursor/rules/aigc-detector.mdc" "$mdc_content"
}

install_windsurf() {
    echo "==> 配置 Windsurf..."
    local content="# AIGC-Detector Skill
# When user asks to analyze/rewrite academic papers, follow these instructions:

$SKILL_CONTENT"
    append_entry "$DIR/.windsurfrules" "$content"
}

install_gemini() {
    echo "==> 配置 Gemini CLI..."
    local content="# AIGC-Detector Skill

$SKILL_CONTENT"
    append_entry "$DIR/GEMINI.md" "$content"
}

install_copilot() {
    echo "==> 配置 GitHub Copilot..."
    local content="# AIGC-Detector Skill

$SKILL_CONTENT"
    append_entry "$DIR/.github/copilot-instructions.md" "$content"
}

# Dispatch
case "$AGENT" in
    claude)
        echo "==> Claude Code: Skill 已安装到 $INSTALL_DIR（自动识别）"
        ;;
    codex)   install_codex ;;
    cursor)  install_cursor ;;
    windsurf) install_windsurf ;;
    gemini)  install_gemini ;;
    copilot) install_copilot ;;
    all)
        echo "==> Claude Code: Skill 已安装到 $INSTALL_DIR（自动识别）"
        install_codex
        install_cursor
        install_windsurf
        install_gemini
        install_copilot
        ;;
    *)
        echo "错误: 未知的 Agent '$AGENT'"
        echo "支持的 Agent: claude, codex, cursor, windsurf, gemini, copilot, all"
        exit 1
        ;;
esac

echo ""
echo "==> 安装完成!"
echo "    核心内容: $INSTALL_DIR"
echo "    Agent: $AGENT"
