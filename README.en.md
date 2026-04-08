# AIGC-Killer-Pro

<p align="center">
  <strong>Academic Paper AIGC Detection | AI Rate Reduction | Writing Assistant</strong>
</p>

<p align="center">
  <a href="https://github.com/free-revalution/AIGC-Killer-Pro/stargazers"><img src="https://img.shields.io/github/stars/free-revalution/AIGC-Killer-Pro?style=social" alt="Stars"></a>
  <a href="https://github.com/free-revalution/AIGC-Killer-Pro/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
  <a href="https://github.com/free-revalution/AIGC-Killer-Pro/releases"><img src="https://img.shields.io/github/stars/free-revalution/AIGC-Killer-Pro?style=social" alt="Stars"></a>
</p>

<p align="center">
  <a href="README.md">简体中文</a> | English
</p>
---

> A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) Skill for academic paper AI content (AIGC) detection and rewriting. Analyzes papers across 5 dimensions for AI-generated characteristics, provides targeted rewrite guidance, and helps reduce AIGC detection rates.

**One-line install, ready to use:**

```bash
curl -sL https://raw.githubusercontent.com/free-revalution/AIGC-Killer-Pro/main/install.sh | bash
```

> Requires [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and Python 3.8+

## Why This Project?

By 2026, mainstream AIGC detection platforms have undergone comprehensive upgrades, significantly improving AI content identification accuracy. Simple synonym replacement no longer bypasses detection — restructuring at the semantic level is required.

AIGC-Killer-Pro leverages Claude's deep semantic understanding to precisely identify AI-generated patterns in academic papers and provide scientifically-grounded rewriting guidance.

## Features

- **5-Dimension Deep Analysis** — Sentence regularity, connector density, voice characteristics, vocabulary diversity, argumentation depth
- **Pure Semantic-Driven** — No keyword matching; powered by Claude's deep semantic understanding
- **Discipline-Adaptive** — Specialized thresholds for humanities, STEM, medicine, and business
- **.docx Support** — Directly reads Word documents; outputs rewritten .docx while preserving formatting
- **Bilingual** — Supports both Chinese and English academic papers
- **One-Line Install** — Single command setup
- **Multi-Agent Compatible** — Works with Claude Code, Codex, Cursor, Windsurf, Gemini CLI, GitHub Copilot

## Installation

```bash
curl -sL https://raw.githubusercontent.com/free-revalution/AIGC-Killer-Pro/main/install.sh | bash
```

The installer automatically:
1. Downloads Skill files to `~/.aigc-killer/aigc-detector/`
2. Checks and installs the `python-docx` dependency

## Multi-Agent Support

AIGC-Detector is compatible with multiple AI agents:

| Agent | Compatibility | Install Command |
|-------|:------------:|----------------|
| Claude Code | Full | `curl -sL ... \| bash` (default) |
| Codex CLI | Partial | `curl -sL ... \| bash -s -- --agent codex` |
| Cursor | Partial | `curl -sL ... \| bash -s -- --agent cursor --dir /your/project` |
| Windsurf | Partial | `curl -sL ... \| bash -s -- --agent windsurf --dir /your/project` |
| Gemini CLI | Partial | `curl -sL ... \| bash -s -- --agent gemini --dir /your/project` |
| All Agents | — | `curl -sL ... \| bash -s -- --agent all` |

> **Compatibility notes:**
> - **Full support**: Intent-based skill triggering, complete multi-step workflow execution, interactive user choice
> - **Partial support**: Instructions injected as context; agents can execute bash/Python/file operations, but step adherence is best-effort (not guaranteed in strict order), no precise trigger mechanism
>
> GitHub Copilot is not supported (cannot execute shell commands or file I/O required by this workflow)

Uninstall:

```bash
curl -sL https://raw.githubusercontent.com/free-revalution/AIGC-Killer-Pro/main/uninstall.sh | bash
```

## Usage

After installation, trigger the Skill through natural conversation in your agent:

### Detect AIGC in a Paper

```
Analyze this paper for AI-generated content: /path/to/thesis.docx
```

```
Detect AI rate in this paper
(paste paper text)
```

### Rewrite Paper to Reduce AI Rate

```
Help me rewrite this paper to reduce AI detection rate: /path/to/thesis.docx
```

## Workflow

```
User provides paper (.docx or pasted text)
        │
        ▼
  Step 0: Language Detection
  (Auto-detect Chinese / English)
        │
        ▼
  Step 1: Read Document
        │
        ▼
  Step 2: 5-Dimension Semantic Analysis
  ├─ Sentence Regularity   (25%)
  ├─ Connector Density     (20%)
  ├─ Voice Characteristics (15%)
  ├─ Vocabulary Diversity  (15%)
  └─ Argumentation Depth   (25%)
        │
        ▼
  Step 3: Output Detection Report
  (Terminal + optional Markdown file)
        │
        ▼
  Step 4: Offer Next Steps
  (Save report / Rewrite / View suggestions)
        │
        ▼
  Step 5: Rewrite & Export Document
  (Backup original → Rewrite → New .docx)
```

### Detection Report Sample

```
# AIGC Detection Report

## Overall Assessment
- AIGC Risk Score: 67% [High Risk]

## Dimension Scores
| Dimension             | Score | Status     |
|-----------------------|-------|------------|
| Sentence Regularity   | 82    | High Risk  |
| Connector Density     | 75    | High Risk  |
| Voice Characteristics | 58    | Medium Risk|
| Vocabulary Diversity  | 45    | Medium Risk|
| Argumentation Depth   | 70    | High Risk  |

## Paragraph-Level Analysis
### Paragraph 3 [High Risk]
- Original: "Firstly, this paper analyzes... Secondly, it explores... In conclusion..."
- Key issues: Template sentence patterns, "Firstly/Secondly/In conclusion" structure
- Suggestion: Break three-part structure, use progressive narrative instead
```

## Rewrite Techniques

The Skill includes 7 rewrite techniques designed based on mainstream AIGC detection principles (perplexity, burstiness, classifiers, probability curvature):

| Technique | Detection Method | Core Strategy |
|-----------|-----------------|---------------|
| Sentence Variation | Burstiness Detection | Merge short sentences, vary length, switch voice |
| Replace Template Transitions | Pattern Matching | Remove "Firstly/Secondly/Finally" AI templates |
| Active Voice Priority | Syntactic Analysis | Add explicit agents to agentless sentences |
| Concrete Language | Semantic Coherence | Abstract claims → specific data/cases |
| Counterargument Addition | Semantic Coherence | Linear argument → multi-dimensional evidence |
| Controlled Informality | Perplexity Detection | Use unconventional but accurate expressions |
| Register Variation | Classifier Detection | Vary expression style across paragraphs |

## Project Structure

```
AIGC-Killer-Pro/
├── .claude/skills/aigc-detector/      # Core content
│   ├── SKILL.md                        # Skill main entry
│   ├── scripts/
│   │   └── docx_io.py                  # Word document I/O script
│   └── references/
│       ├── detection_principles.md     # AIGC detection principles knowledge base
│       └── rewrite_methods.md          # Rewrite techniques detailed guide
├── agents/                             # Agent entry pointer templates
│   ├── codex.md                        # Codex CLI template
│   ├── cursor.mdc                      # Cursor template
│   ├── windsurf.md                     # Windsurf template
│   └── gemini.md                       # Gemini CLI template
├── install.sh                          # One-line installer (multi-agent support)
├── uninstall.sh                        # Uninstaller
├── README.md                           # Chinese documentation
├── README.en.md                        # English documentation
├── LICENSE
└── .gitignore
```

## Notes

- Detection results are for reference only; defer to official platform results for final judgment
- Rewriting maintains academic rigor — no fabricated data or citations
- Recommended: "Human revision + tool assistance" combined strategy
- Supports both Chinese and English academic papers

## Contributing

Issues and Pull Requests are welcome!

## License

[MIT](LICENSE)

---

<p align="center">
  If you find this useful, please give it a <a href="https://github.com/free-revalution/AIGC-Killer-Pro">Star</a>
</p>
