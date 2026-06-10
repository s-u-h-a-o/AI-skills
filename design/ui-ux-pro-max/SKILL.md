---
name: ui-ux-pro-max
description: "UI/UX design intelligence. 67 styles, 96 palettes, 57 font pairings, 25 charts, 13 stacks (React, Next.js, Vue, Svelte, SwiftUI, React Native, Flutter, Tailwind, shadcn/ui). Actions: plan, build, create, design, implement, review, fix, improve, optimize, enhance, refactor, check UI/UX code. Projects: website, landing page, dashboard, admin panel, e-commerce, SaaS, portfolio, blog, mobile app, .html, .tsx, .vue, .svelte. Elements: button, modal, navbar, sidebar, card, table, form, chart. Styles: glassmorphism, claymorphism, minimalism, brutalism, neumorphism, bento grid, dark mode, responsive, skeuomorphism, flat design. Topics: color palette, accessibility, animation, layout, typography, font pairing, spacing, hover, shadow, gradient. Integrations: shadcn/ui MCP for component search and examples."
---
# UI/UX Pro Max - 设计智能

Web 和移动端应用的综合性设计指南。包含 67 种设计风格、96 套配色方案、57 种字体搭配、99 条 UX 规范、25 种图表类型，覆盖 13 个技术栈。可搜索的知识库，提供基于优先级的推荐。

## 适用场景

在以下情况下参考这些规范：
- 设计新的 UI 组件或页面
- 选择配色方案和字体排版
- 审查代码中的 UX 问题
- 构建落地页或仪表盘
- 实现无障碍访问需求

## 规范分类（按优先级）

| 优先级 | 分类 | 影响等级 | 领域 |
|--------|------|----------|------|
| 1 | 无障碍访问 | 严重 | `ux` |
| 2 | 触控与交互 | 严重 | `ux` |
| 3 | 性能 | 高 | `ux` |
| 4 | 布局与响应式 | 高 | `ux` |
| 5 | 字体与颜色 | 中 | `typography`, `color` |
| 6 | 动画 | 中 | `ux` |
| 7 | 风格选择 | 中 | `style`, `product` |
| 8 | 图表与数据 | 低 | `chart` |

## 快速参考

### 1. 无障碍访问（严重）

- `color-contrast` - 普通文本对比度不低于 4.5:1
- `focus-states` - 可交互元素需要可见的聚焦环
- `alt-text` - 有意义的图片需要添加描述性 alt 文本
- `aria-labels` - 纯图标按钮需要添加 aria-label
- `keyboard-nav` - Tab 键导航顺序应与视觉顺序一致
- `form-labels` - 使用 label 标签并关联 for 属性

### 2. 触控与交互（严重）

- `touch-target-size` - 触控目标最小 44x44px
- `hover-vs-tap` - 主要交互使用 click/tap 事件
- `loading-buttons` - 异步操作期间禁用按钮
- `error-feedback` - 在问题附近显示清晰的错误提示
- `cursor-pointer` - 可点击元素添加 cursor-pointer

### 3. 性能（高）

- `image-optimization` - 使用 WebP、srcset、懒加载
- `reduced-motion` - 检查 prefers-reduced-motion 偏好
- `content-jumping` - 为异步内容预留空间，避免布局跳动

### 4. 布局与响应式（高）

- `viewport-meta` - 设置 width=device-width initial-scale=1
- `readable-font-size` - 移动端正文字号不低于 16px
- `horizontal-scroll` - 确保内容适配视口宽度
- `z-index-management` - 定义 z-index 层级（10, 20, 30, 50）

### 5. 字体与颜色（中）

- `line-height` - 正文行高使用 1.5-1.75
- `line-length` - 每行限制在 65-75 个字符
- `font-pairing` - 标题与正文字体风格需协调搭配

### 6. 动画（中）

- `duration-timing` - 微交互时长 150-300ms
- `transform-performance` - 使用 transform/opacity，避免改变 width/height
- `loading-states` - 使用骨架屏或加载指示器

### 7. 风格选择（中）

