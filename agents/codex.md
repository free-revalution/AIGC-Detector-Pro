# Codex CLI Entry Template

## Location
`~/.codex/AGENTS.md`

## Format
Standard Markdown, append mode (marker-based)

## Content
The full content of `SKILL.md` is embedded between markers:

<!-- AIGC-Detector-Start -->
[Full SKILL.md content here]
<!-- AIGC-Detector-End -->

## Notes
- Codex reads AGENTS.md automatically from home directory
- File is created if it doesn't exist, updated if markers already present
- Install command: `curl -sL ... | bash -s -- --agent codex`
