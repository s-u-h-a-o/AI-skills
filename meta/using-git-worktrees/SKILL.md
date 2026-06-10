---
name: using-git-worktrees
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans - ensures an isolated workspace exists via native tools or git worktree fallback
---

# 使用 Git Worktrees

## 概述

确保工作在隔离的工作区中进行。优先使用平台原生的 worktree 工具。仅当没有原生工具可用时才回退到手动 git worktree。

**核心原则：** 先检测已有隔离。然后用原生工具。然后回退到 git。永远不要对抗 harness。

**开始时声明：** "我正在使用 using-git-worktrees skill 来设置隔离工作区。"

## 步骤 0：检测已有隔离

**在创建任何东西之前，检查是否已在隔离工作区中。**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**子模块守卫：** `GIT_DIR != GIT_COMMON` 在 git 子模块内部也为真。在得出"已在 worktree 中"结论之前，验证不在子模块中：

```bash
# 如果返回路径，则在子模块中，而非 worktree——视作普通仓库
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**如果 `GIT_DIR != GIT_COMMON`（且非子模块）：** 已在链接 worktree 中。跳到步骤 3（项目设置）。不要创建另一个 worktree。

**如果 `GIT_DIR == GIT_COMMON`（或在子模块中）：** 在普通仓库检出中。

用户是否已在指令中表明 worktree 偏好？如果没有，在创建 worktree 前征求同意：

> "你希望我设置一个隔离的 worktree 吗？它可以保护你的当前分支免受变更影响。"

## 步骤 1：创建隔离工作区

### 1a. 原生 Worktree 工具（优先）

用户已要求隔离工作区（步骤 0 同意）。你是否已有创建 worktree 的方式？它可能叫 `EnterWorktree`、`WorktreeCreate`、`/worktree` 命令或 `--worktree` 标志。如果有，使用它并跳到步骤 3。

仅在步骤 1a 不适用时才进入步骤 1b。

### 1b. Git Worktree 回退

**仅在步骤 1a 不适用时使用**——你没有可用的原生 worktree 工具。

#### 目录选择

按此优先级顺序。用户明确偏好始终优于观察到的文件系统状态。

1. 检查指令中是否有声明的 worktree 目录偏好
2. 检查已有的项目本地 worktree 目录（`.worktrees/` 优先于 `worktrees/`）
3. 检查已有的全局目录（`~/.config/superpowers/worktrees/<项目>/`）
4. 默认到项目根目录下的 `.worktrees/`

#### 安全验证（仅项目本地目录）

创建 worktree 前必须验证目录已在 .gitignore 中：

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**如果未被忽略：** 添加到 .gitignore，提交变更，然后继续。

#### 创建 Worktree

```bash
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**沙箱回退：** 如果 `git worktree add` 因权限错误失败（沙箱拒绝），告知用户沙箱阻止了 worktree 创建，改为当前目录工作。

## 步骤 3：项目设置

自动检测并运行适当的设置：

```bash
# Node.js
if [ -f package.json ]; then npm install; fi
# Rust
if [ -f Cargo.toml ]; then cargo build; fi
# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
# Go
if [ -f go.mod ]; then go mod download; fi
```

## 步骤 4：验证干净基线

运行测试确保工作区从干净状态开始。如果测试失败：报告失败，询问是继续还是调查。如果通过：报告就绪。

## 快速参考

| 情况 | 操作 |
|------|------|
| 已在链接 worktree 中 | 跳过创建 |
| 在子模块中 | 视作普通仓库 |
| 原生 worktree 工具可用 | 使用它 |
| 无原生工具 | Git worktree 回退 |
| `.worktrees/` 存在 | 使用它（验证已忽略） |
| 目录未被忽略 | 添加到 .gitignore + 提交 |
| 创建时权限错误 | 沙箱回退，原地工作 |
| 基线测试失败 | 报告失败 + 询问 |

## 常见错误

### 对抗 harness
- **问题：** 平台已提供隔离时使用 `git worktree add`
- **修复：** 步骤 0 检测已有隔离，步骤 1a 优先使用原生工具

### 跳过检测
- **问题：** 在已有 worktree 内创建嵌套 worktree
- **修复：** 创建任何东西前始终运行步骤 0

### 跳过忽略验证
- **问题：** Worktree 内容被跟踪，污染 git status
- **修复：** 创建项目本地 worktree 前始终使用 `git check-ignore`

## 红旗

**永远不要：**
- 步骤 0 检测到已有隔离时创建 worktree
- 有原生 worktree 工具时使用 `git worktree add`（这是第 1 错误）
- 跳过步骤 1a 直接跳到步骤 1b 的 git 命令
- 未经验证忽略就创建 worktree（项目本地）
- 跳过基线测试验证
- 不询问就在失败测试上继续

**始终要：**
- 先运行步骤 0 检测
- 优先原生工具而非 git 回退
- 遵循目录优先级：已有 > 全局 > 指令文件 > 默认
- 对项目本地目录验证忽略
- 自动检测并运行项目设置
- 验证干净测试基线
