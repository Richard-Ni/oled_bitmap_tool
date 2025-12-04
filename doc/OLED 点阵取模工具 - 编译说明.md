# OLED 点阵取模工具 - 编译说明

## 📦 源代码包信息

**版本**: v2.3.0  
**发布日期**: 2025-12-04  
**开发框架**: Flutter 3.24.5  
**目标平台**: Linux x86_64 (Ubuntu 22.04+)

## 📋 系统要求

### 操作系统
- **Ubuntu 22.04** 或更高版本
- **其他 Linux 发行版**：Debian 11+, Fedora 36+, Arch Linux 等
- **架构**：x86_64 (64位)

### 必需软件
- **Flutter SDK**: 3.24.5 或更高版本
- **Dart SDK**: 包含在 Flutter 中
- **Git**: 用于版本控制（可选）

### 系统依赖库
以下是 Flutter Linux 桌面应用所需的系统库：

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y \
  clang \
  cmake \
  ninja-build \
  pkg-config \
  libgtk-3-dev \
  liblzma-dev \
  libstdc++-12-dev
```

```bash
# Fedora
sudo dnf install -y \
  clang \
  cmake \
  ninja-build \
  gtk3-devel \
  xz-devel \
  libstdc++-devel
```

```bash
# Arch Linux
sudo pacman -S --needed \
  clang \
  cmake \
  ninja \
  pkgconf \
  gtk3 \
  xz
```

## 🚀 快速开始

### 方法 1：使用已有 Flutter 环境

如果你已经安装了 Flutter SDK：

```bash
# 1. 解压源代码
tar -xzf oled_bitmap_tool_v2.3_source.tar.gz
cd oled_bitmap_tool

# 2. 检查 Flutter 环境
flutter doctor

# 3. 获取依赖
flutter pub get

# 4. 编译 Release 版本
flutter build linux --release

# 5. 运行程序
./build/linux/x64/release/bundle/oled_bitmap_tool
```

### 方法 2：从零开始安装 Flutter

如果你还没有安装 Flutter：

```bash
# 1. 下载 Flutter SDK
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz

# 2. 解压 Flutter
tar -xf flutter_linux_3.24.5-stable.tar.xz

# 3. 添加到 PATH（临时）
export PATH="$PATH:$HOME/flutter/bin"

# 4. 或者添加到 ~/.bashrc（永久）
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# 5. 检查 Flutter 环境
flutter doctor

# 6. 安装系统依赖（如果 flutter doctor 提示缺少）
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev

# 7. 解压源代码
cd ~
tar -xzf oled_bitmap_tool_v2.3_source.tar.gz
cd oled_bitmap_tool

# 8. 获取依赖
flutter pub get

# 9. 编译 Release 版本
flutter build linux --release

# 10. 运行程序
./build/linux/x64/release/bundle/oled_bitmap_tool
```

## 📂 源代码结构

```
oled_bitmap_tool/
├── lib/                              # 源代码目录
│   ├── main.dart                     # 主入口文件
│   ├── bitmap_model.dart             # 点阵数据模型
│   ├── bitmap_converter.dart         # 取模转换器
│   ├── drawing_tools.dart            # 绘图工具类
│   ├── text_renderer.dart            # 文字渲染器
│   ├── font_generator.dart           # 字库生成器
│   └── widgets/                      # UI 组件目录
│       ├── bitmap_editor_enhanced.dart    # 增强点阵编辑器
│       ├── settings_panel.dart            # 设置面板
│       ├── code_output_panel.dart         # 代码输出面板
│       ├── character_panel.dart           # 字符模式面板
│       └── font_library_panel.dart        # 字库生成面板
├── linux/                            # Linux 平台配置
│   ├── CMakeLists.txt                # CMake 构建配置
│   ├── my_application.cc             # 应用程序入口
│   └── flutter/                      # Flutter 引擎配置
├── pubspec.yaml                      # 项目配置文件
├── pubspec.lock                      # 依赖锁定文件
└── README.md                         # 项目说明文档
```

## 🔨 编译选项

### Debug 版本（开发调试）

```bash
# 编译 Debug 版本（包含调试信息，体积较大）
flutter build linux --debug

# 运行 Debug 版本
./build/linux/x64/debug/bundle/oled_bitmap_tool
```

### Release 版本（生产发布）

```bash
# 编译 Release 版本（优化性能，体积较小）
flutter build linux --release

# 运行 Release 版本
./build/linux/x64/release/bundle/oled_bitmap_tool
```

### Profile 版本（性能分析）

```bash
# 编译 Profile 版本（用于性能分析）
flutter build linux --profile

# 运行 Profile 版本
./build/linux/x64/profile/bundle/oled_bitmap_tool
```

## 📦 打包发布

### 创建发布包

```bash
# 编译 Release 版本
flutter build linux --release

# 打包为 tar.gz
cd build/linux/x64/release
tar -czf oled_bitmap_tool_linux_x64.tar.gz bundle/

# 或者从项目根目录打包
cd /path/to/oled_bitmap_tool
tar -czf oled_bitmap_tool_linux_x64.tar.gz -C build/linux/x64/release/bundle .
```

### 发布包内容

编译后的发布包包含：

```
bundle/
├── oled_bitmap_tool          # 可执行文件
├── lib/                      # 共享库
│   └── libflutter_linux_gtk.so
└── data/                     # 资源文件
    ├── icudtl.dat
    └── flutter_assets/
