---
name: writing-skills
description: Use when creating new skills, editing existing skills, or verifying skills work before deployment
---

# 编写 Skills

## 概述

**编写 skills 就是应用于流程文档的测试驱动开发。**

你写测试用例（用 subagent 运行压力场景），看着它们失败（基线行为），写 skill（文档），看着测试通过（agent 遵从），然后重构（堵上漏洞）。

**核心原则：** 如果你没有亲眼看到一个 agent 在没有 skill 时失败，你就不知道 skill 是否教了正确的东西。

**必须背景知识：** 使用此 skill 前必须理解 TDD。TDD 定义了基本的红-绿-重构循环。此 skill 将 TDD 适配到文档编写。

## 什么是 Skill？

**Skill** 是经过验证的技术、模式或工具的参考指南。Skills 帮助未来的 Claude 实例找到并应用有效的方法。

**Skill 是：** 可复用的技术、模式、工具、参考指南
**Skill 不是：** 关于你如何解决某个问题的叙事

## TDD 映射

| TDD 概念 | Skill 创建 |
|----------|-----------|
| **测试用例** | 用 subagent 运行压力场景 |
| **生产代码** | Skill 文档（SKILL.md） |
| **测试失败（红）** | Agent 无 skill 时违反规则（基线） |
| **测试通过（绿）** | Agent 有 skill 时遵从 |
| **重构** | 在保持合规的同时堵上漏洞 |
| **先写测试** | 在写 skill 前先运行基线场景 |
| **看着它失败** | 记录 agent 使用的确切借口 |
| **最少代码** | 针对那些具体违规编写 skill |
| **看着它通过** | 验证 agent 现在遵从 |
| **重构循环** | 发现新借口 → 堵上 → 重新验证 |

## 何时创建 Skill

**创建时机：**
- 技术对你来说不是直觉上显而易见的
- 你会跨项目再次参考它
- 模式适用范围广（非项目特定）
- 其他人会受益

**不要创建：**
- 一次性解决方案
- 已在他处充分记录的实践
- 项目特定的约定（放在 CLAUDE.md 中）
- 纯机械约束（如果能用正则/验证强制执行，自动化它）

## SKILL.md 结构

**Frontmatter（YAML）：**
- 两个必需字段：`name` 和 `description`（参见 agentskills.io/specification）
- 最多 1024 字符
- `name`：仅使用字母、数字和连字符
- `description`：第三人称，仅描述何时使用（而非做什么）
  - 以 "Use when..." 开头，聚焦触发条件
  - 包含具体症状、场景和上下文
  - **永远不要总结 skill 的流程或工作流**
  - 尽可能保持在 500 字符以内

```markdown
---
name: skill-name-with-hyphens
description: Use when [具体触发条件和症状]
---

# Skill 名称

## 概述
这是什么？核心原则 1-2 句。

## 适用场景
[决策不显然时加小流程图]
何时不用

## 核心模式
前后代码对比

## 快速参考
用于扫描常见操作的表格或列表

## 常见错误
什么会出错 + 修复
```

## Claude 搜索优化（CSO）

**对可发现性至关重要：** 未来的 Claude 需要找到你的 skill。

### 1. 丰富的 description 字段

**目的：** Claude 读取 description 来决定为给定任务加载哪些 skills。

**格式：** 以 "Use when..." 开头，聚焦触发条件。

**关键：Description = 何时用，而非 skill 做什么。**

**为什么：** 测试表明，当 description 总结了 skill 的工作流时，Claude 可能按照 description 做而非读取完整 skill 内容。

```yaml
# ❌ 差：总结了工作流
description: Use when executing plans - dispatches subagent per task with code review between tasks

# ✅ 好：仅触发条件，无工作流总结
description: Use when executing implementation plans with independent tasks in the current session
```

用具体触发条件、症状和场景来充实内容。永远不要总结 skill 的流程或工作流。

### 2. 关键词覆盖

使用 Claude 会搜索的词：错误消息、症状、同义词、工具名称。

### 3. Token 效率（关键）

**目标词数：**
- 入门工作流：每个 <150 词
- 频繁加载的 skills：总计 <200 词
- 其他 skills：<500 词（仍要简洁）

**技巧：** 将细节移至工具帮助、使用交叉引用、压缩示例、消除冗余。

## 流程图使用

**仅在以下情况使用流程图：**
- 非显然的决策点
- 可能过早停止的流程循环
- "何时用 A vs B"的决策

**永远不要对以下使用流程图：**
- 参考材料 → 表格、列表
- 代码示例 → Markdown 代码块
- 线性指令 → 编号列表

## 代码示例

**一个优秀的例子胜过许多平庸的例子**

好的例子：完整可运行、注释解释原因、来自真实场景、清晰展示模式。

## 铁律（与 TDD 相同）

```
没有先失败的测试，就没有 skill
```

这对新 skill 和对已有 skill 的编辑都适用。

没有例外——对"简单添加"、"只是加一节"、"文档更新"都不行。

## 防 Rationalization 的 Skill 加固

强制执行纪律的 skill（如 TDD）需要抵抗找借口。Agent 很聪明，在压力下会找到漏洞。

### 显式堵上每个漏洞

```markdown
❌ 差：测试前写代码？删掉。
✅ 好：测试前写代码？删掉。重新开始。
   没有例外：不要保留作为"参考"、不要在写测试时"改编"、不要看它、删的意思是删。
```

### 处理"精神 vs 字面"争论

尽早加入基础原则：**"违反规则的字面规定即是违反规则的精神。"**

### 建立合理化借口表

从基线测试中捕获借口。Agent 提出的每个借口都进入表格：

```markdown
| 借口 | 现实 |
|------|------|
| "太简单不值得测试" | 简单代码也会出错。测试只需 30 秒。 |
```

### 创建红旗列表

让 Agent 在找借口时能自我检查。

## Skill 的红-绿-重构

### 红：写失败测试（基线）
用 subagent 在没有 skill 的情况下运行压力场景。记录：他们做了什么选择？用了什么借口？哪些压力触发了违规？

### 绿：写最小 Skill
写针对那些具体借口的 skill。运行相同场景 WITH skill。Agent 现在应该遵从。

### 重构：堵上漏洞
Agent 发现了新借口？添加显式反驳。重复测试直到无懈可击。

## 反模式

- ❌ 叙事示例（太具体，不可复用）
- ❌ 多语言稀释（质量平庸，维护负担）
- ❌ 流程图中的代码（无法复制粘贴）
- ❌ 通用标签（helper1、step2：标签应有语义意义）

## Skill 创建清单（TDD 适配）

**红阶段：**
- [ ] 创建压力场景
- [ ] 无 skill 运行场景——逐字记录基线行为
- [ ] 识别借口/失败的模式

**绿阶段：**
- [ ] 名称仅使用字母、数字、连字符
- [ ] YAML frontmatter 含必需字段
- [ ] Description 以 "Use when..." 开头
- [ ] 全文散布关键词
- [ ] 清晰概述含核心原则
- [ ] 处理红阶段识别的具体基线失败
- [ ] With skill 运行场景——验证 agent 现在遵从

**重构阶段：**
- [ ] 识别测试中的新借口
- [ ] 添加显式反驳
- [ ] 从所有测试迭代建立合理化借口表
- [ ] 创建红旗列表
- [ ] 重复测试直到无懈可击

## 底线

**创建 skills 就是应用于流程文档的 TDD。**

同样的铁律。同样的循环。同样的好处。
