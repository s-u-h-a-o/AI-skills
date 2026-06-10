---
name: web-artifacts-builder
description: Suite of tools for creating elaborate, multi-component claude.ai HTML artifacts using modern frontend web technologies (React, Tailwind CSS, shadcn/ui). Use for complex artifacts requiring state management, routing, or shadcn/ui components - not for simple single-file HTML/JSX artifacts.
license: Complete terms in LICENSE.txt
---

# Web Artifacts 构建器

要构建功能强大的 claude.ai 前端 artifacts，按以下步骤操作：
1. 使用 `scripts/init-artifact.sh` 初始化前端仓库
2. 通过编辑生成的代码开发你的 artifact
3. 使用 `scripts/bundle-artifact.sh` 将所有代码打包为单个 HTML 文件
4. 向用户展示 artifact
5. （可选）测试 artifact

**技术栈**：React 18 + TypeScript + Vite + Parcel（打包）+ Tailwind CSS + shadcn/ui

## 设计 & 风格指南

非常重要：为避免常被称为 "AI slop" 的问题，避免使用过多的居中布局、紫色渐变、统一圆角和 Inter 字体。

## 快速开始

### 第 1 步：初始化项目

运行初始化脚本创建新的 React 项目：
```bash
bash scripts/init-artifact.sh <project-name>
cd <project-name>
```

这会创建一个完全配置好的项目，包含：
- ✅ React + TypeScript（通过 Vite）
- ✅ Tailwind CSS 3.4.1 配合 shadcn/ui 主题系统
- ✅ 路径别名（`@/`）已配置
- ✅ 40+ 个 shadcn/ui 组件预安装
- ✅ 所有 Radix UI 依赖已包含
- ✅ Parcel 打包配置（通过 .parcelrc）
- ✅ Node 18+ 兼容（自动检测并固定 Vite 版本）

### 第 2 步：开发你的 Artifact

要构建 artifact，编辑生成的文件。参见下方**常见开发任务**的指引。

### 第 3 步：打包为单个 HTML 文件

将 React 应用打包为单个 HTML artifact：
```bash
bash scripts/bundle-artifact.sh
```

这会创建 `bundle.html`——一个自包含的 artifact，所有 JavaScript、CSS 和依赖都已内联。此文件可以直接在 Claude 对话中作为 artifact 分享。

**要求**：你的项目必须在根目录有一个 `index.html`。

**脚本做了什么**：
- 安装打包依赖（parcel、@parcel/config-default、parcel-resolver-tspaths、html-inline）
- 创建支持路径别名的 `.parcelrc` 配置
- 使用 Parcel 构建（无 source map）
- 使用 html-inline 将所有资源内联到单个 HTML 中

### 第 4 步：与用户分享 Artifact

最后，在对话中与用户分享打包好的 HTML 文件，让他们可以作为 artifact 查看。

### 第 5 步：测试/可视化 Artifact（可选）

注意：这是完全可选的一步。仅在有需要或被要求时执行。

要测试/可视化 artifact，使用可用工具（包括其他 Skill 或内置工具如 Playwright 或 Puppeteer）。一般来说，避免预先测试 artifact，因为它会在请求和看到成品 artifact 之间增加延迟。在展示 artifact 之后，如果被要求或出现问题再测试。

## 参考

- **shadcn/ui 组件**：https://ui.shadcn.com/docs/components
