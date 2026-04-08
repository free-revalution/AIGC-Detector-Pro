# AIGC检测原理知识库

## 一、主流检测技术

AIGC 检测的核心原理是利用 AI 生成文本与人类写作的统计分布差异。学术界和工业界已发展出多种检测方法。

### 1. 困惑度检测（Perplexity-based Detection）

**代表项目**：DetectGPT（Stanford, Mitchell et al. 2023）

- **原理**：AI 模型生成文本时，会倾向于选择概率较高的词，导致文本整体困惑度（perplexity）偏低。人类写作由于思维的非线性跳跃，困惑度更高且波动更大。
- **方法**：用语言模型计算文本的对数概率，AI 文本的困惑度通常比人类文本低 30-50%。
- **局限性**：当 AI 被指示生成"有创意"的内容时，困惑度会接近人类水平。

### 2. 突发性检测（Burstiness Analysis）

**代表项目**：GPTZero（Tian et al. 2023）

- **原理**：人类写作的句子长度和复杂度呈现"突发性"——长短句交替出现，方差大。AI 生成的文本句子长度分布更均匀，突发性偏低。
- **方法**：计算句子级别的困惑度方差（sentence-level perplexity variance）。人类文本的突发性指标通常是 AI 文本的 2-3 倍。
- **关键洞察**：即使 AI 文本的整体困惑度与人类接近，突发性指标仍然能区分两者。

### 3. 分类器检测（Classifier-based Detection）

**代表项目**：RoBERTa-base-OpenAI-Detector、HelloSimpleAI/ai-detector

- **原理**：使用预训练语言模型（如 RoBERTa）在大规模人类/AI 文本对上微调，直接学习两类文本的分布差异。
- **方法**：将文本编码后输入分类器，输出 AI 生成概率。
- **优势**：能捕捉超越统计特征的深层语言模式差异。
- **局限性**：对新模型（如 GPT-4、Claude）生成的文本效果可能下降，需要持续更新训练数据。

### 4. 多特征融合检测（Multi-feature Detection）

**代表项目**：Ghostbuster（UC Berkeley, Wan et al. 2023）

- **原理**：单一指标容易误判，融合多个互补特征可显著提升准确率。
- **方法**：结合困惑度、突发性、词汇多样性、句法复杂度、语义一致性等多个维度，加权融合判断。
- **优势**：多指标互补，鲁棒性更强。

### 5. 概率曲率检测（Probability Curvature）

**代表项目**：DetectGPT（Stanford）

- **原理**：AI 生成文本处于概率分布的高概率区域。如果在文本的某些位置替换为低概率词，AI 文本的采栝始终会回到原始词汇（概率曲率为负），而人类文本没有这种倾向。
- **方法**：零样本检测，不需要训练数据。
- **优势**：可以检测未见过的 AI 模型。

## 二、AI 生成文本的 12 大特征

### 语言风格特征

| 特征 | 描述 | 检测方法 |
|------|------|---------|
| **1. 困惑度偏低** | AI 倾向选择高概率词，整体文本更"可预测" | Perplexity 计算 |
| **2. 突发性不足** | 句子长度和复杂度分布过于均匀 | 句级困惑度方差 |
| **3. 模板化句式** | "首先/其次/综上所述"、三是...三... | 模式匹配 |
| **4. 逻辑词堆砌** | 过度使用连接词形成机械节奏 | 连接词密度统计 |
| **5. 被动语态泛滥** | "被分析""被发现""被证明"过多 | 语态标注分析 |
| **6. 无主句过多** | 缺乏明确行为主体 | 依存句法分析 |

### 内容深度特征

| 特征 | 描述 | 检测方法 |
|------|------|---------|
| **7. 词汇重复率高** | "显著""有效""重要"等词频率异常 | 词频分布分析 |
| **8. 概念过于抽象** | 缺乏具体数据、案例、实验细节 | 实体密度计算 |
| **9. 论证线性化** | 观点→解释→结论，缺乏多维证据 | 论证结构分析 |
| **10. 风格一致性强** | 全文语言风格高度统一，缺乏个人化表达 | 风格一致性度量 |
| **11. 缺少方法论反思** | 不讨论局限性、不对比不同观点 | 否定/限定词密度 |
| **12. 引用模式异常** | 引用格式单一，缺乏对引文的具体讨论 | 引用上下文分析 |

