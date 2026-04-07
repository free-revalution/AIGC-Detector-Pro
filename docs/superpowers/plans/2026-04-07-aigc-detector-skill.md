# AIGC-Detector Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Claude Code global Skill that analyzes academic papers for AIGC characteristics and provides rewriting suggestions to reduce CNKI detection rates.

**Architecture:** Pure Prompt-driven Skill. Claude performs all text analysis via SKILL.md instructions. A minimal Python script (`docx_io.py`) handles .docx file I/O. Reference files provide knowledge bases for detection principles and rewrite techniques.

**Tech Stack:** Claude Code Skill (SKILL.md + references), Python 3.9+ with python-docx

---

### Task 1: Create Directory Structure and Install Dependency

**Files:**
- Create: `~/.claude/skills/aigc-detector/` (directory)
- Create: `~/.claude/skills/aigc-detector/scripts/` (directory)
- Create: `~/.claude/skills/aigc-detector/references/` (directory)

- [ ] **Step 1: Create skill directory structure**

```bash
mkdir -p ~/.claude/skills/aigc-detector/{scripts,references}
```

- [ ] **Step 2: Install python-docx**

```bash
pip3 install python-docx
```

- [ ] **Step 3: Verify installation**

```bash
python3 -c "import docx; print('OK:', docx.__version__)"
```

Expected: `OK: 1.x.x`

- [ ] **Step 4: Verify directory structure**

```bash
ls -R ~/.claude/skills/aigc-detector/
```

Expected:
```
~/.claude/skills/aigc-detector/:
references/ scripts/

~/.claude/skills/aigc-detector/references:
(empty)

~/.claude/skills/aigc-detector/scripts:
(empty)
```

---

### Task 2: Write docx_io.py Script

**Files:**
- Create: `~/.claude/skills/aigc-detector/scripts/docx_io.py`

- [ ] **Step 1: Write the docx_io.py script**

Create `~/.claude/skills/aigc-detector/scripts/docx_io.py`:

```python
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
```

- [ ] **Step 2: Create a test docx and verify read**

```bash
python3 -c "
from docx import Document
doc = Document()
doc.add_paragraph('第一段测试文本。')
doc.add_paragraph('第二段测试文本。人工智能技术快速发展。')
doc.add_paragraph('')
doc.add_paragraph('第四段，包含首先、其次、综上所述等AI常用连接词。综上所述，具有重要意义。')
doc.save('/tmp/test_aigc.docx')
print('Test file created')
"
```

```bash
python3 ~/.claude/skills/aigc-detector/scripts/docx_io.py read /tmp/test_aigc.docx
```

Expected: 3 paragraphs of text output (empty paragraph skipped).

- [ ] **Step 3: Verify write**

```bash
echo -e "改写后的第一段内容。\n\n改写后的第二段内容。" | python3 ~/.claude/skills/aigc-detector/scripts/docx_io.py write /tmp/test_aigc_output.docx
```

```bash
python3 ~/.claude/skills/aigc-detector/scripts/docx_io.py read /tmp/test_aigc_output.docx
```

Expected: The two paragraphs written and read back correctly.

- [ ] **Step 4: Verify error handling**

```bash
python3 ~/.claude/skills/aigc-detector/scripts/docx_io.py read /tmp/nonexistent.docx
```

Expected: `Error: file not found: /tmp/nonexistent.docx` on stderr, exit code 1.

```bash
python3 ~/.claude/skills/aigc-detector/scripts/docx_io.py
```

Expected: Usage message on stderr, exit code 1.

---

### Task 3: Write references/detection_principles.md

**Files:**
- Create: `~/.claude/skills/aigc-detector/references/detection_principles.md`

- [ ] **Step 1: Write the detection principles knowledge base**

Create `~/.claude/skills/aigc-detector/references/detection_principles.md` with the following content:

```markdown
# 知网AIGC检测原理知识库

## 检测系统概述

知网AIGC检测系统（v2.13，2026年升级）采用"DeepSeek+华知"双模型架构，从三个核心维度识别AI生成内容：
- 语义连贯性分析
- 风格一致性评估
- 知识密度检测

识别准确率达89%，已覆盖ChatGPT、DeepSeek、豆包、Kimi等主流AI工具。

## AI生成文本的6大特征

### 1. 句式过于规整
频繁使用"研究了""体现了""提供了"等模板化句式，句子结构单一，缺乏变化。

### 2. 逻辑词堆砌
过度使用"首先""其次""综上所述""由此可见"等连接词，形成机械化的行文节奏。

### 3. 被动语态泛滥
如"数据被分析"而非"我们分析了数据"，被动句比例显著高于人类写作。

### 4. 句长分布均匀
缺乏长短句交错的自然节奏，句长方差小，变异系数通常低于15%。

### 5. 词汇重复率高
特定词汇（如"显著""有效""重要"）出现频率异常，缺乏同义替换的自然变化。

### 6. 论证缺乏深度
观点缺乏具体数据支撑，论证链条呈线性（观点→解释→结论），缺少多维证据、对比研究、个人见解。

## 2026年升级后的检测重点

知网v2.13升级后加强了**语义结构相似度判断**：
- 单纯同义词替换已无法通过检测
- 必须在语义结构层面进行重构
- 系统能识别AI的"套路化表达"模式

## 检测指标参考阈值

| 指标 | 正常范围（人类写作） | AI可疑范围 |
|------|---------------------|-----------|
| 词频离散度 | 0.4 - 0.6 | <0.3 或 >0.7 |
| 句子长度变异系数 | >25% | <15% |
| 被动语态占比 | <35% | >45% |
| 连接词密度 | <8% | >12% |
| 句式模板匹配度 | <20% | >40% |

## 学科特化阈值

| 学科类型 | 可容忍更高被动语态 | 要求更高术语密度 |
|---------|-------------------|----------------|
| 文科 | 是 | 否 |
| 理工科 | 否 | 是 |
| 医学 | 否 | 是 |
| 经管 | 部分 | 部分 |
```

---

### Task 4: Write references/rewrite_methods.md

**Files:**
- Create: `~/.claude/skills/aigc-detector/references/rewrite_methods.md`

- [ ] **Step 1: Write the rewrite methods knowledge base**

Create `~/.claude/skills/aigc-detector/references/rewrite_methods.md` with the following content:

```markdown
# 五大改写技法

## 核心原则

2026年知网升级后，单纯同义词替换已失效。必须在**语义结构层面**进行重构。
核心公式：**语义重构 + 句式多样化 + 个性化注入**

---

## 技法一：句式重构法

### 原理
AI最典型的特征是句子结构过于规整、长短均匀。人类写作自然地交错使用长短句。

### 操作要点
- 将连续短句合并为包含2-3个分句的长句
- 适当使用分号、冒号增加句式变化
- 转换语态（被动变主动，主动变被动）
- 插入一个超长句打破节奏规律

### 示例
**AI风格（高风险）：**
> 人工智能技术的快速发展对教育领域产生了深远影响。它改变了传统的教学模式。个性化学习成为可能。

**人类风格（低风险）：**
> 随着深度学习算法的持续突破，教育领域正经历着从传统统一授课向个性化学习范式的重要转型，这一变革的核心驱动力正是人工智能技术的快速发展。

---

## 技法二：破解AI语言模式

### 原理
AI有固定的"死亡组合"词汇模式，知网已建立完整的模式库。

### 高风险模板（必须删除或替换）
- "首先，本文分析了...；其次，本文探讨了...；最后，本文总结了..."
- "一是...，二是...，三是..."
- "XX的重要性不言而喻"
- "综上所述，本研究具有重要的理论意义和实践价值"
- "由此可见"
- "具体而言"
- "也就是说"

### 替换策略
- 删掉"首先/其次/最后"结构，改用递进关系："在厘清X概念的基础上，本研究进一步考察Y机制"
- 用具体衔接语替代模板连接词："与之相关的是""一个值得注意的现象是""基于上述分析"
- 将列举式改为叙述式

---

## 技法三：给句子找个"主人"

### 原理
AI最大破绽是喜欢写"无主句"——句子缺乏明确的行为主体。

### 操作要点
- 为每个判断句补充主语（研究者/本研究/该理论/实验数据）
- 将泛指改为具体指代

### 示例
**AI无主句（高风险）：**
> "确实令人困扰。"
> "具有重要意义。"
> "为后续研究提供了参考。"

**人类表达（低风险）：**
> "这一问题确实让从事该领域的研究者们感到持续困扰。"
> "本研究对该领域的理论建构和实证探索均具有重要的参考价值。"
> "张等（2024）的实验数据为后续研究提供了关键的对照组参考。"

---

## 技法四：概念具象化

### 原理
AI倾向于使用抽象、泛化的表述。人类学者会引入具体案例、数据和细节。

### 操作要点
- 将"广泛应用"替换为具体应用场景 + 数据
- 将"显著影响"替换为具体影响维度 + 程度
- 补充具体的设备型号、参数、实验条件
- 引入真实文献引用

### 示例
**抽象表达（高风险）：**
> "机器学习在图像识别领域具有广泛应用前景。"

**具体化改写（低风险）：**
> "在医学影像分析的实际应用中，基于卷积神经网络的AI系统已实现对早期肺癌病灶的95%识别准确率，显著提升了临床诊断效率。"

---

## 技法五：论证链条补全

### 原理
AI论证通常是线性的（观点→解释→结论）。人类论证是立体的（多维证据→对比→限定→结论）。

### 操作要点
- 为每个观点添加至少两个支撑证据
- 加入对比研究（"与X研究的结果不同，本研究发现..."）
- 补充限定条件（"在一定范围内""在X条件下"）
- 添加方法论反思（"这一结果的局限性在于..."）

### 示例
**线性论证（高风险）：**
> "社交媒体使用时间增加导致青少年注意力下降。"

**立体论证（低风险）：**
> "当社交媒体使用频率提升至每日3小时以上时，研究数据显示青少年的持续注意力时长较对照组下降约27%。这一发现与Smith（2023）报告的19%形成对比，可能源于样本选取的年龄差异——本研究纳入的受试者平均年龄为14.2岁，低于Smith研究中17.5岁的均值。"

---

## 学科特化建议

### 文科论文
- 重点关注：句式多样化、批判性评述
- 优化方向：增加对已有研究的批判性分析，打破AI的标准化叙事
- 可保留适度的学术化被动语态

### 理工科论文
- 重点关注：数据细节、方法描述精确度
- 优化方向：加入具体设备参数、实验条件、误差范围，这些信息机器难以虚构
- 使用专业缩写和符号

### 医学论文
- 重点关注：术语规范、数据精确
- 优化方向：使用专业缩写，加入样本量、p值、置信区间等具体统计信息
- 补充患者纳入/排除标准等细节

### 经管论文
- 重点关注：逻辑论证、案例结合
- 优化方向：补充实际企业案例数据，引用具体年报或财报数字
- 打破AI的理论模板，增加实践层面的分析

---

## 注意事项

1. 改写时保持学术规范，不要为了降低AI率而牺牲学术严谨性
2. 保留10%-15%的非标准化表达，这是人类写作的自然特征
3. 建议采用"人工修改+工具辅助"的组合策略
4. 改写后应由作者本人通读，确保逻辑连贯
```

