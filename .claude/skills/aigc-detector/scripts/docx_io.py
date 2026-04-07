#!/usr/bin/env python3
"""Minimal docx I/O for AIGC-Detector Skill."""

import sys
import os


def read_docx(file_path: str) -> str:
    """Extract plain text from a .docx file."""
    from docx import Document
    doc = Document(file_path)
    paragraphs = []
    for para in doc.paragraphs:
        if para.text.strip():
            paragraphs.append(para.text.strip())
    return "\n\n".join(paragraphs)


def write_docx(file_path: str, text: str) -> None:
    """Write plain text to a .docx file."""
    from docx import Document
    from docx.shared import Pt
    doc = Document()
    paragraphs = text.split("\n\n")
    for para_text in paragraphs:
        if para_text.strip():
            p = doc.add_paragraph(para_text.strip())
            for run in p.runs:
                run.font.size = Pt(12)
                run.font.name = "宋体"
    doc.save(file_path)


def main():
    if len(sys.argv) < 3:
        print("Usage: python docx_io.py <read|write> <file_path>", file=sys.stderr)
        sys.exit(1)

    command = sys.argv[1]
    file_path = sys.argv[2]

    if command == "read":
        if not os.path.exists(file_path):
            print(f"Error: file not found: {file_path}", file=sys.stderr)
            sys.exit(1)
        text = read_docx(file_path)
        print(text)
    elif command == "write":
        text = sys.stdin.read()
        write_docx(file_path, text)
        print(f"Written to: {file_path}", file=sys.stderr)
    else:
        print(f"Error: unknown command '{command}'. Use 'read' or 'write'.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