## 三、本 Skill 的检测策略

### 为什么选择 Prompt 驱动而非规则引擎？

| 对比维度 | 规则/统计引擎 | Prompt 驱动（Claude） |
|---------|-------------|-------------------|
| 语义理解 | 仅靠正则/统计，无法理解含义 | 深层语义理解，能判断论证质量 |
| 适应性 | 固定规则，新 AI 写法会绕过 | 灵活适应，随 AI 进化而进化 |
| 上下文理解 | 段落级分析，缺乏全文连贯性判断 | 全文连贯性分析，跨段落检测 |
| 改写建议 | 只能标记问题，无法给出针对性建议 | 理解内容后给出具体的改写方案 |
| 误判率 | 15-25%（统计方法上限） | 利用深层语义理解，误判更低 |

### 检测流程

本 Skill 采用 5 维度语义分析，对应学术界主流检测方法：

| Skill 维度 | 对应学术方法 | 核心原理 |
|-----------|-------------|---------|
| 句式规整度 | 突发性检测 (Burstiness) | 检测句长分布均匀度、模板化表达 |
| 逻辑词密度 | 模式匹配 + 词频分析 | 检测连接词使用频率异常 |
| 语态特征 | 句法分析 (Syntactic Analysis) | 检测被动语态、无主句 |
| 词汇多样性 | 词频分布分析 (Vocabulary Distribution) | 检测词汇重复率、抽象度 |
| 论证深度 | 语义一致性分析 (Semantic Coherence) | 检测论证结构、证据深度 |

### 评分权重设计

```
句式规整度: 25%  ← 突发性是最强的单一检测信号
逻辑词密度: 20%  ← 模板化表达是 AI 最明显痕迹
语态特征:   15%  ← 辅助指标
词汇多样性: 15%  ← 辅助指标
论证深度:   25%  ← 语义一致性是最难伪装的维度
```

论证深度和句式规整度权重最高，因为：
- **论证深度**：AI 难以生成包含具体数据、对比文献、方法论反思的立体论证
- **句式规整度**：突发性是学术界的核心检测指标（GPTZero、DetectGPT 都基于此）

## 四、检测指标参考阈值

| 指标 | 正常范围（人类写作） | AI可疑范围 | 对应检测方法 |
|------|---------------------|-----------|-------------|
| 困惑度 | 高（>阈值） | 低（<阈值） | Perplexity |
| 句子长度突发性 | 高（>2x均值） | 低（<1.5x均值） | Burstiness |
| 词频离散度 | 0.4 - 0.6 | <0.3 或 >0.7 | 词汇分布 |
| 句子长度变异系数 | >25% | <15% | 统计特征 |
| 被动语态占比 | <35% | >45% | 句法分析 |
| 连接词密度 | <8% | >12% | 模式匹配 |
| 句式模板匹配度 | <20% | >40% | 模式匹配 |

## 五、学科特化阈值

| 学科类型 | 可容忍更高被动语态 | 要求更高术语密度 | 重点检测维度 |
|---------|-------------------|----------------|-------------|
| 文科 | 是 | 否 | 句式规整度、逻辑词密度 |
| 理工科 | 否 | 是 | 论证深度、概念具象度 |
| 医学 | 否 | 是 | 术语规范度、数据精确度 |
| 经管 | 部分 | 部分 | 逻辑论证、案例结合度 |

## 六、参考文献

- Mitchell, E., et al. (2023). "DetectGPT: Zero-Shot Machine-Generated Text Detection using Probability Curvature." *ICML 2023*.
- Tian, L., et al. (2023). "GPTZero: A Tool for Detecting AI-Generated Text." *Princeton University*.
- Wan, Z., et al. (2023). "Ghostbuster: Detecting Ghost Text in Student Essays." *UC Berkeley*.
- Krishna, K., et al. (2023). "Can AI-Generated Text be Reliably Detected?" *ICLR 2024*.
- OpenAI. (2023). "RoBERTa-base-OpenAI-Detector." *Hugging Face*.