---

### Task 5: Write SKILL.md

**Files:**
- Create: `~/.claude/skills/aigc-detector/SKILL.md`

- [ ] **Step 1: Write the SKILL.md main file**

Create `~/.claude/skills/aigc-detector/SKILL.md` with the following content:

```markdown
---
name: aigc-detector
description: 论文AIGC检测与改写助手。检测学术论文中的AI生成内容特征，提供详细改写建议，帮助降低知网等平台的AIGC检测率。支持.docx文档分析，输出检测报告和改写后文档。
---

# AIGC检测与论文改写助手

学术论文AIGC（AI生成内容）检测分析与改写助手。基于知网v2.13检测原理，从多维度分析文本的AI生成特征，提供具体的改写指导。

---

## 使用方式

**分析论文：**
- "分析这篇论文的AIGC特征：/path/to/thesis.docx"
- "检测这篇论文的AI率"（然后粘贴文本）

**改写论文：**
- "帮我改写这篇论文降低AI率：/path/to/thesis.docx"

---

## 工作流程

严格按照以下步骤执行，不要跳过任何步骤。

### Step 1：读取文档

根据用户输入类型选择处理方式：

**如果用户提供了 .docx 文件路径：**
```bash
python3 ~/.claude/skills/aigc-detector/scripts/docx_io.py read "<文件路径>"
```
将输出的文本用于后续分析。

**如果用户直接粘贴了文本：**
直接使用粘贴的文本进行分析。

**处理要求：**
- 按段落分割文本，为每个段落编号
- 如果文本过长（超过5000字），按章节或自然段落分段处理，每段200-500字

### Step 2：多维度语义分析

对文本进行5个维度的AI特征分析。不要使用简单的关键词匹配或统计计算，要基于语义理解进行深度分析。

**5个分析维度：**

1. **句式规整度** — 检测是否存在以下特征：
   - 模板化句式（"首先...其次...最后..."、"一是...二是...三是..."）
   - 句长过于均匀（缺乏长短句交错）
   - 段落结构雷同

2. **逻辑词密度** — 检测是否存在：
   - 连接词使用频率异常（"综上所述""由此可见""具体而言""也就是说"）
   - 机械化的过渡句
   - 逻辑词在相似位置反复出现

3. **语态特征** — 检测是否存在：
   - 被动语态泛滥（"被分析""被发现""被证明"）
   - 无主句过多（句子缺乏明确的行为主体）
   - 泛指表达过多（"具有重要意义""提供了参考"而未说明"谁""对什么"）

4. **词汇多样性** — 检测是否存在：
   - 特定词汇重复率高（"显著""有效""重要""促进"等）
   - 概念表述过于抽象，缺乏具体化
   - 缺乏学科术语的自然使用

5. **论证深度** — 检测是否存在：
   - 论证呈线性结构（观点→解释→结论），缺乏多维度证据
   - 缺少具体数据、案例、实验细节支撑
   - 缺少对比研究、方法论反思、局限性讨论
   - 缺少个人研究观点和独立见解

**评分规则：**
- 每个维度单独评分（0-100分，100分代表最像AI）
- 整体风险评分 = 5个维度的加权平均
  - 句式规整度：权重 25%
  - 逻辑词密度：权重 20%
  - 语态特征：权重 15%
  - 词汇多样性：权重 15%
  - 论证深度：权重 25%
- 段落级风险分级：
  - 高风险（>60分）：红色标记，需要重点改写
  - 中风险（30-60分）：黄色标记，建议优化
  - 低风险（<30分）：绿色标记，可保持

**重要：** 评分要考虑学科类型。如果用户未指定学科，询问用户论文所属学科，然后使用对应的阈值。参考 `~/.claude/skills/aigc-detector/references/detection_principles.md` 中的学科特化阈值。

### Step 3：输出检测报告

在终端输出Markdown格式的检测报告，结构如下：

```
# AIGC检测报告