- `style-match` - 设计风格需与产品类型匹配
- `consistency` - 所有页面使用统一的设计风格
- `no-emoji-icons` - 使用 SVG 图标，而非 emoji

### 8. 图表与数据（低）

- `chart-type` - 图表类型需与数据类型匹配
- `color-guidance` - 使用无障碍友好的配色方案
- `data-table` - 提供表格作为图表的无障碍替代

## 使用方式

使用下方的 CLI 工具搜索特定领域。

---

## 环境准备

检查 Python 是否已安装：

```bash
python3 --version || python --version
```

如果 Python 未安装，根据操作系统执行安装：

**macOS:**
```bash
brew install python3
```

**Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install python3
```

**Windows:**
```powershell
winget install Python.Python.3.12
```

---

## 如何使用此 Skill

当用户提出 UI/UX 相关需求（设计、构建、创建、实现、审查、修复、改进）时，按以下流程操作：

### 第 1 步：分析用户需求

从用户请求中提取关键信息：
- **产品类型**：SaaS、电商、作品集、仪表盘、落地页等
- **风格关键词**：极简、活泼、专业、优雅、暗色模式等
- **行业**：医疗、金融科技、游戏、教育等
- **技术栈**：React、Vue、Next.js 等，未指定时默认 `html-tailwind`

### 第 2 步：生成设计系统（必须执行）

**始终从 `--design-system` 开始**，获取带推理过程的完整设计建议：

```bash
python3 skills/ui-ux-pro-max/scripts/search.py "<产品类型> <行业> <关键词>" --design-system [-p "项目名称"]
```

此命令会：
1. 并行搜索 5 个领域（product、style、color、landing、typography）
2. 应用 `ui-reasoning.csv` 中的推理规则选择最佳匹配
3. 返回完整设计系统：模式、风格、颜色、字体、效果
4. 包含需要避免的反模式

**示例：**
```bash
python3 skills/ui-ux-pro-max/scripts/search.py "beauty spa wellness service" --design-system -p "Serenity Spa"
```

### 第 2b 步：持久化设计系统（主文件 + 覆写模式）

如需保存设计系统以支持跨会话的分层检索，添加 `--persist`：

```bash
python3 skills/ui-ux-pro-max/scripts/search.py "<查询>" --design-system --persist -p "项目名称"
```

这会创建：
- `design-system/MASTER.md` — 全局唯一真相源，包含所有设计规则
- `design-system/pages/` — 存放页面级覆写规则的文件夹

**带页面级覆写：**
```bash
python3 skills/ui-ux-pro-max/scripts/search.py "<查询>" --design-system --persist -p "项目名称" --page "dashboard"
```

还会额外创建：
- `design-system/pages/dashboard.md` — 该页面相对于主文件的定制规则

**分层检索机制：**
1. 构建特定页面（如"结算页"）时，先检查 `design-system/pages/checkout.md`
2. 如果页面文件存在，其规则**覆盖**主文件
3. 如果不存在，则完全使用 `design-system/MASTER.md`

### 第 3 步：按需补充详细搜索

获取设计系统后，可通过领域搜索获取更多细节：

```bash
python3 skills/ui-ux-pro-max/scripts/search.py "<关键词>" --domain <领域> [-n <最大结果数>]
```

**详细搜索的使用时机：**

| 需求 | 领域 | 示例 |
|------|------|------|
| 更多风格选项 | `style` | `--domain style "glassmorphism dark"` |
| 图表推荐 | `chart` | `--domain chart "real-time dashboard"` |
| UX 最佳实践 | `ux` | `--domain ux "animation accessibility"` |
| 替代字体 | `typography` | `--domain typography "elegant luxury"` |
| 落地页结构 | `landing` | `--domain landing "hero social-proof"` |

### 第 4 步：技术栈指南（默认：html-tailwind）

获取特定技术栈的实现最佳实践。用户未指定技术栈时，**默认使用 `html-tailwind`**。

```bash
python3 skills/ui-ux-pro-max/scripts/search.py "<关键词>" --stack html-tailwind
```

可用技术栈：`html-tailwind`、`react`、`nextjs`、`vue`、`svelte`、`swiftui`、`react-native`、`flutter`、`shadcn`、`jetpack-compose`

---

## 搜索参考

### 可用领域

| 领域 | 用途 | 关键词示例 |
|------|------|------------|
| `product` | 产品类型推荐 | SaaS、电商、作品集、医疗、美容、服务 |
| `style` | UI 风格、颜色、效果 | 玻璃态、极简、暗色模式、粗野主义 |
| `typography` | 字体搭配、Google Fonts | 优雅、活泼、专业、现代 |
| `color` | 按产品类型的配色方案 | saas、ecommerce、healthcare、beauty、fintech、service |
| `landing` | 页面结构、CTA 策略 | hero、hero-centric、testimonial、pricing、social-proof |
| `chart` | 图表类型、库推荐 | 趋势、对比、时间线、漏斗、饼图 |
| `ux` | 最佳实践、反模式 | 动画、无障碍访问、z-index、加载 |
| `react` | React/Next.js 性能 | 瀑布请求、打包、Suspense、memo、重渲染、缓存 |
| `web` | Web 界面规范 | aria、焦点、键盘、语义化、虚拟化 |
| `prompt` | AI 提示词、CSS 关键词 | （风格名称） |

### 可用技术栈

| 技术栈 | 侧重点 |
|--------|--------|
| `html-tailwind` | Tailwind 工具类、响应式、无障碍（默认） |
| `react` | 状态、Hooks、性能、设计模式 |
| `nextjs` | SSR、路由、图片、API Routes |
| `vue` | Composition API、Pinia、Vue Router |
| `svelte` | Runes、Stores、SvelteKit |
| `swiftui` | Views、State、Navigation、Animation |
| `react-native` | Components、Navigation、Lists |
| `flutter` | Widgets、State、Layout、Theming |
| `shadcn` | shadcn/ui 组件、主题、表单、模式 |
| `jetpack-compose` | Composable、Modifier、状态提升、重组 |

---

## 完整工作流示例

**用户需求：** "做一个专业护肤服务的落地页"

### 第 1 步：分析需求
- 产品类型：美容/水疗服务
- 风格关键词：优雅、专业、柔和
- 行业：美容/健康
- 技术栈：html-tailwind（默认）

### 第 2 步：生成设计系统（必须执行）

```bash
python3 skills/ui-ux-pro-max/scripts/search.py "beauty spa wellness service elegant" --design-system -p "Serenity Spa"
```

**输出：** 包含模式、风格、颜色、字体、效果和反模式的完整设计系统。

### 第 3 步：按需补充详细搜索

```bash
# 获取动画和无障碍访问的 UX 指南
python3 skills/ui-ux-pro-max/scripts/search.py "animation accessibility" --domain ux

