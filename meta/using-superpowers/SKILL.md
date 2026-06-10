---
name: using-superpowers
description: Use when starting any conversation - establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions
---

<SUBAGENT-STOP>
如果你作为 subagent 被派发执行特定任务，跳过此 skill。
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
如果你认为某个 skill 有哪怕 1% 的可能性适用于你正在做的事情，你绝对必须调用该 skill。

如果某个 skill 适用于你的任务，你没有选择。必须使用它。

这事没有商量余地。这不是可选的。你不能给自己找理由逃避。
</EXTREMELY-IMPORTANT>

## 指令优先级

Superpowers skills 覆盖默认系统提示行为，但**用户指令始终优先**：

1. **用户的明确指令**（CLAUDE.md、AGENTS.md、直接请求）——最高优先级
2. **Superpowers skills**——在与默认系统行为冲突时覆盖
3. **默认系统提示**——最低优先级

如果 CLAUDE.md 或 AGENTS.md 说"不要用 TDD"，而 skill 说"始终用 TDD"，遵循用户指令。用户才是有控制权的人。

## 如何访问 Skills

**在 Claude Code 中：** 使用 `Skill` 工具。当你调用一个 skill 时，其内容被加载并呈现给你——直接遵循它。永远不要用 Read 工具读取 skill 文件。

**在 Copilot CLI / Gemini CLI / 其他环境中：** 查看你平台的文档了解 skills 如何加载。

## 使用 Skills

## 规则

**在任何响应或行动之前调用相关或被请求的 skill。** 即使只有 1% 的可能性某个 skill 可能适用，也意味着你应该调用该 skill 来检查。如果调用的 skill 结果证明不适合当前情况，你不需要使用它。

```
用户消息收到 → 任何 skill 可能适用？ → 是（哪怕 1%）→ 调用 Skill 工具 → 遵循 skill
                    ↓ 否
              直接响应
```

## 红旗

这些想法意味着停止——你在找借口：

| 想法 | 现实 |
|------|------|
| "这只是个简单问题" | 问题就是任务。检查 skills。 |
| "我需要先了解更多上下文" | Skill 检查在澄清问题之前。 |
| "我先探索一下代码库" | Skills 告诉你如何探索。先检查。 |
| "我可以快速检查 git/文件" | 文件缺乏会话上下文。检查 skills。 |
| "这不需要正式的 skill" | 如果 skill 存在，使用它。 |
| "我记得这个 skill" | Skills 会演进。阅读当前版本。 |
| "这个 skill 有点小题大做" | 简单的事会变复杂。使用它。 |
| "我先做这一件事" | 在做任何事之前先检查。 |

## Skill 优先级

当多个 skill 可能适用时，按此顺序：

1. **先流程类 skills**（头脑风暴、调试）——这些决定如何处理任务
2. **再实现类 skills**（前端设计、MCP 构建器）——这些指导执行

## Skill 类型

**刚性**（TDD、调试）：严格遵循。不要用"灵活应变"来规避纪律。

**柔性**（模式）：将原则适配到上下文。

Skill 本身会告诉你它是哪种。
