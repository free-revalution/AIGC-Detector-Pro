---
name: aigc-detector
description: "Academic paper AI content detection, rewriting, and thesis writing assistant. Analyzes text for AI-generated characteristics, provides detailed rewrite suggestions, and generates full thesis drafts. Supports .docx files, outputs reports and rewritten/formatted documents. Bilingual: Chinese & English."
---

# AIGC Detection, Rewriting & Thesis Writing Assistant

Bilingual academic paper assistant. Two modes: **Detection & Rewrite** (analyze existing papers for AI-generated content) and **Thesis Writing** (generate full thesis drafts from templates and code). Supports Chinese and English academic papers.

---

## 使用方式

**分析论文 / Analyze paper:**
- "分析这篇论文的AIGC特征：/path/to/thesis.docx"
- "Analyze this paper for AI-generated content: /path/to/thesis.docx"
- "检测这篇论文的AI率"（然后粘贴文本）

**改写论文 / Rewrite paper:**
- "帮我改写这篇论文降低AI率：/path/to/thesis.docx"
- "Help me rewrite this paper to reduce AI detection rate: /path/to/thesis.docx"

**撰写论文 / Write thesis:**
- "帮我写毕业论文，模板在About/目录"
- "Help me write my graduation thesis, template is in About/"
- "开始论文写作模式"（然后按提示操作）

---

## Agent 适配说明

本 Skill 适配多种 AI Agent。以下是各 Agent 的工具映射：

| 功能 | Claude Code | 其他 Agent (Codex / Cursor / Windsurf / Gemini) |
|------|------------|--------------------------------------------------|
| 询问用户 | AskUserQuestion 工具 | 输出选项编号，等待用户输入数字选择 |
| 保存文件 | Write 工具 | 使用 Bash 写入文件 |
| 读取文档 | Bash + python3 | 相同 |
| 生成图表 | Bash + python3 diagram_gen.py | 相同 |
| 插入图片 | Bash + python3 docx_io.py insert_figure | 相同 |
| 路径解析 | .claude/skills/ → ~/.claude/skills/（fallback） | ~/.claude/skills/（全局安装路径） |

---

## 工作流程

严格按照以下步骤执行，不要跳过任何步骤。

### 模式选择（Mode Selection）

根据用户意图选择工作模式：

1. **检测/改写模式（Detection & Rewrite Mode）** — 用户要求分析或改写已有论文
   - 触发词："分析""检测""改写""降低AI率""AIGC" + 文件路径或文本
   - 执行下方 **检测/改写模式** 步骤（Step 0-5）

2. **论文写作模式（Thesis Writing Mode）** — 用户要求撰写或生成论文
   - 触发词："写论文""撰写""生成论文""毕业论文""thesis""write paper"
   - 执行下方 **论文写作模式** 步骤（Step W0-W5）
   - 详细指令见 `references/thesis_writing_guide.md`

如果用户意图不明确，使用 AskUserQuestion 工具询问：
> 1. "检测/改写已有论文"
> 2. "撰写新论文"

---

### 检测/改写模式（Detection & Rewrite Mode）

### Step 0：语言检测

检测论文语言。如果用户提供了 .docx 文件，先执行 Step 1 读取文档获取文本后再检测语言。

1. 分析输入文本的前500个字符
2. 如果非标点字符中中文字符占比 > 60% → 语言 = "zh"
3. 否则 → 语言 = "en"
4. 后续所有步骤（分析、报告、改写）均使用检测到的语言

**中英文对应维度映射：**

| 中文维度 | English Dimension |
|---------|------------------|
| 句式规整度 | Sentence Regularity |
| 逻辑词密度 | Connector Density |
| 语态特征 | Voice Characteristics |
| 词汇多样性 | Vocabulary Diversity |
| 论证深度 | Argumentation Depth |

**重要：** 如果语言为 "en"，在 Step 2 分析时参考 `references/detection_principles.md` 中的 "English AI Characteristics" 章节，在 Step 5 改写时参考 `references/rewrite_methods.md` 中的 "English Rewrite Techniques" 章节。

### Step 1：读取文档

根据用户输入类型选择处理方式：

**如果用户提供了 .docx 文件路径：**

先用全局安装路径尝试：
```bash
python3 ~/.claude/skills/aigc-detector/scripts/docx_io.py read "<文件路径>"
```
如果上述命令失败（文件不存在），再尝试项目级路径：
```bash
python3 .claude/skills/aigc-detector/scripts/docx_io.py read "<文件路径>"
```

将输出的文本用于后续分析。输出格式为 `[段落编号] 段落内容`，段落间以空行分隔。

**如果用户直接粘贴了文本：**
直接使用粘贴的文本进行分析。

