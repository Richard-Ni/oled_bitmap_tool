# OLED 点阵取模工具 (OLED Bitmap Tool)

这是一个基于 Flutter 开发的 OLED 点阵取模工具，专为嵌入式开发设计，支持 Linux 桌面平台。

## ✨ 功能特性

- **图形模式 (Graphic Mode)**:
  - 支持图片导入与二值化处理
  - 提供画笔、橡皮擦、直线、矩形、圆等绘图工具
  - 支持图像反色、镜像、旋转等操作
- **字符模式 (Character Mode)**:
  - 支持输入文字生成点阵数据
  - 可自定义字体、字号和偏移量
- **字库生成 (Font Library Generation)**:
  - 支持批量生成字库数据
- **代码生成**:
  - 实时预览取模结果
  - 支持 C51, Arduino, STM32 等多种常见格式
  - 可自定义取模方式（横向/纵向，高位/低位在前等）

## 📋 系统要求

- **操作系统**: Ubuntu 22.04 或更高版本 (推荐)，也支持 Debian 11+, Fedora 36+, Arch Linux 等。
- **Flutter SDK**: 3.24.5 或更高版本。

## 🛠️ 编译指南

### 1. 安装系统依赖

根据您的 Linux 发行版安装必要的开发库：

**Ubuntu/Debian:**

```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
```

**Fedora:**

```bash
sudo dnf install -y clang cmake ninja-build gtk3-devel xz-devel libstdc++-devel
```

**Arch Linux:**

```bash
sudo pacman -S --needed clang cmake ninja pkgconf gtk3 xz
```

### 2. 编译项目

确保您已安装 Flutter SDK 并配置好环境变量。

```bash
# 1. 进入项目目录
cd oled_bitmap_tool

# 2. 获取 Flutter 依赖
flutter pub get

# 3. 编译 Linux Release 版本
flutter build linux --release
```

### 3. 运行程序

编译完成后，可执行文件位于 `build/linux/x64/release/bundle/` 目录下：

```bash
./build/linux/x64/release/bundle/oled_bitmap_tool
```

## 🚀 快速安装 Flutter (如果尚未安装)

如果您还没有安装 Flutter，可以使用以下命令快速安装：

```bash
# 下载并解压 Flutter SDK
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
tar -xf flutter_linux_3.24.5-stable.tar.xz

# 配置环境变量 (临时生效)
export PATH="$PATH:$HOME/flutter/bin"

# 验证安装
flutter doctor
```

## 📄 许可证

本项目采用 MIT 许可证，详情请参阅 [LICENSE](LICENSE.txt) 文件。