# 如需替代字体方案
python3 skills/ui-ux-pro-max/scripts/search.py "elegant luxury serif" --domain typography
```

### 第 4 步：技术栈指南

```bash
python3 skills/ui-ux-pro-max/scripts/search.py "layout responsive form" --stack html-tailwind
```

**最后：** 综合设计系统 + 详细搜索结果，完成设计实现。

---

## 输出格式

`--design-system` 支持两种输出格式：

```bash
# ASCII 边框（默认）- 适合终端展示
python3 skills/ui-ux-pro-max/scripts/search.py "fintech crypto" --design-system

# Markdown - 适合生成文档
python3 skills/ui-ux-pro-max/scripts/search.py "fintech crypto" --design-system -f markdown
```

---

## 提高搜索效果的技巧

1. **关键词要具体** - "医疗 SaaS 仪表盘" 优于 "应用"
2. **多次搜索** - 不同关键词能揭示不同的设计洞察
3. **组合领域** - 风格 + 字体 + 颜色 = 完整设计系统
4. **始终检查 UX** - 搜索"动画"、"z-index"、"无障碍"以排查常见问题
5. **使用技术栈参数** - 获取特定技术栈的最佳实践
6. **迭代优化** - 首次搜索结果不理想时，尝试换用不同关键词

---

## 专业 UI 常见规范

以下是一些容易被忽略但会让 UI 显得不专业的问题：

### 图标与视觉元素

| 规范 | ✅ 正确做法 | ❌ 错误做法 |
|------|------------|------------|
| **禁用 emoji 图标** | 使用 SVG 图标（Heroicons、Lucide、Simple Icons） | 使用 🎨 🚀 ⚙️ 等 emoji 作为 UI 图标 |
| **稳定的悬停效果** | 悬停时使用颜色/透明度过渡 | 使用 scale 变换导致布局偏移 |
| **正确的品牌 logo** | 从 Simple Icons 查找官方 SVG | 猜测或使用错误的 logo 路径 |
| **统一的图标尺寸** | 使用固定 viewBox（24x24）+ w-6 h-6 | 混用不同尺寸的图标 |

### 交互与光标

| 规范 | ✅ 正确做法 | ❌ 错误做法 |
|------|------------|------------|
| **鼠标指针样式** | 所有可点击/可悬停的卡片添加 `cursor-pointer` | 交互元素使用默认光标 |
| **悬停反馈** | 提供视觉反馈（颜色、阴影、边框变化） | 无任何可交互提示 |
| **平滑过渡** | 使用 `transition-colors duration-200` | 瞬间切换状态或过渡过慢（>500ms） |

### 明暗模式对比度

| 规范 | ✅ 正确做法 | ❌ 错误做法 |
|------|------------|------------|
| **亮色模式毛玻璃卡片** | 使用 `bg-white/80` 或更高不透明度 | 使用 `bg-white/10`（过于透明） |
| **亮色模式文字对比度** | 正文使用 `#0F172A`（slate-900） | 正文使用 `#94A3B8`（slate-400） |
| **亮色模式次要文字** | 最低使用 `#475569`（slate-600） | 使用 gray-400 或更浅的颜色 |
| **边框可见性** | 亮色模式使用 `border-gray-200` | 使用 `border-white/10`（不可见） |

