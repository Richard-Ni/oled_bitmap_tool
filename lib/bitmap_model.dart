import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

/// 图像缩放模式
enum ImageScaleMode {
  /// 保持纵横比（居中，留白）
  aspectFit,
  /// 保持纵横比（填充，裁剪）
  aspectFill,
  /// 拉伸填充
  stretch,
  /// 平铺
  tile,
}

/// 点阵数据模型
class BitmapModel extends ChangeNotifier {
  int _width = 128;
  int _height = 64;
  List<List<bool>> _pixels = [];

  BitmapModel() {
    _initializePixels();
  }

  int get width => _width;
  int get height => _height;
  List<List<bool>> get pixels => _pixels;

  /// 初始化点阵数据（全部为 false）
  void _initializePixels() {
    _pixels = List.generate(
      _height,
      (row) => List.generate(_width, (col) => false),
    );
  }

  /// 设置点阵大小
  void setSize(int width, int height) {
    if (width <= 0 || height <= 0 || width > 1024 || height > 1024) {
      return;
    }

    _width = width;
    _height = height;
    _initializePixels();
    notifyListeners();
  }

  /// 设置指定位置的像素
  void setPixel(int row, int col, bool value) {
    if (row >= 0 && row < _height && col >= 0 && col < _width) {
      _pixels[row][col] = value;
      notifyListeners();
    }
  }

  /// 切换指定位置的像素
  void togglePixel(int row, int col) {
    if (row >= 0 && row < _height && col >= 0 && col < _width) {
      _pixels[row][col] = !_pixels[row][col];
      notifyListeners();
    }
  }

  /// 清空所有像素
  void clear() {
    _initializePixels();
    notifyListeners();
  }

  /// 反转所有像素
  void invert() {
    for (int row = 0; row < _height; row++) {
      for (int col = 0; col < _width; col++) {
        _pixels[row][col] = !_pixels[row][col];
      }
    }
    notifyListeners();
  }

  /// 水平翻转
  void flipHorizontal() {
    for (int row = 0; row < _height; row++) {
      _pixels[row] = _pixels[row].reversed.toList();
    }
    notifyListeners();
  }

  /// 垂直翻转
  void flipVertical() {
    _pixels = _pixels.reversed.toList();
    notifyListeners();
  }

  /// 顺时针旋转90度
  void rotateClockwise() {
    List<List<bool>> newPixels = List.generate(
      _width,
      (row) => List.generate(_height, (col) => false),
    );

    for (int row = 0; row < _height; row++) {
      for (int col = 0; col < _width; col++) {
        newPixels[col][_height - 1 - row] = _pixels[row][col];
      }
    }

    // 交换宽高
    int temp = _width;
    _width = _height;
    _height = temp;

    _pixels = newPixels;
    notifyListeners();
  }

  /// 逆时针旋转90度
  void rotateCounterClockwise() {
    List<List<bool>> newPixels = List.generate(
      _width,
      (row) => List.generate(_height, (col) => false),
    );

    for (int row = 0; row < _height; row++) {
      for (int col = 0; col < _width; col++) {
        newPixels[_width - 1 - col][row] = _pixels[row][col];
      }
    }

    // 交换宽高
    int temp = _width;
    _width = _height;
    _height = temp;

    _pixels = newPixels;
    notifyListeners();
  }

  /// 从图像文件加载
  Future<bool> loadFromFile(String filePath, {ImageScaleMode scaleMode = ImageScaleMode.stretch}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return false;
      }

