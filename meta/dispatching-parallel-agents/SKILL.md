---
name: dispatching-parallel-agents
description: Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies
---

# 并行派发 Agent

## 概述

你将任务委派给具有隔离上下文的专门 agent。通过精确地构建他们的指令和上下文，确保他们保持聚焦并成功完成任务。他们不应该继承你的会话上下文或历史——你精确构建他们所需的内容。这也为你自己的协调工作保留了上下文。

当你有多个互不相关的失败（不同的测试文件、不同的子系统、不同的 bug）时，顺序调查它们浪费时间。每项调查是独立的，可以并行进行。

**核心原则：** 每个独立问题域派发一个 agent。让他们并发工作。

## 适用场景

```
多个失败？ → 是 → 它们是否独立？ → 否（相关）→ 单个 agent 调查所有
                      ↓ 是
                它们可以并行工作？ → 是 → 并行派发
                      ↓ 否
                 顺序 agent
```

**适用时：**
- 3 个以上测试文件因不同根因失败
- 多个子系统独立损坏
- 每个问题可以不依赖其他上下文独立理解
- 各调查之间无共享状态

**不适用时：**
- 失败是相关的（修复一个可能修复其他）
- 需要了解完整系统状态
- Agent 会互相干扰

## 模式

### 1. 识别独立领域

按出错的内容分组失败：
- 文件 A 测试：工具批准流程
- 文件 B 测试：批量完成行为
- 文件 C 测试：中止功能

每个领域是独立的——修复工具批准不影响中止功能测试。

### 2. 创建聚焦的 Agent 任务

每个 agent 获得：
- **具体范围：** 一个测试文件或子系统
- **清晰目标：** 使这些测试通过
- **约束：** 不要修改其他代码
- **预期输出：** 你发现了什么以及修复了什么的总结

### 3. 并行派发

```typescript
// 在 Claude Code / AI 环境中
Task("修复 agent-tool-abort.test.ts 失败")
Task("修复 batch-completion-behavior.test.ts 失败")
Task("修复 tool-approval-race-conditions.test.ts 失败")
// 所有三个并发运行
```

### 4. 审查与集成

Agent 返回后：
- 阅读每个总结
- 验证修复不冲突
- 运行完整测试套件
- 集成所有变更

## Agent Prompt 结构

好的 agent prompt 应：
1. **聚焦** - 一个清晰的问题域
2. **自包含** - 理解问题所需的所有上下文
3. **输出明确** - Agent 应该返回什么？

```markdown
修复 src/agents/agent-tool-abort.test.ts 中的 3 个失败测试：

1. "should abort tool with partial output capture" - 期望消息中包含 'interrupted at'
2. "should handle mixed completed and aborted tools" - 快速工具被中止而非完成
3. "should properly track pendingToolCount" - 期望 3 个结果但得到 0

这些是时序/竞态问题。你的任务：

1. 阅读测试文件，理解每个测试验证什么
2. 识别根因——时序问题还是实际 bug？
3. 修复方式：
   - 用基于事件的等待替换任意超时
   - 如果发现中止实现中的 bug，修复它们
   - 如果测试的是已改变的行为，调整测试预期

不要仅仅增加超时——找到真正的问题。

返回：你发现了什么以及修复了什么的总结。
```

## 常见错误

**❌ 太宽泛：** "修复所有测试"——agent 迷失方向
**✅ 具体：** "修复 agent-tool-abort.test.ts"——聚焦范围

**❌ 无上下文：** "修复竞态条件"——agent 不知道在哪里
**✅ 提供上下文：** 粘贴错误消息和测试名称

**❌ 无约束：** Agent 可能重构一切
**✅ 约束：** "不要修改生产代码"或"仅修复测试"

**❌ 输出模糊：** "修好它"——你不知道什么变了
**✅ 明确：** "返回根因和变更的总结"

## 不适用场景

**相关失败：** 修复一个可能修复其他——先一起调查
**需要完整上下文：** 理解需要看到整个系统
**探索性调试：** 你还不知道什么出了问题
**共享状态：** Agent 会干扰（编辑相同文件、使用相同资源）

## 会话中的真实示例

**场景：** 重大重构后 3 个文件 6 个测试失败

**失败：**
- agent-tool-abort.test.ts：3 个失败（时序问题）
- batch-completion-behavior.test.ts：2 个失败（工具未执行）
- tool-approval-race-conditions.test.ts：1 个失败（execution count = 0）

**决策：** 独立领域——中止逻辑与批量完成与竞态条件互不相关

**派发：**
```
Agent 1 → 修复 agent-tool-abort.test.ts
Agent 2 → 修复 batch-completion-behavior.test.ts
Agent 3 → 修复 tool-approval-race-conditions.test.ts
```

**结果：**
- Agent 1：用基于事件的等待替换超时
- Agent 2：修复事件结构 bug（threadId 位置错误）
- Agent 3：添加等待异步工具执行完成

**集成：** 所有修复独立，无冲突，完整套件通过

**节省的时间：** 3 个问题并行解决 vs 顺序解决

## 关键优势

1. **并行化** - 多项调查同时进行
2. **聚焦** - 每个 agent 范围窄，需跟踪的上下文更少
3. **独立性** - Agent 互不干扰
4. **速度** - 3 个问题在 1 个问题的时间内解决

## 验证

Agent 返回后：
1. **审查每个总结** - 理解什么变了
2. **检查冲突** - Agent 是否编辑了相同代码？
3. **运行完整套件** - 验证所有修复一起工作
4. **抽查** - Agent 可能犯系统性错误

## 实际效果

来自调试记录（2025-10-03）：
- 3 个文件 6 个失败
- 3 个 agent 并行派发
- 所有调查并发完成
- 所有修复成功集成
- Agent 之间零冲突
