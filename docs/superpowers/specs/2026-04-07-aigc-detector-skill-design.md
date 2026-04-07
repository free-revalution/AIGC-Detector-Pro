# AIGC-Detector Skill Design Spec

## Overview

A Claude Code global Skill that analyzes academic papers for AI-generated content (AIGC) characteristics and provides rewriting suggestions to reduce detection rates on CNKI (知网) and similar platforms.

## Architecture

Pure Prompt-driven approach. Claude performs all text analysis; no statistical detection engine. A minimal Python script handles .docx file I/O only.

### File Structure

```
~/.claude/skills/aigc-detector/
├── SKILL.md                      # Main entry: workflow + core prompts
├── scripts/
│   └── docx_io.py                # docx read/write (~60 lines)
└── references/
    ├── detection_principles.md   # CNKI detection principles knowledge base
    └── rewrite_methods.md        # 5 rewrite techniques + discipline-specific tips
```

## Installation

Global Skill at `~/.claude/skills/aigc-detector/`. Available across all projects.

## Workflow

5-step pipeline triggered when user requests AIGC analysis:

### Step 1: Document Input

- If user provides a `.docx` path, run `python scripts/docx_io.py read <file>` to extract plain text
- If user pastes text directly, analyze as-is
- Split text by paragraphs, preserving paragraph index

### Step 2: Semantic Analysis

Claude evaluates text across 5 dimensions (no Python computation needed):

| Dimension | What to Detect |
|-----------|---------------|
| Sentence regularity | Template patterns (首先/其次/综上所述), uniform sentence length |
| Connector density | Abnormal frequency of logical connectors |
| Voice characteristics | Passive voice overuse, subjectless sentences |
| Vocabulary diversity | Repetitive word usage, abstract concept density |
| Argumentation depth | Lack of specific data, cases, personal viewpoints |

### Step 3: Report Output

Terminal report containing:
- Overall AIGC risk score (0-100%)
- Per-paragraph risk level: high / medium / low
- Per-dimension scores
- High-risk paragraph list with specific characteristic explanations

Option: save report as Markdown file.

### Step 4: Rewrite Suggestions

For each high-risk paragraph, provide specific rewrite methods based on 5 techniques:
1. Sentence restructuring (long-short alternation, voice conversion)
2. Breaking template expressions (remove 首先/其次/最后 patterns)
3. Adding subjects (fix subjectless sentences)
4. Concept concretization (abstract → specific with data/cases)
5. Argumentation completion (linear → multi-evidence reasoning)

Reference `references/rewrite_methods.md` for detailed technique guides.

### Step 5: Rewritten Output (optional)

If user confirms:
1. Save original document copy (e.g., `thesis_backup.docx`)
2. Rewrite high-risk paragraphs using Claude
3. Output new .docx file via `python scripts/docx_io.py write <file>`

## docx_io.py Interface

Minimal script with two subcommands:

```bash
# Read: extract text from .docx to stdout
python scripts/docx_io.py read input.docx

# Write: read text from stdin, write to .docx
python scripts/docx_io.py write output.docx < rewritten.txt
```

Dependencies: `python-docx` only.

## Trigger Conditions

Skill activates when user messages contain:
- "AIGC检测" / "AIGC分析" / "AI检测"
- "降AI率" / "降低AI率" / "降低AI检测"
- "论文改写" (in context of AIGC)
- "检测论文" / "分析论文"
- File path ending in `.docx` combined with analysis keywords

## Scoring System

- Overall risk score: 0-100%
- Paragraph-level: high risk (>60%), medium risk (30-60%), low risk (<30%)
- Each dimension scored individually
- Discipline-aware thresholds: liberal arts tolerate higher passive voice, STEM requires higher terminology density

## Constraints

1. Detection results are for reference only; official CNKI results take precedence
2. Rewriting must maintain academic rigor — never sacrifice accuracy for lower AI scores
3. Recommend "manual revision + tool assistance" combined strategy
4. Preserve 10-15% non-standardized expression (natural human writing characteristic)

## Out of Scope

- No external API calls (GPTZero, PaperPass, etc.)
- No batch document processing
- No version tracking of revision history
- No real-time collaborative editing
