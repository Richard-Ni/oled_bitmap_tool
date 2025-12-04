#!/bin/bash

set -e

# 获取脚本所在目录的绝对路径，并切换到项目根目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

APP_NAME="oled_bitmap_tool"
BUILD_DIR="build/linux/x64/release/bundle"
APP_DIR="AppDir"
OUTPUT_NAME="OLED_Bitmap_Tool-x86_64.AppImage"

# 1. 检查并安装依赖 (仅在本地运行且非 CI 环境时提示)
if [ -z "$CI" ]; then
    echo "正在检查依赖..."
    if ! command -v appimagetool &> /dev/null; then
        echo "正在下载 appimagetool..."
        wget https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
        chmod +x appimagetool
    fi
else
    # 在 CI 环境中，假设 appimagetool 已经准备好或者在此处下载
    if [ ! -f "appimagetool" ]; then
        wget https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
        chmod +x appimagetool
    fi
fi

# 2. 编译 Flutter 项目
echo "正在编译 Flutter 项目..."
flutter build linux --release

# 3. 创建 AppDir 结构
echo "正在创建 AppDir..."
rm -rf $APP_DIR
mkdir -p $APP_DIR/usr/bin
mkdir -p $APP_DIR/usr/lib/oled_bitmap_tool
mkdir -p $APP_DIR/usr/share/icons/hicolor/256x256/apps

# 4. 复制文件
echo "正在复制文件..."
# 将 bundle 内容复制到 /usr/lib/oled_bitmap_tool，保持结构完整
cp -r $BUILD_DIR/* $APP_DIR/usr/lib/oled_bitmap_tool/
# 创建软链接到 /usr/bin
ln -s ../lib/oled_bitmap_tool/oled_bitmap_tool $APP_DIR/usr/bin/oled_bitmap_tool

# 5. 准备图标
# 如果没有图标，生成一个默认的
if [ ! -f "assets/icon.png" ]; then
    echo "未找到图标，生成默认图标..."
    mkdir -p assets
    # 生成一个简单的 SVG 图标
    cat > assets/icon.svg <<EOF
<svg width="256" height="256" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
    <rect width="256" height="256" fill="#2196F3"/>
    <text x="128" y="160" font-size="150" text-anchor="middle" fill="white">O</text>
</svg>
EOF
    # 既然是 Flutter 工具，我们尽量不依赖 imagemagick。
    # 我们直接复制 svg 到图标目录，并命名为 oled_bitmap_tool.svg
    cp assets/icon.svg $APP_DIR/oled_bitmap_tool.svg
    cp assets/icon.svg $APP_DIR/usr/share/icons/hicolor/256x256/apps/oled_bitmap_tool.svg
    ICON_EXT="svg"
else
    cp assets/icon.png $APP_DIR/oled_bitmap_tool.png
    cp assets/icon.png $APP_DIR/usr/share/icons/hicolor/256x256/apps/oled_bitmap_tool.png
    ICON_EXT="png"
fi

# 6. 创建 .desktop 文件
echo "创建 .desktop 文件..."
cat > $APP_DIR/oled_bitmap_tool.desktop <<EOF
[Desktop Entry]
Name=OLED Bitmap Tool
Exec=oled_bitmap_tool
Icon=oled_bitmap_tool
Type=Application
Categories=Development;Utility;
Comment=OLED Dot Matrix Bitmap Tool
Terminal=false
EOF

# 7. 创建 AppRun
echo "创建 AppRun..."
cat > $APP_DIR/AppRun <<EOF
#!/bin/bash
HERE="\$(dirname "\$(readlink -f "\${0}")")"
exec "\${HERE}/usr/bin/oled_bitmap_tool" "\$@"
EOF
chmod +x $APP_DIR/AppRun

# 8. 打包
echo "正在打包 AppImage..."
# 使用 ARCH=x86_64 环境变量
export ARCH=x86_64
./appimagetool $APP_DIR $OUTPUT_NAME

echo "打包完成: $OUTPUT_NAME"