      return loadFromImage(image, scaleMode: scaleMode);
    } catch (e) {
      print('加载图像失败: $e');
      return false;
    }
  }

  /// 从 Image 对象加载
  bool loadFromImage(img.Image image, {ImageScaleMode scaleMode = ImageScaleMode.stretch}) {
    try {
      img.Image processedImage;

      switch (scaleMode) {
        case ImageScaleMode.aspectFit:
          processedImage = _scaleAspectFit(image);
          break;
        case ImageScaleMode.aspectFill:
          processedImage = _scaleAspectFill(image);
          break;
        case ImageScaleMode.stretch:
          processedImage = _scaleStretch(image);
          break;
        case ImageScaleMode.tile:
          processedImage = _scaleTile(image);
          break;
      }

      // 转换为黑白点阵（二值化）
      for (int row = 0; row < _height; row++) {
        for (int col = 0; col < _width; col++) {
          final pixel = processedImage.getPixel(col, row);
          
          // 计算灰度值（使用加权平均）
          final r = pixel.r.toInt();
          final g = pixel.g.toInt();
          final b = pixel.b.toInt();
          final gray = (0.299 * r + 0.587 * g + 0.114 * b).round();

          // 二值化：灰度值大于128为白色（false），否则为黑色（true）
          _pixels[row][col] = gray < 128;
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      print('处理图像失败: $e');
      return false;
    }
  }

  /// 保持纵横比缩放（居中，留白）
  img.Image _scaleAspectFit(img.Image image) {
    // 计算缩放比例
    final scaleX = _width / image.width;
    final scaleY = _height / image.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // 计算缩放后的尺寸
    final scaledWidth = (image.width * scale).round();
    final scaledHeight = (image.height * scale).round();

    // 缩放图像
    final resized = img.copyResize(
      image,
      width: scaledWidth,
      height: scaledHeight,
      interpolation: img.Interpolation.nearest,
    );

    // 创建白色背景
    final result = img.Image(width: _width, height: _height);
    img.fill(result, color: img.ColorRgb8(255, 255, 255));

    // 计算居中位置
    final offsetX = (_width - scaledWidth) ~/ 2;
    final offsetY = (_height - scaledHeight) ~/ 2;

    // 将缩放后的图像复制到中心
    img.compositeImage(result, resized, dstX: offsetX, dstY: offsetY);

    return result;
  }

  /// 保持纵横比缩放（填充，裁剪）
  img.Image _scaleAspectFill(img.Image image) {
    // 计算缩放比例
    final scaleX = _width / image.width;
    final scaleY = _height / image.height;
    final scale = scaleX > scaleY ? scaleX : scaleY;

    // 计算缩放后的尺寸
    final scaledWidth = (image.width * scale).round();
    final scaledHeight = (image.height * scale).round();

    // 缩放图像
    final resized = img.copyResize(
      image,
      width: scaledWidth,
      height: scaledHeight,
      interpolation: img.Interpolation.nearest,
    );

    // 计算裁剪位置（居中裁剪）
    final offsetX = (scaledWidth - _width) ~/ 2;
    final offsetY = (scaledHeight - _height) ~/ 2;

    // 裁剪图像
    final result = img.copyCrop(
      resized,
      x: offsetX,
      y: offsetY,
      width: _width,
      height: _height,
    );

    return result;
  }

  /// 拉伸填充
  img.Image _scaleStretch(img.Image image) {
    return img.copyResize(
      image,
      width: _width,
      height: _height,
      interpolation: img.Interpolation.nearest,
    );
  }

  /// 平铺
  img.Image _scaleTile(img.Image image) {
    final result = img.Image(width: _width, height: _height);
    img.fill(result, color: img.ColorRgb8(255, 255, 255));

    // 计算需要平铺的次数
    final tilesX = (_width / image.width).ceil();
    final tilesY = (_height / image.height).ceil();

    // 平铺图像
    for (int ty = 0; ty < tilesY; ty++) {
      for (int tx = 0; tx < tilesX; tx++) {
        final dstX = tx * image.width;
        final dstY = ty * image.height;

        // 计算要复制的区域大小
        final copyWidth = (dstX + image.width > _width) ? _width - dstX : image.width;
        final copyHeight = (dstY + image.height > _height) ? _height - dstY : image.height;

        if (copyWidth > 0 && copyHeight > 0) {
          // 如果需要裁剪，先裁剪再复制
          if (copyWidth < image.width || copyHeight < image.height) {
            final cropped = img.copyCrop(
              image,
              x: 0,
              y: 0,
              width: copyWidth,
              height: copyHeight,
            );
            img.compositeImage(result, cropped, dstX: dstX, dstY: dstY);
          } else {
            img.compositeImage(result, image, dstX: dstX, dstY: dstY);
          }
        }
      }
    }

    return result;
  }

  /// 导出为 Image 对象
  img.Image exportToImage() {
    final image = img.Image(width: _width, height: _height);

    for (int row = 0; row < _height; row++) {
      for (int col = 0; col < _width; col++) {
        final color = _pixels[row][col]
            ? img.ColorRgb8(0, 0, 0) // 黑色
            : img.ColorRgb8(255, 255, 255); // 白色
        image.setPixel(col, row, color);
      }
    }

    return image;
  }

  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    int blackPixels = 0;
    for (var row in _pixels) {
      for (var pixel in row) {
        if (pixel) blackPixels++;
      }
    }

    return {
      'width': _width,
      'height': _height,
      'totalPixels': _width * _height,
      'blackPixels': blackPixels,
      'whitePixels': _width * _height - blackPixels,
      'fillRate': (blackPixels / (_width * _height) * 100).toStringAsFixed(2),
    };
  }
}