```

## 🐛 常见问题

### 问题 1：flutter: command not found

**原因**：Flutter 未添加到 PATH

**解决**：
```bash
# 临时添加
export PATH="$PATH:$HOME/flutter/bin"

# 永久添加
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

### 问题 2：缺少系统依赖

**现象**：
```
CMake Error: Could not find CMAKE_MAKE_PROGRAM
```

**解决**：
```bash
# Ubuntu/Debian
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev

# Fedora
sudo dnf install -y clang cmake ninja-build gtk3-devel

# Arch Linux
sudo pacman -S clang cmake ninja pkgconf gtk3
```

### 问题 3：GTK 版本不兼容

**现象**：
```
Package gtk+-3.0 was not found in the pkg-config search path
```

**解决**：
```bash
# 安装 GTK 3 开发库
sudo apt-get install libgtk-3-dev

# 检查 GTK 版本
pkg-config --modversion gtk+-3.0
```

### 问题 4：编译速度慢

**优化**：
```bash
# 使用多核编译（例如 4 核）
flutter build linux --release -j 4

# 或者设置环境变量
export FLUTTER_BUILD_PARALLEL=4
flutter build linux --release
```

### 问题 5：依赖下载失败

**原因**：网络问题或镜像源问题

**解决**：
```bash
# 使用国内镜像（中国大陆用户）
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# 清理缓存并重新获取
flutter clean
flutter pub get
```

### 问题 6：运行时缺少库

**现象**：
```
error while loading shared libraries: libgtk-3.so.0
```

**解决**：
```bash
# 安装运行时库
sudo apt-get install libgtk-3-0

# 检查缺少的库
ldd ./build/linux/x64/release/bundle/oled_bitmap_tool
```

## 🔍 验证编译

### 检查可执行文件

```bash
# 查看文件信息
file ./build/linux/x64/release/bundle/oled_bitmap_tool

# 预期输出：
# oled_bitmap_tool: ELF 64-bit LSB pie executable, x86-64, ...
```

### 检查依赖库

```bash
# 查看动态链接库
ldd ./build/linux/x64/release/bundle/oled_bitmap_tool

# 预期输出包含：
# libflutter_linux_gtk.so => ./lib/libflutter_linux_gtk.so
# libgtk-3.so.0 => /usr/lib/x86_64-linux-gnu/libgtk-3.so.0
# ...
```

### 测试运行

```bash
# 运行程序
./build/linux/x64/release/bundle/oled_bitmap_tool

# 如果成功，应该看到图形界面启动
```

## 📝 开发说明

### 运行开发版本

```bash
# 直接运行（热重载支持）
flutter run -d linux

# 在开发过程中，修改代码后按 'r' 热重载，按 'R' 热重启
```

### 代码格式化

```bash
# 格式化所有 Dart 代码
flutter format lib/

# 检查代码规范
flutter analyze
```

### 依赖管理

```bash
# 查看依赖树
flutter pub deps

# 更新依赖
flutter pub upgrade

# 检查过时的依赖
flutter pub outdated
```

## 🎯 项目依赖

### pubspec.yaml 主要依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2          # 状态管理
  image: ^4.2.0             # 图像处理
  file_picker: ^8.1.2       # 文件选择
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0     # 代码规范检查
```

## 🚀 性能优化

### 编译优化

```bash
# 启用 AOT 编译优化
flutter build linux --release --tree-shake-icons

# 减小体积（移除未使用的图标）
flutter build linux --release --split-debug-info=./debug-info
```

### 运行时优化

```bash
# 设置环境变量优化性能
export FLUTTER_ENGINE_SWITCH_PERFORMANCE_OVERLAY=true
./build/linux/x64/release/bundle/oled_bitmap_tool
```

## 📚 参考资料

### 官方文档
- [Flutter 官方文档](https://flutter.dev/docs)
- [Flutter Linux 桌面支持](https://docs.flutter.dev/platform-integration/linux/building)
- [Dart 语言指南](https://dart.dev/guides)

### 社区资源
- [Flutter 中文网](https://flutter.cn/)
- [Flutter GitHub](https://github.com/flutter/flutter)
- [Pub.dev 包管理](https://pub.dev/)

## 💡 开发建议

### IDE 推荐
- **VS Code** + Flutter 插件
- **Android Studio** + Flutter 插件
- **IntelliJ IDEA** + Flutter 插件

### 调试工具
```bash
# 启用 DevTools
flutter pub global activate devtools
flutter pub global run devtools

# 在另一个终端运行应用
flutter run -d linux
```

## 🎊 编译成功

如果一切顺利，你应该能够：

✅ 成功编译 Release 版本  
✅ 在 `build/linux/x64/release/bundle/` 找到可执行文件  
✅ 运行程序并看到图形界面  
✅ 使用所有功能（图形模式、字符模式、字库生成）

## 📞 获取帮助

如果遇到问题：

1. **检查 Flutter 环境**：`flutter doctor -v`
2. **清理并重新构建**：`flutter clean && flutter pub get && flutter build linux --release`
3. **查看详细日志**：`flutter build linux --release --verbose`
4. **检查系统依赖**：确保所有必需的库都已安装

---

**祝编译顺利！** 🎉

如有问题，请参考上述常见问题部分或查阅 Flutter 官方文档。
