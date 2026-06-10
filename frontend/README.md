# 🎨 前端开发

前端工程相关 skill，涵盖组件开发、样式方案、状态管理、性能优化、框架实践。

## Skill 清单

### `frontend-ui-engineering`

构建生产级 UI 界面。适用场景：创建组件、实现布局、管理状态，或任何需要看起来不像 AI 生成的前端代码。

> **场景示例：** 用户说“帮我做一个商品卡片组件” → 自动触发，产出带 loading/skeleton、错误处理、响应式适配的完整组件，而非一个简单的 `<div>` 卡片。

### `frontend-design`

有意识的、独特的视觉设计指导。帮助在配色、排版和布局上做出不像模板化 default 的选择。

> **场景示例：** 用户说“帮我设计一个 SaaS 落地页” → 自动触发，先确定产品定位和受众，选择非模板化的字体搭配和配色方案，产出有品牌辨识度的设计。

### `web-artifacts-builder`

React + TypeScript + Vite + Tailwind + shadcn/ui 项目脚手架，用于构建复杂的多组件 claude.ai HTML artifacts。

> **场景示例：** 用户说“帮我做一个带路由和状态管理的后台仪表盘 prototype” → 先用 `init-artifact.sh` 初始化项目，开发后再用 `bundle-artifact.sh` 打包成单个 HTML 交付。

### `state-management`

不可变状态管理模式：所有状态更新通过单一 setter 传入纯函数 `(prev: State) => State`，防止竞态和脏 UI。

> **场景示例：** 开发一个购物车功能时，多个组件（导航栏徽标、购物车列表、结账按钮）共享同一份状态 → 按照此模式集中管理，避免某处直接修改导致其他组件显示 stale 数据。

### `types-and-interfaces`

TypeScript 类型设计模式：discriminated union 表达多种返回类型、Zod schema 作为单一真相源、`z.infer<>` 自动推导类型。

> **场景示例：** 定义一个 API 响应类型，可能返回成功数据、验证错误或服务端错误三种形态 → 用 discriminated union 让 TypeScript 编译器强制处理每种分支，杜绝遗漏。