**处理要求：**
- 如果文本过长（超过5000字），按章节或自然段落分段处理，每段200-500字

### Step 2：多维度语义分析

对文本进行5个维度的AI特征分析。不要使用简单的关键词匹配或统计计算，要基于语义理解进行深度分析。

**5个分析维度：**

1. **句式规整度** — 检测是否存在以下特征：
   - 中文：模板化句式（"首先...其次...最后..."、"一是...二是...三是..."）
   - 英文：Template transitions ("Firstly...Secondly...In conclusion...", "It is important to note that...", "Building on previous work...")
   - 句长过于均匀（缺乏长短句交错）
   - 段落结构雷同

2. **逻辑词密度** — 检测是否存在：
   - 中文：连接词使用频率异常（"综上所述""由此可见""具体而言""也就是说"）
   - 英文：Hedging language overuse ("it is worth noting that", "it should be emphasized", "to some extent", "arguably", "may suggest")
   - 机械化的过渡句
   - 逻辑词在相似位置反复出现

3. **语态特征** — 检测是否存在：
   - 中文：被动语态泛滥（"被分析""被发现""被证明"）
   - 英文：Passive voice overuse ("was analyzed", "has been shown to", "it was found that") and uniform formal register throughout
   - 无主句过多（句子缺乏明确的行为主体）
   - 泛指表达过多（"具有重要意义""提供了参考"而未说明"谁""对什么"）

4. **词汇多样性** — 检测是否存在：
   - 中文：特定词汇重复率高（"显著""有效""重要""促进"等）
   - 英文：AI overuses "significantly", "effectively", "demonstrate", "leverage", "utilize", "facilitate", "comprehensive"
   - 概念表述过于抽象，缺乏具体化
   - 缺乏学科术语的自然使用

5. **论证深度** — 检测是否存在：
   - 论证呈线性结构（观点→解释→结论），缺乏多维度证据
   - 缺少具体数据、案例、实验细节支撑
   - 缺少对比研究、方法论反思、局限性讨论
   - 缺少个人研究观点和独立见解
   - 英文特有：Missing methodological caveats（不讨论局限性）和 citation pattern uniformity（公式化引用 "According to [Author] (Year)..." 而不深入讨论引文内容）

**评分规则：**
- 每个维度单独评分（0-100分，100分代表最像AI）
- 整体风险评分 = 5个维度的加权平均
  - 句式规整度：权重 25%
  - 逻辑词密度：权重 20%
  - 语态特征：权重 15%
  - 词汇多样性：权重 15%
  - 论证深度：权重 25%
- 段落级风险分级：
  - 高风险（>60分）：需要重点改写
  - 中风险（30-60分）：建议优化
  - 低风险（<30分）：可保持

**重要：** 评分要考虑学科类型。如果用户未指定学科，询问用户论文所属学科，然后使用对应的阈值。

### Step 3：输出检测报告

在终端输出Markdown格式的检测报告。根据 Step 0 检测到的语言选择对应模板。

**中文报告模板（language = "zh"）：**

```markdown
# AIGC检测报告

## 基本信息
- 段落总数：X段
- 分析学科：[学科名称]
- 分析时间：[日期]

## 整体评估
- **AIGC风险评分：XX%** 【高风险/中风险/低风险】

## 维度评分

| 维度 | 评分 | 状态 |
|:-----|:----:|:----:|
| 句式规整度 | XX分 | 高/中/低风险 |
| 逻辑词密度 | XX分 | 高/中/低风险 |
| 语态特征   | XX分 | 高/中/低风险 |
| 词汇多样性 | XX分 | 高/中/低风险 |
| 论证深度   | XX分 | 高/中/低风险 |

---

## 段落级分析

### 第1段：【高风险 XX分】

**原文：**
> 「...前50字...」

**主要问题：**
- 问题1描述
- 问题2描述

**风险原因：** 解释为什么被判定为AI特征

---

### 第2段：【中风险 XX分】

（格式同上，每个段落独立一个小节）

---

## 改写优先级

| 优先级 | 段落 | 原因 |
|:------:|:-----|:-----|
| 1 | 段落名 | 原因简述 |
| 2 | 段落名 | 原因简述 |
| ... | ... | ... |

## 总体建议
1. 建议1
2. 建议2
```

**英文报告模板（language = "en"）：**