## 基本信息
- 段落总数：X段
- 分析学科：[学科名称]
- 分析时间：[日期]

## 整体评估
- **AIGC风险评分：XX%** [高风险/中风险/低风险]

## 维度评分
| 维度 | 评分 | 状态 |
|------|------|------|
| 句式规整度 | XX分 | [图标] |
| 逻辑词密度 | XX分 | [图标] |
| 语态特征 | XX分 | [图标] |
| 词汇多样性 | XX分 | [图标] |
| 论证深度 | XX分 | [图标] |

## 段落级分析

### 第1段 [高风险/中风险/低风险]
- 原文：「...」
- 主要问题：[列出具体问题]
- 风险原因：[解释为什么被判定为AI特征]

### 第2段 ...

## 改写优先级建议
1. [最高优先级段落]：[原因]
2. [次优先级段落]：[原因]
...

## 总体建议
[基于整体分析给出2-3条宏观改写建议]
```

**询问用户：** "是否将此报告保存为Markdown文件？"

如果用户同意，使用Write工具保存到用户指定的路径（或默认保存到输入文件同目录下的 `aigc_report.md`）。

### Step 4：提供改写建议

对每个高风险和中风险段落，提供具体的改写建议。

改写前，先阅读 `~/.claude/skills/aigc-detector/references/rewrite_methods.md` 获取详细的改写技法。

对每个需要改写的段落：

1. 标注风险原因（引用具体维度）
2. 指出具体的AI特征词汇/句式
3. 提供改写示例（应用合适的改写技法）
4. 说明改写思路（为什么这样改能降低AI率）

**改写注意事项：**
- 保持原文的学术含义，不要改变核心观点
- 使用学科对应的术语和表达风格
- 保留10%-15%的非标准化表达
- 改写后段落应包含具体数据、案例或个人观点

**询问用户：** "是否需要我对高风险段落进行改写并输出新的.docx文件？"
- 如果用户同意，继续 Step 5
- 如果用户拒绝，流程结束

### Step 5：改写并输出文档

如果用户确认要改写：

1. **保存原始副本**
   ```bash
   cp "<原始文件路径>" "<原始文件名去扩展名>_backup.docx"
   ```
   如果用户提供的是文本而非文件，跳过此步。

2. **执行改写**
   - 逐段改写高风险和中风险段落
   - 保持低风险段落不变
   - 改写时严格遵循 `references/rewrite_methods.md` 中的技法
   - 每个改写后的段落都应能独立通过AIGC检测

3. **输出改写后文档**
   - 将改写后的全文组装
   - 使用 docx_io.py 写入新文件：

   ```bash
   echo "<改写后的全文>" | python3 ~/.claude/skills/aigc-detector/scripts/docx_io.py write "<输出路径>"
   ```

   默认输出路径：与原始文件同目录，文件名添加 `_rewritten` 后缀（如 `thesis_rewritten.docx`）

4. **输出改写对比**
   展示改写前后的对比摘要：
   - 改写了X个段落
   - 预估改写后AIGC风险评分
   - 改写使用的技法汇总

---

## 重要约束

1. 本Skill检测结果仅供参考，最终判断应以知网等官方平台的检测结果为准
2. 改写必须保持学术严谨性，绝不为了降低AI率而牺牲学术准确性
3. 不要编造虚假的数据、文献引用或实验结果
4. 建议用户采用"人工修改+工具辅助"的组合策略
5. 如果用户提供的文本明显不是学术论文（如小说、新闻等），提示用户本Skill专用于学术论文分析

## 参考知识库

- 检测原理：`~/.claude/skills/aigc-detector/references/detection_principles.md`
- 改写技法：`~/.claude/skills/aigc-detector/references/rewrite_methods.md`
```

