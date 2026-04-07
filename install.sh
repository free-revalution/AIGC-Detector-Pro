#!/usr/bin/env bash
# AIGC-Detector Skill 一键安装脚本
# 用法: curl -sL https://raw.githubusercontent.com/free-revalution/AIGC-Killer-Pro/main/install.sh | bash

set -e

SKILL_NAME="aigc-detector"
INSTALL_DIR="$HOME/.claude/skills/$SKILL_NAME"
REPO_URL="https://raw.githubusercontent.com/free-revalution/AIGC-Killer-Pro/main/.claude/skills/$SKILL_NAME"

echo "==> 正在安装 AIGC-Detector Skill..."

# 创建目录
mkdir -p "$INSTALL_DIR/scripts" "$INSTALL_DIR/references"

# 下载文件
curl -fsSL "$REPO_URL/SKILL.md" -o "$INSTALL_DIR/SKILL.md"
curl -fsSL "$REPO_URL/scripts/docx_io.py" -o "$INSTALL_DIR/scripts/docx_io.py"
curl -fsSL "$REPO_URL/references/detection_principles.md" -o "$INSTALL_DIR/references/detection_principles.md"
curl -fsSL "$REPO_URL/references/rewrite_methods.md" -o "$INSTALL_DIR/references/rewrite_methods.md"

# 检查 python-docx
echo "==> 检查 python-docx 依赖..."
if ! python3 -c "import docx" 2>/dev/null; then
    echo "==> 正在安装 python-docx..."
    pip3 install python-docx -q
fi

echo "==> 安装完成! Skill 已安装到 $INSTALL_DIR"
echo "    使用方式: 在 Claude Code 中说「分析这篇论文的AIGC特征：/path/to/thesis.docx」"