```markdown
# AIGC Detection Report

## Overview
- Total paragraphs: X
- Discipline: [Discipline Name]
- Analysis date: [Date]

## Overall Assessment
- **AIGC Risk Score: XX%** [High Risk / Medium Risk / Low Risk]

## Dimension Scores

| Dimension | Score | Status |
|:----------|:-----:|:------:|
| Sentence Regularity | XX | High/Medium/Low Risk |
| Connector Density | XX | High/Medium/Low Risk |
| Voice Characteristics | XX | High/Medium/Low Risk |
| Vocabulary Diversity | XX | High/Medium/Low Risk |
| Argumentation Depth | XX | High/Medium/Low Risk |

---

## Paragraph-Level Analysis

### Paragraph 1: [High Risk XX]

**Original text:**
> "...first 50 words..."

**Key issues:**
- Issue 1 description
- Issue 2 description

**Risk rationale:** Explanation of why this was flagged as AI-generated

---

### Paragraph 2: [Medium Risk XX]

(Same format as above, each paragraph in its own subsection)

---

## Rewrite Priority

| Priority | Paragraph | Reason |
|:--------:|:----------|:-------|
| 1 | Paragraph name | Brief reason |
| 2 | Paragraph name | Brief reason |
| ... | ... | ... |

## Overall Recommendations
1. Recommendation 1
2. Recommendation 2
```

**注意事项：**
- 中文报告使用 `> 「...」` 引用原文（只引用前50字），英文报告使用 `> "..."` 引用原文
- 使用表格展示维度评分和改写优先级，使报告更易读
- 用分隔线 `---` 区分报告的不同区块
- 高风险用红色 emoji 标记（🔴），中风险用黄色（🟡），低风险用绿色（🟢）
- 不要使用 ASCII 表格框线（如 ┌──┬──┐），使用标准 Markdown 表格

### Step 4：询问用户下一步操作

报告输出后，使用 AskUserQuestion 工具一次性询问用户后续操作。根据语言使用对应选项文案：

> **注意：** 若当前 Agent 不支持 AskUserQuestion 工具，直接在终端输出选项编号（1/2/3），等待用户输入数字选择。

**中文选项：**
1. "保存报告为 Markdown 文件" — 将检测报告保存为 .md 文件
2. "对高风险段落进行改写并输出 .docx" — 执行 Step 5 的完整改写流程
3. "仅查看改写建议（不修改文档）" — 输出改写建议供手动修改参考

**English options:**
1. "Save report as Markdown file"
2. "Rewrite high-risk paragraphs and output .docx"
3. "View rewrite suggestions only (no document changes)"

根据用户选择执行对应操作：
- 选择 1：使用 Write 工具保存，默认路径为输入文件同目录下的 `aigc_report.md`

> **注意：** 若当前 Agent 不支持 Write 工具，使用 Bash 命令写入文件。
- 选择 2：继续 Step 5
- 选择 3：对每个高风险/中风险段落输出改写建议（技法 + 示例 + 思路），然后结束
- 用户可多选（同时选 1 和 2，或 1 和 3）

### Step 5：改写并输出文档（仅在用户选择时执行）

如果用户确认要改写：

1. **保存原始副本**
   ```bash
   cp "<原始文件路径>" "<原始文件名去扩展名>_backup.docx"
   ```
   如果用户提供的是文本而非文件，跳过此步。

2. **执行改写**
   - 逐段改写高风险和中风险段落
   - 保持低风险段落不变
   - 中文改写严格遵循 7 大改写技法（句式重构 > 破解模板 > 论证补全 > 概念具象 > 困惑度提升 > 风格断裂 > 添加主语）
   - 英文改写严格遵循 7 大 English Rewrite Techniques（Sentence Variation > Replace Formulaic Transitions > Counterargument Addition > Concrete Language > Controlled Informality > Register Variation > Active Voice Priority）
   - 每个改写后的段落都应能独立通过AIGC检测

3. **输出改写后文档**

   使用 docx_io.py 的 replace 子命令逐个替换高风险段落，保留原始文档的格式、图片和排版：

   **首次替换**（从原始文件生成改写版本）：
   ```bash
   echo "<改写后的段落文本>" | python3 ~/.claude/skills/aigc-detector/scripts/docx_io.py replace "<原始文件路径>" <段落编号> --output "<原始文件名去扩展名>_rewritten.docx"
   ```

   **后续替换**（在改写版本上继续替换，用 --output 指向同一个输出文件）：
   ```bash
   echo "<改写后的段落文本>" | python3 ~/.claude/skills/aigc-detector/scripts/docx_io.py replace "<上一步的输出文件>" <段落编号> --output "<上一步的输出文件>"
   ```

   如果全局路径不存在，回退到项目级路径：
   ```bash
   echo "<改写后的段落文本>" | python3 .claude/skills/aigc-detector/scripts/docx_io.py replace "<文件路径>" <段落编号> --output "<输出路径>"
   ```

   - 先保存原始副本：`cp "<原始文件路径>" "<文件名去扩展名>_backup.docx"`
   - 首次替换指定 `--output` 为 `{文件名}_rewritten.docx`
   - 后续替换将上一步的输出作为输入，`--output` 指向同一文件
   - 保留低风险段落不变

