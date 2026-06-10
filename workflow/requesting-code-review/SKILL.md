---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# 请求 Code Review

派发代码审查 subagent 在问题级联之前捕获它们。审查者获得精确构建的评估上下文——永远不是你会话的历史。这使审查者聚焦于工作产物而非你的思考过程，并为你保留上下文以继续工作。

**核心原则：** 尽早审查，经常审查。

## 何时请求审查

**强制：**
- Subagent 驱动开发中每个任务之后
- 完成主要功能后
- 合并到 main 之前

**可选但有价值：**
- 卡住时（新鲜视角）
- 重构前（基线检查）
- 修复复杂 bug 后

## 如何请求

**1. 获取 git SHA：**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # 或 origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. 派发代码审查 subagent：**

使用 Task 工具，填充 `code-reviewer.md` 模板。

**占位符：**
- `{DESCRIPTION}` - 你构建了什么的简要总结
- `{PLAN_OR_REQUIREMENTS}` - 它应该做什么
- `{BASE_SHA}` - 起始提交
- `{HEAD_SHA}` - 结束提交

**3. 根据反馈行动：**
- Critical 问题立即修复
- Important 问题在继续前修复
- Minor 问题记下后续修复
- 如果审查者错了，反驳（附推理）

## 与工作流集成

**Subagent 驱动开发：** 每个任务后审查，捕获问题后再累积。

**执行计划：** 每个任务后或自然检查点审查。

**临时开发：** 合并前审查，卡住时审查。

## 红旗

**永远不要：**
- 因为"这很简单"跳过审查
- 忽略 Critical 问题
- 在 Important 问题未修复时继续
- 与有效的技术反馈争论

**如果审查者错了：**
- 用技术推理反驳
- 展示证明其工作的代码/测试
- 请求澄清

参见模板：requesting-code-review/code-reviewer.md