---

## 七、English AI Characteristics (英文AI特征)

When analyzing English academic papers, the following 7 English-specific AI characteristics should be evaluated alongside the standard 5 dimensions.

### Feature 1: Excessive Hedging Language (过度模糊语言)

AI overuses tentative language to appear balanced: "it is worth noting that", "it should be emphasized", "to some extent", "arguably", "may suggest", "it could be argued that". Human academic writing is more direct in stating findings.

**Detection indicators:**
- Hedging word density > 6% of total words
- Multiple hedging phrases per paragraph
- Tentative language used even for well-established findings

### Feature 2: Passive Voice Overuse (被动语态过度使用)

AI defaults to passive constructions: "was analyzed", "has been shown to", "it was found that", "were collected", "is considered". Human writers use active voice more frequently: "we analyzed", "our results show", "we found that".

**Detection indicators:**
- Passive voice ratio > 45% of sentences
- Consecutive passive sentences (>3 in a row)
- "It was found that..." / "It should be noted that..." sentence openers

### Feature 3: Uniform Formal Register (形式化语体一致性)

AI maintains identical academic register throughout the entire text. Human writing varies naturally — some paragraphs are more formal (results), others more direct (methods), and transitions often use slightly different registers.

**Detection indicators:**
- Consistent sentence complexity across all sections
- No variation in formality level between sections
- All paragraphs follow the same rhetorical pattern

### Feature 4: Template Transitions (模板化过渡)

AI uses formulaic transitions: "Firstly...Secondly...In conclusion...", "It is important to note that...", "Building on previous work...", "As previously mentioned...", "In addition to the above...". Human transitions are more varied and contextual.

**Detection indicators:**
- Template transition count > 4 per section
- Identical transition phrases repeated across sections
- Sequential enumeration patterns (Firstly/Secondly/Thirdly)

### Feature 5: Vocabulary Repetition (词汇重复)

AI overuses a limited set of "academic-sounding" words: "significantly", "effectively", "demonstrate", "leverage", "utilize", "facilitate", "comprehensive", "novel", "robust", "paramount". Human writers use more diverse vocabulary with discipline-specific alternatives.

**Detection indicators:**
- Lexical diversity (Type-Token Ratio) < 0.60
- Same "academic buzzword" appearing > 3 times per 1000 words
- Preference for polysyllabic alternatives over simpler accurate words (e.g., "utilize" instead of "use")

### Feature 6: Missing Methodological Caveats (缺少方法论限定)

AI omits or minimizes limitations discussion. Human papers typically include honest assessments: "limitations of this approach include...", "within the scope of this study...", "this finding should be interpreted with caution because...", "a constraint of our dataset is...".

**Detection indicators:**
- Zero methodological caveat statements in a major section
- No discussion of sample size limitations, confounding variables, or scope boundaries
- Overconfident claims without hedging or qualification

### Feature 7: Citation Pattern Uniformity (引用模式单一)

AI uses formulaic citation openings: "According to [Author] (Year)..." without engaging with the cited content. Human writing integrates citations into the argument, sometimes agreeing, sometimes critiquing, sometimes extending the cited work.

**Detection indicators:**
- All citations follow the same pattern: "Author (Year) found that..."
- No critical engagement with cited sources
- Citations used as decorative references rather than argumentative tools

### English-Specific Thresholds (英文特有阈值)

| Metric | Normal Range (Human) | AI-Suspicious Range |
|--------|---------------------|-------------------|
| Passive voice ratio | < 30% | > 45% |
| Hedging word density | < 3% | > 6% |
| Template transition count | < 2 per section | > 4 per section |
| Lexical diversity (TTR) | > 0.72 | < 0.60 |
| Methodological caveat count | >= 1 per major section | 0 (missing) |
