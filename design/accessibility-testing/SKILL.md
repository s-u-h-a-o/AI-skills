---
name: accessibility-testing
description: Audit web interfaces against WCAG 2.1 AA/AAA standards, identify violations, and produce actionable remediation reports with code fixes.
license: MIT
metadata:
  author: AI Agent Skills Community
  version: 1.0.0
---

# 无障碍访问测试

此 skill 使 Agent 能够根据 Web 内容无障碍指南（WCAG 2.1）对网页和组件进行全面的 AA 和 AAA 级别无障碍审计。Agent 会在四大原则（可感知、可操作、可理解、健壮性）框架下识别违规项，并生成结构化的合规报告及具体代码修复方案。覆盖范围包括：自动化检查（颜色对比度、缺失的 alt 文本、ARIA 误用）、半自动化检查（键盘导航流程、焦点管理）以及手动检查指导（屏幕阅读器播报、认知负荷）。

## 工作流程

1. **定义审计范围和合规目标**：确定需要审计的页面、组件或用户流程，以及目标是 WCAG 2.1 AA（最常见的法律要求）还是 AAA（最高合规等级）。明确需要考虑的辅助技术：屏幕阅读器（Windows 上的 NVDA、macOS/iOS 上的 VoiceOver、Android 上的 TalkBack）、纯键盘导航和放大工具。

2. **运行自动化扫描**：使用 axe-core 或 Lighthouse 执行自动化无障碍分析。这些工具能自动检测约 30-40% 的 WCAG 违规项，包括缺失的 alt 属性、颜色对比度不足、表单标签缺失、重复 ID、无效的 ARIA 角色以及缺失的文档语言声明。记录每个违规项的 WCAG 标准引用（如 1.4.3 对比度最低要求）、严重程度（严重、重要、中等、轻微）、受影响的 HTML 元素及 CSS 选择器路径。

3. **执行键盘导航测试**：仅使用 Tab、Shift+Tab、Enter、Space、Escape 和方向键手动追踪每个交互流程。验证焦点顺序是否与视觉顺序一致、焦点指示器是否可见（最低 2px 轮廓，3:1 对比度）、模态对话框是否正确捕获焦点、是否存在键盘陷阱。记录键盘用户无法完成但鼠标用户可以完成的任何流程。

4. **使用屏幕阅读器测试**：至少使用一种屏幕阅读器浏览页面，验证所有内容是否正确播报。确认图片有有意义的 alt 文本（或装饰性图片使用 `alt=""`）、标题形成逻辑层级（无跳级）、存在地标元素（`<nav>`、`<main>`、`<aside>`）、动态内容更新通过 `aria-live` 区域播报。

5. **生成合规报告**：生成按 WCAG 原则和标准组织的结构化报告。每个违规项包含：标准编号和名称、严重程度、受影响元素的 HTML 片段、失败原因说明以及具体的代码修复方案。包含按原则分类的通过/失败统计汇总表及整体合规声明。

6. **提供修复代码**：为每个违规项提供修复前后的具体代码对比。按组件或页面区域对修复进行分组，使开发者可以系统性地解决而非逐一修补。

## 使用方式

向 Agent 提供 URL、HTML 代码块或 React/Vue 组件。指定目标合规等级（AA 或 AAA）及任何辅助技术要求。Agent 将审计内容并返回结构化报告及代码修复方案。

## 示例

### 示例 1：WCAG 合规审计报告

**用户需求**："审计此登录表单的 WCAG 2.1 AA 合规性。"

```html
<div class="login">
  <img src="logo.png">
  <input type="text" placeholder="Username">
  <input type="password" placeholder="Password">
  <div class="btn" onclick="login()">Sign In</div>
  <p style="color: #aaa; font-size: 12px;">Forgot your password?</p>
</div>
```

**Agent 回复 — 无障碍审计报告**：

| # | 标准 | 严重程度 | 元素 | 问题 |
|---|------|----------|------|------|
| 1 | 1.1.1 非文本内容 | 严重 | `<img src="logo.png">` | 图片缺少 `alt` 属性，屏幕阅读器无法描述。 |
| 2 | 1.3.1 信息与关系 | 严重 | `<input placeholder="Username">` | 输入框未关联 `<label>`。placeholder 文本不能替代标签。 |
| 3 | 1.3.1 信息与关系 | 严重 | `<input placeholder="Password">` | 同上，存在标签缺失问题。 |
| 4 | 1.4.3 对比度最低要求 | 重要 | `<p style="color: #aaa">` | 文字颜色 `#aaa` 在白色背景上对比度仅 2.32:1。AA 标准要求此字号文本对比度不低于 4.5:1。 |
| 5 | 2.1.1 键盘 | 严重 | `<div class="btn" onclick>` | `<div>` 无法通过键盘聚焦，用户无法 Tab 到达或激活此按钮。 |
| 6 | 4.1.2 名称、角色、值 | 严重 | `<div class="btn" onclick>` | 元素缺少语义化角色。屏幕阅读器将其播报为普通文本而非按钮。 |

