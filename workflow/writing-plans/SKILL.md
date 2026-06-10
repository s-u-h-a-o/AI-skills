---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# 编写计划

## 概述

编写全面的实现计划，假设工程师对我们代码库零上下文且品味可疑。记录他们需要知道的一切：每个任务涉及哪些文件、代码、测试、他们可能需要查看的文档、如何测试。将整个计划呈现为小口任务。DRY、YAGNI、TDD、频繁提交。

假设他们是熟练开发者，但几乎不了解我们的工具集或问题域。假设他们不太了解好的测试设计。

**开始时声明：** "我正在使用 writing-plans skill 来创建实现计划。"

**保存计划到：** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`

## 范围检查

如果 spec 覆盖多个独立子系统，应在头脑风暴期间分解为子项目 spec。如果没有，建议将其分解为单独计划——每个子系统一个。每个计划应独立产出可工作、可测试的软件。

## 文件结构

定义任务前，先规划哪些文件将被创建或修改以及每个文件的职责。这是分解决策被锁定的地方。

- 设计具有清晰边界和明确定义接口的单元。
- 偏好更小、聚焦的文件而非太大做太多事的文件。
- 一起变化的文件应放在一起。按职责而非按技术层拆分。
- 在已有代码库中，遵循已有模式。

## 小口任务粒度

**每一步是一个操作（2-5 分钟）：**
- "写失败测试"——一步
- "运行它以确认失败"——一步
- "实现最少代码使测试通过"——一步
- "运行测试确认通过"——一步
- "提交"——一步

## 计划文档头

**每个计划必须以这个头开始：**

```markdown
# [功能名称] 实现计划

> **给 agent 工作者：** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 逐步实现此计划。

**目标：** [一句话描述构建什么]

**架构：** [2-3 句话描述方法]

**技术栈：** [关键技术/库]

---
```

## 任务结构

```markdown
### 任务 N：[组件名称]

**文件：**
- 创建：`exact/path/to/file.py`
- 修改：`exact/path/to/existing.py:123-145`
- 测试：`tests/exact/path/to/test.py`

- [ ] **步骤 1：写失败测试**
  ```python
  def test_specific_behavior():
      result = function(input)
      assert result == expected
  ```

- [ ] **步骤 2：运行测试验证失败**
  运行：`pytest tests/path/test.py::test_name -v`
  预期：FAIL

- [ ] **步骤 3：写最少实现**
  ```python
  def function(input):
      return expected
  ```

- [ ] **步骤 4：运行测试验证通过**
  预期：PASS

- [ ] **步骤 5：提交**
  ```bash
  git add tests/path/test.py src/path/file.py
  git commit -m "feat: add specific feature"
  ```
```

## 无占位符

每一步必须包含工程师所需的实际内容。这些是计划失败——绝不写：
- "TBD"、"TODO"、"稍后实现"、"填细节"
- "添加适当的错误处理" / "添加校验" / "处理边界情况"
- "为上述写测试"（无实际测试代码）
- "类似任务 N"（重复代码——工程师可能乱序阅读任务）
- 描述做什么但不展示如何做的步骤（代码步骤需要代码块）
- 引用未被任何任务定义的类型、函数或方法

## 记住
- 始终精确文件路径
- 每步完整代码
- 精确命令及预期输出
- DRY、YAGNI、TDD、频繁提交

## 自审

写完完整计划后，用新眼光审视 spec 并对照检查计划：

1. **Spec 覆盖：** 浏览 spec 中每个章节/需求。能指出哪个任务实现了它吗？列出任何遗漏。
2. **占位符扫描：** 搜索计划中的红旗——上面"无占位符"部分提到的任何模式。修复。
3. **类型一致性：** 后续任务中使用的类型、方法签名和属性名与前面任务中定义的一致吗？

发现问题就内联修复。如果发现 spec 需求没有对应任务，添加任务。

## 执行交接

保存计划后，提供执行选择：

**"计划完成，已保存到 `docs/superpowers/plans/<filename>.md`。两种执行方式：**

**1. Subagent 驱动（推荐）** — 每任务派发全新 subagent，任务间审查，快速迭代

**2. 内联执行** — 使用 executing-plans 在当前会话执行，批量执行含检查点

**选哪种？"**