- [ ] **Step 2: Verify SKILL.md is recognized by Claude Code**

确认文件存在且格式正确：

```bash
head -5 ~/.claude/skills/aigc-detector/SKILL.md
```

Expected: YAML frontmatter with `name: aigc-detector` and description.

---

### Task 6: End-to-End Verification

**Files:**
- None (verification only)

- [ ] **Step 1: Create a test docx with AI-style content**

```python
from docx import Document
doc = Document()
doc.add_paragraph("首先，本文分析了人工智能技术在教育领域的应用。其次，本文探讨了其带来的机遇与挑战。最后，本文总结了未来的发展方向。综上所述，人工智能技术对教育领域具有重要意义，其影响深远而广泛，不容忽视。")
doc.add_paragraph("数据被分析后发现了显著的差异性。结果表明，机器学习模型具有有效的预测能力。此外，深度学习算法被证明在图像识别中表现出色。由此可见，人工智能技术的发展具有重要意义。")
doc.add_paragraph("社交媒体使用时间增加导致青少年注意力下降。具体而言，过度使用社交媒体会分散青少年的学习精力。因此，减少社交媒体使用时间对青少年的学习成绩具有积极影响。综上所述，这一问题的重要性不言而喻。")
doc.add_paragraph("本研究采用定量研究方法。数据来源于问卷调查。共收集了500份有效问卷。使用SPSS软件进行统计分析。结果显示，变量之间存在显著相关性。研究结论对相关领域的理论建设具有重要意义。")
doc.add_paragraph("在2023年的实验中，研究团队使用NVIDIA A100 GPU训练了一个基于Transformer架构的文本分类模型。与传统的BERT-base（12层，110M参数）相比，本研究提出的轻量化模型在保持95.2% F1-score的同时，推理速度提升了3.7倍。值得注意的是，当我们将训练数据量从10万条增加到50万条时，模型在低资源场景（<1000条标注数据）下的零样本迁移能力反而下降了12.3%，这一反直觉的发现与Chen等人在NeurIPS 2022上报告的趋势一致——过量的领域内数据可能导致模型对特定分布的过拟合。")
doc.save("/tmp/test_aigc_paper.docx")
```

- [ ] **Step 2: Test the full workflow**

在Claude Code中执行：
> "分析这篇论文的AIGC特征：/tmp/test_aigc_paper.docx"

**验证要点：**
- Skill被正确触发
- docx文件被成功读取
- 输出包含整体评分、维度评分、段落级分析
- 前4段被标记为高风险（明显AI风格）
- 第5段被标记为低风险（包含具体数据、对比研究、个人见解）
- 改写建议具体且有针对性

- [ ] **Step 3: Clean up test files**

```bash
rm -f /tmp/test_aigc.docx /tmp/test_aigc_output.docx /tmp/test_aigc_paper.docx
```

---

## File Structure Summary

```
~/.claude/skills/aigc-detector/
├── SKILL.md                          # 主入口：触发条件 + 5步工作流 + 评分规则 + 约束
├── scripts/
│   └── docx_io.py                    # docx 读取/写入（~60行）
└── references/
    ├── detection_principles.md       # 知网检测原理 + 6大AI特征 + 阈值表
    └── rewrite_methods.md            # 5大改写技法 + 学科特化建议
```