**修复方案 — 修复后代码**：

```html
<form class="login" onsubmit="login(event)">
  <img src="logo.png" alt="Acme Corp 标志">

  <label for="username">用户名</label>
  <input id="username" type="text" autocomplete="username" required>

  <label for="password">密码</label>
  <input id="password" type="password" autocomplete="current-password" required>

  <button type="submit" class="btn">登录</button>

  <a href="/forgot-password" style="color: #595959; font-size: 14px;">
    忘记密码？
  </a>
</form>
```

修改说明：为图片添加 `alt`、将仅使用 placeholder 的输入框替换为显式 `<label>` 元素、将 `<div>` 替换为语义化 `<button>`、将链接颜色从 `#aaa`（2.32:1）改为 `#595959`（7.0:1）、将表单包裹在 `<form>` 中以正确处理提交、添加 `autocomplete` 属性。

### 示例 2：修复 React 组件

**用户需求**："修复此 React 通知组件的无障碍问题。"

**修复前（有可访问性问题）**：
```jsx
function Notification({ message, onClose }) {
  return (
    <div className="notification">
      <span>{message}</span>
      <span className="close-x" onClick={onClose}>✕</span>
    </div>
  );
}
```

**修复后（可访问）**：
```jsx
function Notification({ message, onClose }) {
  return (
    <div role="alert" aria-live="assertive" className="notification">
      <p>{message}</p>
      <button
        type="button"
        onClick={onClose}
        aria-label="关闭通知"
        className="close-btn"
      >
        ✕
      </button>
    </div>
  );
}
```

**修复说明**：(1) 添加 `role="alert"` 和 `aria-live="assertive"`，使屏幕阅读器在通知出现时立即播报。(2) 将 `<span onClick>` 替换为 `<button>`，使其可键盘聚焦并被播报为交互控件。(3) 添加 `aria-label="关闭通知"`，因为单独的 "✕" 字符无法告知屏幕阅读器用户按钮的用途。(4) 将内部 `<span>` 改为 `<p>` 以获得正确的文本语义。

## 最佳实践

- **先运行自动化工具，但不要仅依赖它们**：axe-core 大约能捕获 30-40% 的 WCAG 问题。剩余 60-70% 需要手动键盘测试、屏幕阅读器验证和认知审查。
- **用真实的屏幕阅读器测试，而非仅用 ARIA 校验器**：某个元素可能 ARIA 标记正确但产生的播报仍然令人困惑。VoiceOver 和 NVDA 可能对相同标记做出不同解读。
- **先修复严重和重要问题，再处理中等和轻微问题**：优先处理完全阻碍访问的违规项（缺少键盘可操作性、功能性图片无 alt 文本），而非美观问题（装饰性元素的轻微对比度不足）。
- **优先使用语义化 HTML，而非动辄使用 ARIA**：`<button>` 不需要 `role="button"`。`<nav>` 不需要 `role="navigation"`。ARIA 是语义化 HTML 不足时的修复工具，而非其替代品。
- **将无障碍检查纳入 CI 流水线**：在自动化测试中运行 axe-core 或 pa11y，使新违规项在上线前被捕获。对严重违规项构建失败。
- **记录无障碍决策**：当组件有意偏离某条指南时（如自定义组合框模式），记录原因及为保持等效访问所采用的替代方法。

## 边界情况

- **客户端路由的单页应用**：页面导航不会触发浏览器页面加载，因此屏幕阅读器不会收到新内容的通知。使用 `aria-live="polite"` 区域播报路由变化，或以编程方式将焦点移至新页面的 `<h1>`。
- **初始渲染后加载的动态内容**：页面加载后通过 JavaScript 注入的内容对屏幕阅读器不可见，除非包裹在 `aria-live` 区域中或显式管理焦点。Toast 通知使用 `aria-live="assertive"`；信息流更新使用 `aria-live="polite"`。
- **复杂数据表格**：合并单元格、嵌套表头或可排序列的表格需要显式的 `scope`、`headers` 和 `aria-sort` 属性。测试屏幕阅读器用户是否能理解每个数据单元格对应的表头。
- **自定义交互组件（滑块、日期选择器、组合框）**：这些没有原生 HTML 等价实现。严格按照 WAI-ARIA Authoring Practices 1.2 模式实现，包括每种组件类型指定的完整键盘交互模型。
- **第三方嵌入内容（iframe、组件）**：你无法修复第三方 iframe 内部的无障碍问题。记录该问题，为 `<iframe>` 添加描述性 `title` 属性，并在嵌入内容对用户流程至关重要时提供可访问的替代方案。
