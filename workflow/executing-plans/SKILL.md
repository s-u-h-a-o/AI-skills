---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# 执行计划

## 概述

加载计划，批判性审查，执行所有任务，完成时报告。

**开始时声明：** "我正在使用 executing-plans skill 来实现此计划。"

**注意：** 告知 human partner，有 subagent 支持时 Superpowers 工作效果更好。如果 subagent 可用，使用 superpowers:subagent-driven-development 代替此 skill。

## 流程

### 步骤 1：加载并审查计划
1. 读取计划文件
2. 批判性审查——识别任何疑问或担忧
3. 如果有担忧：在开始前向 human partner 提出
4. 如果没有担忧：创建 TodoWrite 并继续

### 步骤 2：执行任务

对每个任务：
1. 标记为 in_progress
2. 严格遵循每一步（计划包含小口步骤）
3. 按指定运行验证
4. 标记为 completed

### 步骤 3：完成开发

所有任务完成并验证后：
- 声明："我正在使用 finishing-a-development-branch skill 来完成此工作。"
- **必须使用的子 skill：** Use superpowers:finishing-a-development-branch
- 遵循该 skill 验证测试、呈现选项、执行选择

## 何时停下并求助

**以下情况立即停止执行：**
- 遇到阻塞（缺失依赖、测试失败、指令不清）
- 计划有关键缺口阻止开始
- 不理解某个指令
- 验证反复失败

**寻求澄清而非猜测。**

## 何时重访更早步骤

- Partner 根据你的反馈更新了计划
- 根本方法需要重新思考

**不要硬闯阻塞**——停下来问。

## 记住
- 先批判性审查计划
- 严格遵循计划步骤
- 不跳过验证
- 当计划指示时参考 skills
- 阻塞时停下，不猜测
- 没有用户明确同意绝不在 main/master 分支上开始实现

## 集成

**需要的工作流 skills：**
- **superpowers:using-git-worktrees** — 确保隔离工作区
- **superpowers:writing-plans** — 创建此 skill 执行的计划
- **superpowers:finishing-a-development-branch** — 所有任务完成后完成开发
