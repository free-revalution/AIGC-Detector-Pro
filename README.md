# AIGC-Killer-Pro

<p align="center">
  <strong>论文 AIGC 检测 | AI 降率 | 学术写作助手</strong>
</p>

<p align="center">
  <a href="https://github.com/free-revalution/AIGC-Killer-Pro/stargazers"><img src="https://img.shields.io/github/stars/free-revalution/AIGC-Killer-Pro?style=social" alt="Stars"></a>
  <a href="https://github.com/free-revalution/AIGC-Killer-Pro/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
  <a href="https://github.com/free-revalution/AIGC-Killer-Pro/releases"><img src="https://img.shields.io/badge/version-1.0.0-green.svg" alt="Version"></a>
</p>

---

> 基于 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 的学术论文 AIGC 检测与改写 Skill。从 5 个维度深度分析论文的 AI 生成特征，提供针对性改写建议，帮助降低 AIGC 检测率。

**一句话安装，开箱即用：**

```bash
curl -sL https://raw.githubusercontent.com/free-revalution/AIGC-Killer-Pro/main/install.sh | bash
```

> 需要提前安装 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 和 Python 3.8+

## 为什么做这个？

2026 年主流 AIGC 检测平台已全面升级，AI 内容识别准确率大幅提升。单纯同义词替换已无法通过检测，必须在语义结构层面进行重构。

AIGC-Killer-Pro 利用 Claude 的深层语义理解能力，精准识别论文中的 AI 生成痕迹，并提供科学的改写指导。

## 特性

- **5 维度深度分析** — 句式规整度、逻辑词密度、语态特征、词汇多样性、论证深度
- **纯语义驱动** — 不依赖关键词匹配，由 Claude 进行深层语义理解分析
- **学科自适应** — 支持文科、理工科、医学、经管等学科特化阈值
- **.docx 支持** — 直接读取 Word 文档，改写后输出新 .docx（自动保留原始副本）
- **一键安装** — 一条命令完成安装

## 安装

```bash
curl -sL https://raw.githubusercontent.com/free-revalution/AIGC-Killer-Pro/main/install.sh | bash
```

安装脚本会自动完成：
1. 下载 Skill 文件到 `~/.claude/skills/aigc-detector/`
2. 检查并安装 `python-docx` 依赖

卸载：

```bash
rm -rf ~/.claude/skills/aigc-detector/
```

## 多 Agent 支持

AIGC-Detector 适配多种 AI Agent，一条命令即可安装：

| Agent | 安装命令 |
|-------|---------|
| Claude Code | `curl -sL ... \| bash`（默认） |
| Codex CLI | `curl -sL ... \| bash -s -- --agent codex` |
| Cursor | `curl -sL ... \| bash -s -- --agent cursor --dir /your/project` |
| Windsurf | `curl -sL ... \| bash -s -- --agent windsurf --dir /your/project` |
| Gemini CLI | `curl -sL ... \| bash -s -- --agent gemini --dir /your/project` |
| GitHub Copilot | `curl -sL ... \| bash -s -- --agent copilot --dir /your/project` |
| 全部安装 | `curl -sL ... \| bash -s -- --agent all` |

> 核心内容统一安装在 `~/.claude/skills/aigc-detector/`，各 Agent 通过入口指针文件引用。升级时重新运行安装命令即可。

卸载：

```bash
curl -sL https://raw.githubusercontent.com/free-revalution/AIGC-Killer-Pro/main/uninstall.sh | bash
```

## 使用方式

安装完成后，在 Claude Code 中直接对话即可触发 Skill：

### 检测论文 AIGC 特征

```
分析这篇论文的AIGC特征：/path/to/thesis.docx
```

```
检测这篇论文的AI率
（然后粘贴论文文本）
```

### 改写论文降低 AI 率

```
帮我改写这篇论文降低AI率：/path/to/thesis.docx
```

## 工作流程

```
用户提供论文 (.docx 或粘贴文本)
        │
        ▼
  Step 1: 读取文档
        │
        ▼
  Step 2: 5 维度语义分析
  ├─ 句式规整度 (25%)
  ├─ 逻辑词密度 (20%)
  ├─ 语态特征   (15%)
  ├─ 词汇多样性 (15%)
  └─ 论证深度   (25%)
        │
        ▼
  Step 3: 输出检测报告
  (终端 + 可选 Markdown 文件)
        │
        ▼
  Step 4: 提供改写建议
  (逐段标注 + 改写示例)
        │
        ▼
  Step 5: 改写并输出文档
  (保留原始副本 → 改写 → 新 .docx)
```

### 检测报告示例

```
# AIGC检测报告

## 整体评估
- AIGC风险评分：67% [高风险]

## 维度评分
| 维度       | 评分   | 状态   |
|------------|--------|--------|
| 句式规整度 | 82分   | 高风险 |
| 逻辑词密度 | 75分   | 高风险 |
| 语态特征   | 58分   | 中风险 |
| 词汇多样性 | 45分   | 中风险 |
| 论证深度   | 70分   | 高风险 |

## 段落级分析
### 第3段 [高风险]
- 原文：「首先，本文分析了...其次，本文探讨了...综上所述...」
- 主要问题：模板化句式、"首先/其次/综上所述"模式
- 改写建议：打破三段式结构，改用递进关系叙述
```

## 改写技法

Skill 内置 7 大改写技法，基于学术界主流 AIGC 检测原理（困惑度、突发性、分类器、概率曲率）设计：

| 技法 | 对应检测方法 | 核心思路 |
|------|------------|---------|
| 句式重构 | 突发性检测 (Burstiness) | 合并短句、长短交替、语态转换 |
| 破解模板 | 模式匹配 | 删除"首先/其次/最后"等 AI 模板 |
| 添加主语 | 句法分析 | 为无主句补充行为主体 |
| 概念具象 | 语义一致性 | 抽象表述 → 具体数据/案例 |
| 论证补全 | 语义一致性 | 线性论证 → 多维证据 + 对比研究 |
| 困惑度提升 | 困惑度检测 (Perplexity) | 使用非常规但准确的学术表达 |
| 风格断裂 | 分类器检测 | 段落间切换表达风格，打破一致性 |

## 项目结构

```
AIGC-Killer-Pro/
├── .claude/skills/aigc-detector/      # 核心内容
│   ├── SKILL.md                        # Skill 主入口
│   ├── scripts/
│   │   └── docx_io.py                  # Word 文档读写脚本
│   └── references/
│       ├── detection_principles.md     # AIGC 检测原理知识库
│       └── rewrite_methods.md          # 改写技法详细指南
├── agents/                             # 各 Agent 入口指针模板
│   ├── codex.md                        # Codex CLI 模板
│   ├── cursor.mdc                      # Cursor 模板
│   ├── windsurf.md                     # Windsurf 模板
│   ├── gemini.md                       # Gemini CLI 模板
│   └── copilot.md                      # GitHub Copilot 模板
├── install.sh                          # 一键安装脚本（支持多 Agent）
├── uninstall.sh                        # 卸载脚本
├── README.md
├── LICENSE
└── .gitignore
```

## 注意事项

- 检测结果仅供参考，最终判断以各平台官方检测结果为准
- 改写时会保持学术严谨性，不会编造虚假数据或文献
- 建议采用"人工修改 + 工具辅助"的组合策略
- 适用于中文和英文学术论文

## 贡献

欢迎提交 Issue 和 Pull Request！

## License

[MIT](LICENSE)

---

<p align="center">
  如果觉得有用，请给一个 <a href="https://github.com/free-revalution/AIGC-Killer-Pro">Star</a> 支持一下
</p>
