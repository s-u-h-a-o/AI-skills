---
name: theme-factory
description: Toolkit for styling artifacts with a theme. These artifacts can be slides, docs, reportings, HTML landing pages, etc. There are 10 pre-set themes with colors/fonts that you can apply to any artifact that has been creating, or can generate a new theme on-the-fly.
license: Complete terms in LICENSE.txt
---

# 主题工厂 Skill

此 skill 提供一套精心策划的专业字体和颜色主题集合，每套主题都包含精心挑选的配色方案和字体搭配。选定主题后，可将其应用于任何制品。

## 用途

为演示文稿幻灯片等制品应用统一、专业的样式。每套主题包含：
- 一套带 hex 色值的协调配色方案
- 标题和正文的互补字体搭配
- 适合不同场景和受众的独特视觉识别

## 使用说明

为幻灯片或其他制品应用样式：

1. **展示主题预览**：显示 `theme-showcase.pdf` 文件，让用户直观地查看所有可用主题。不要对其进行任何修改；仅展示该文件供查看。
2. **询问用户选择**：询问要应用哪套主题到制品上
3. **等待选择确认**：获取用户对所选主题的明确确认
4. **应用主题**：选定主题后，将所选主题的颜色和字体应用到幻灯片/制品上

## 可用主题

以下 10 套主题可用，每套均在 `theme-showcase.pdf` 中展示：

1. **Ocean Depths**（海洋深处）- 专业沉稳的海洋主题
2. **Sunset Boulevard**（日落大道）- 温暖活力的日落色彩
3. **Forest Canopy**（森林华盖）- 自然沉稳的大地色调
4. **Modern Minimalist**（现代极简）- 干净现代的灰度色系
5. **Golden Hour**（黄金时刻）- 浓郁温暖的秋日调色
6. **Arctic Frost**（极地霜冻）- 清冷通透的冬日主题
7. **Desert Rose**（沙漠玫瑰）- 柔软精致的沙尘色调
8. **Tech Innovation**（科技创新）- 大胆现代的科技美学
9. **Botanical Garden**（植物园）- 清新自然的园林色彩
10. **Midnight Galaxy**（午夜银河）- 戏剧性的深邃宇宙色调

## 主题详情

每套主题在 `themes/` 目录中有完整定义，包括：
- 带 hex 色值的协调配色方案
- 标题和正文的互补字体搭配
- 适合不同场景和受众的独特视觉识别

## 应用流程

选定首选主题后：
1. 从 `themes/` 目录读取对应的主题文件
2. 在整个幻灯片中统一应用指定的颜色和字体
3. 确保适当的对比度和可读性
4. 在所有幻灯片中保持主题的视觉一致性

## 自定义主题

当现有主题均不适用于某个制品时，可以创建自定义主题。基于提供的输入信息，生成一套类似上述主题的新主题。为主题命名一个类似的、能表达字体/颜色组合意境的名称。根据任何基础描述来选择适当的颜色和字体。生成主题后，展示供审阅和确认。之后，按上述方式应用主题。