4. **输出改写对比摘要**

根据语言使用对应模板：

**中文模板：**

```markdown
## 改写结果

**输出文件：**
- 改写后论文：[文件路径]

**改写统计：**
- 替换段落：X个
- 保留段落：Y个

**改写覆盖的高风险段落：**

| 段落 | 改写要点 |
|:-----|:---------|
| 段落名 | 改写要点简述 |
| ... | ... |

**主要应用的改写技法：** 技法1、技法2、...

**预估改写后AIGC风险：** 从XX%降至约XX-XX%
```

**English template:**

```markdown
## Rewrite Results

**Output files:**
- Rewritten paper: [file path]

**Statistics:**
- Paragraphs rewritten: X
- Paragraphs preserved: Y

**High-risk paragraphs addressed:**

| Paragraph | Key Changes |
|:----------|:------------|
| Paragraph name | Brief description |
| ... | ... |

**Primary techniques applied:** Technique 1, Technique 2, ...

**Estimated post-rewrite AIGC risk:** From XX% to approximately XX-XX%
```

---

### 论文写作模式（Thesis Writing Mode）

当用户选择论文写作模式时，执行以下步骤。每一步的详细指令见 `references/thesis_writing_guide.md`。

- **Step W0: 环境准备** — 在工作目录创建 `About/` 目录，引导用户放入材料（论文模板 .docx、范文、代码、文档），扫描并分类文件。使用 `docx_io.py analyze` 解析模板格式。
- **Step W1: 材料分析** — 解析模板格式要求，阅读范文理解写作风格，分析代码理解项目架构，收集用户信息（题目、学校、姓名、导师、字数等）。
- **Step W2: 大纲生成** — 基于模板结构、范文模式、代码分析生成论文大纲，用户审核修改后确认。
- **Step W3: 逐章撰写** — 按大纲逐章生成内容。代码相关章节基于实际代码分析。全程应用 AIGC 安全写作技法（参考 `references/rewrite_methods.md`）。**图表识别与插入：**写每章时自动判断适合插入图表的位置（参考 `references/thesis_writing_guide.md` 中的图表规则），输出建议列表供用户确认。用户确认后：
  1. 生成 Mermaid 文本描述
  2. 调用 `diagram_gen.py generate` 渲染 PNG
  3. 调用 `docx_io.py insert_figure` 插入图片 + 题注到 docx
  每章生成后暂停，让用户确认或修改后再继续。维护全局上下文摘要确保跨章节一致性。
**图表生成命令：**
```bash
# 生成图表（Mermaid 文本 → PNG）
echo "graph TD\n  A --> B" | python3 ~/.claude/skills/aigc-detector/scripts/diagram_gen.py generate --output ./figures/fig1.png

# 插入图片到 docx（在第5段后插入）
python3 ~/.claude/skills/aigc-detector/scripts/docx_io.py insert_figure thesis.docx 5 ./figures/fig1.png --caption "图 3-1 系统架构图" --output thesis_with_fig.docx
```

如果全局路径不存在，回退到项目级路径：
```bash
python3 .claude/skills/aigc-detector/scripts/diagram_gen.py generate --output ./figures/fig1.png
python3 .claude/skills/aigc-detector/scripts/docx_io.py insert_figure thesis.docx 5 ./figures/fig1.png --caption "图 3-1 系统架构图"
```

**注意：** 多张图片需从后往前插入（先插索引大的段落），避免段落索引偏移。

- **Step W4: 格式应用与输出** — 使用 `docx_io.py formatted_write` 命令将 Markdown 文本转换为格式化 .docx（自动应用模板的页面布局、字体、行距等）。
- **Step W5: AIGC 检测与优化** — 对完整论文执行检测流程（Step 0-3），识别高风险段落并改写优化，直到通过检测。

**论文写作模式约束：**
1. 不编造虚假的实验数据、代码功能或项目背景
2. 代码分析章节必须基于 About/ 中的实际代码，不能凭空捏造
3. 参考文献仅来自用户提供的材料，不编造文献引用
4. 每章生成后需用户确认，不自动生成全篇

---

## 重要约束

1. 本Skill检测结果仅供参考，最终判断应以各平台官方检测结果为准
2. 改写必须保持学术严谨性，绝不为了降低AI率而牺牲学术准确性
3. 不要编造虚假的数据、文献引用或实验结果
4. 建议用户采用"人工修改+工具辅助"的组合策略
5. 如果用户提供的文本明显不是学术论文（如小说、新闻等），提示用户本Skill专用于学术论文分析
