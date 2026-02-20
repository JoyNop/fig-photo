# FIG - 照片 CLI

[English Version](README.md) | [中文版](README_CN.md)

---

**作者**: HE-AN
**网站**: [WWW.HEAN.LIFE](https://www.hean.life)
**GitHub**: [https://github.com/JoyNop/fig-photo](https://github.com/JoyNop/fig-photo)

FIG 是一款轻量跨平台的命令行工具，用于整理相机照片。它可以自动区分 RAW 和 JPG 文件，并根据厂商组织 RAW 文件，支持恢复、预览模式，并生成详细日志。

---

## 功能特性

- 自动分类 RAW/JPG
- RAW 按相机厂商分类（Sony, Canon, Nikon, Fujifilm, Panasonic, Leica, Pentax, Unknown）
- 支持移动(move)和复制(copy)操作
- 交互式终端模式，方便不熟悉命令行的用户
- 支持恢复已处理文件到原位置
- 支持 dry-run 预览模式
- 显示处理进度条
- 生成 CSV 日志，记录文件路径、类型、厂商

---

## 安装

```bash
# 方式 1: 通过 Git 克隆仓库
git clone https://github.com/JoyNop/fig-photo.git
cd fig-photo

# 方式 2: 通过 Release 直接下载
# 打开: https://github.com/JoyNop/fig-photo/releases
# 下载压缩包后解压并进入目录

# 确保脚本可执行
chmod +x fig.sh

# 可选: 移动到 PATH 目录
sudo mv fig.sh /usr/local/bin/fig
```

---

## 使用方法

### 交互模式

```bash
./fig.sh
```

- 选择处理目录：当前目录或拖入其他目录
- 选择识别模式：自动(EXIF)或手动
- 手动模式下选择厂商
- 选择操作类型：移动或复制
- 可启用 dry-run 预览模式
- 可选择恢复上次处理的文件

### 命令参数模式

```bash
./fig.sh [选项]

选项:
  -d, --dir PATH        指定目标目录
  -m, --maker NAME      sony|canon|nikon|fuji|panasonic|leica|pentax|auto
  -a, --action TYPE     move|copy
  --dry-run             预览模式
  --restore             恢复已处理文件
  -h, --help            显示帮助
```

**示例:**

```bash
# 使用自动识别整理文件
./fig.sh --dir /Users/username/DCIM --maker auto --action move

# 仅预览操作
./fig.sh --dir /Users/username/DCIM --dry-run

# 恢复上次分类
./fig.sh --restore
```

---

## 日志说明

目标目录下会生成 CSV 文件 `fig-photo.csv`：

| 文件名 | 原路径 | 新路径 | 类型 | 厂商 |
| ------ | ------ | ------ | ---- | ---- |

方便追踪和恢复文件。

---

## 系统要求

- Bash (macOS, Linux, Windows Git Bash / WSL)
- 可选安装 `exiftool` 用于自动识别厂商
