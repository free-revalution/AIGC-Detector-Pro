# Gemini CLI Entry Template

## Location
`{project}/GEMINI.md`

## Format
Standard Markdown, append mode (marker-based)

## Content
# AIGC-Detector Skill

<!-- AIGC-Detector-Start -->
[Full SKILL.md content here]
<!-- AIGC-Detector-End -->

## Notes
- Gemini CLI reads GEMINI.md from project root automatically
- Supports hierarchical loading (multiple directory levels)
- Append mode preserves any existing instructions
- Install command: `curl -sL ... | bash -s -- --agent gemini --dir /your/project`