### 布局与间距

| 规范 | ✅ 正确做法 | ❌ 错误做法 |
|------|------------|------------|
| **浮动导航栏** | 添加 `top-4 left-4 right-4` 边距 | 紧贴 `top-0 left-0 right-0` |
| **内容内边距** | 为固定导航栏高度留出空间 | 让内容被固定元素遮挡 |
| **统一最大宽度** | 使用一致的 `max-w-6xl` 或 `max-w-7xl` | 混用不同容器宽度 |

---

## 交付前自检清单

交付 UI 代码前，逐项确认：

### 视觉质量
- [ ] 没有使用 emoji 作为图标（改用 SVG）
- [ ] 所有图标来自统一的图标集（Heroicons / Lucide）
- [ ] 品牌 logo 正确无误（已从 Simple Icons 核实）
- [ ] 悬停效果不会导致布局偏移
- [ ] 直接使用主题色类名（bg-primary），而非 var() 包装

### 交互
- [ ] 所有可点击元素都有 `cursor-pointer`
- [ ] 悬停状态提供清晰视觉反馈
- [ ] 过渡动画流畅（150-300ms）
- [ ] 键盘导航的聚焦状态可见

### 明暗模式
- [ ] 亮色模式下文字对比度达标（最低 4.5:1）
- [ ] 毛玻璃/透明元素在亮色模式下可见
- [ ] 两种模式下边框均可见
- [ ] 交付前两种模式均已测试

### 布局
- [ ] 浮动元素与边缘保持合理间距
- [ ] 没有内容被固定导航栏遮挡
- [ ] 在 375px、768px、1024px、1440px 下均能正常响应
- [ ] 移动端无水平滚动条

### 无障碍访问
- [ ] 所有图片都有 alt 描述
- [ ] 表单输入框都有 label 标签
- [ ] 颜色不是唯一的提示方式
- [ ] 遵循 `prefers-reduced-motion` 偏好
