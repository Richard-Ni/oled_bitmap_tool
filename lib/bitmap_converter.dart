/// 取模方式枚举
enum ScanMode {
  rowByRow, // 逐行
  columnByColumn, // 逐列
  rowColumn, // 行列
  columnRow, // 列行
}

/// 取模选项
class ConversionOptions {
  final ScanMode scanMode;
  final bool isPositive; // true=阴码(亮点为1), false=阳码(亮点为0)
  final bool isLsbFirst; // true=纵向(低位在前), false=倒向(高位在前)
  final bool isHex; // true=16进制, false=10进制
  final int bytesPerLine; // 每行输出字节数

  ConversionOptions({
    this.scanMode = ScanMode.rowByRow,
    this.isPositive = true,
    this.isLsbFirst = true,
    this.isHex = true,
    this.bytesPerLine = 16,
  });

  ConversionOptions copyWith({
    ScanMode? scanMode,
    bool? isPositive,
    bool? isLsbFirst,
    bool? isHex,
    int? bytesPerLine,
  }) {
    return ConversionOptions(
      scanMode: scanMode ?? this.scanMode,
      isPositive: isPositive ?? this.isPositive,
      isLsbFirst: isLsbFirst ?? this.isLsbFirst,
      isHex: isHex ?? this.isHex,
      bytesPerLine: bytesPerLine ?? this.bytesPerLine,
    );
  }
}

/// 点阵转换器
class BitmapConverter {
  /// 将点阵数据转换为字节数组
  static List<int> convertToBytes(
    List<List<bool>> bitmap,
    ConversionOptions options,
  ) {
    if (bitmap.isEmpty || bitmap[0].isEmpty) {
      return [];
    }

    final height = bitmap.length;
    final width = bitmap[0].length;

    switch (options.scanMode) {
      case ScanMode.rowByRow:
        return _convertRowByRow(bitmap, width, height, options);
      case ScanMode.columnByColumn:
        return _convertColumnByColumn(bitmap, width, height, options);
      case ScanMode.rowColumn:
        return _convertRowColumn(bitmap, width, height, options);
      case ScanMode.columnRow:
        return _convertColumnRow(bitmap, width, height, options);
    }
  }

  /// 逐行取模：横向逐行取点
  /// 从左到右，从上到下，每8行作为一个字节
  static List<int> _convertRowByRow(
    List<List<bool>> bitmap,
    int width,
    int height,
    ConversionOptions options,
  ) {
    List<int> bytes = [];

    // 按8行为一组进行处理
    for (int row = 0; row < height; row += 8) {
      for (int col = 0; col < width; col++) {
        int byte = 0;
        for (int bit = 0; bit < 8 && row + bit < height; bit++) {
          if (bitmap[row + bit][col]) {
            if (options.isLsbFirst) {
              byte |= (1 << bit); // 低位在前
            } else {
              byte |= (1 << (7 - bit)); // 高位在前
            }
          }
        }
        if (!options.isPositive) {
          byte = (~byte) & 0xFF; // 阳码：取反
        }
        bytes.add(byte);
      }
    }

    return bytes;
  }

  /// 逐列取模：纵向逐列取点
  /// 从上到下，从左到右，每8列作为一个字节
  static List<int> _convertColumnByColumn(
    List<List<bool>> bitmap,
    int width,
    int height,
    ConversionOptions options,
  ) {
    List<int> bytes = [];

    // 按8列为一组进行处理
    for (int col = 0; col < width; col += 8) {
      for (int row = 0; row < height; row++) {
        int byte = 0;
        for (int bit = 0; bit < 8 && col + bit < width; bit++) {
          if (bitmap[row][col + bit]) {
            if (options.isLsbFirst) {
              byte |= (1 << bit);
            } else {
              byte |= (1 << (7 - bit));
            }
          }
        }
        if (!options.isPositive) {
          byte = (~byte) & 0xFF;
        }
        bytes.add(byte);
      }
    }

    return bytes;
  }

  /// 行列取模：先横向取第一行的8个点，然后纵向取第二行的8个点
  /// 横向优先，纵向分组
  static List<int> _convertRowColumn(
    List<List<bool>> bitmap,
    int width,
    int height,
    ConversionOptions options,
  ) {
    List<int> bytes = [];

    // 按8列为一组，每组内逐行处理
    for (int col = 0; col < width; col += 8) {
      for (int row = 0; row < height; row++) {
        int byte = 0;
        for (int bit = 0; bit < 8 && col + bit < width; bit++) {
          if (bitmap[row][col + bit]) {
            if (options.isLsbFirst) {
              byte |= (1 << bit);
            } else {
              byte |= (1 << (7 - bit));
            }
          }
        }
        if (!options.isPositive) {
          byte = (~byte) & 0xFF;
        }
        bytes.add(byte);
      }
    }

    return bytes;
  }

  /// 列行取模：先纵向取第一列的前8个点，然后横向取第二列的前8个点
  /// 纵向优先，横向分组
  static List<int> _convertColumnRow(
    List<List<bool>> bitmap,
    int width,
    int height,
    ConversionOptions options,
  ) {
    List<int> bytes = [];

    // 按8行为一组，每组内逐列处理
    for (int row = 0; row < height; row += 8) {
      for (int col = 0; col < width; col++) {
        int byte = 0;
        for (int bit = 0; bit < 8 && row + bit < height; bit++) {
          if (bitmap[row + bit][col]) {
            if (options.isLsbFirst) {
              byte |= (1 << bit);
            } else {
              byte |= (1 << (7 - bit));
            }
          }
        }
        if (!options.isPositive) {
          byte = (~byte) & 0xFF;
        }
        bytes.add(byte);
      }
    }

    return bytes;
  }

  /// 生成 C 语言数组代码
  static String generateCCode(
    List<int> bytes,
    ConversionOptions options, {
    String arrayName = 'bitmap',
    int width = 0,
    int height = 0,
  }) {
    StringBuffer sb = StringBuffer();

    // 添加注释
    sb.writeln('// 点阵大小: ${width}x${height}');
    sb.writeln('// 取模方式: ${_getScanModeName(options.scanMode)}');
    sb.writeln('// 取模选项: ${options.isPositive ? "阴码" : "阳码"}, ${options.isLsbFirst ? "纵向" : "倒向"}, ${options.isHex ? "16进制" : "10进制"}');
    sb.writeln('// 字节总数: ${bytes.length}');
    sb.writeln();

    // 数组声明
    sb.write('const unsigned char $arrayName[${ bytes.length}] = {');

    // 输出数据
    for (int i = 0; i < bytes.length; i++) {
      if (i % options.bytesPerLine == 0) {
        sb.writeln();
        sb.write('    ');
      }

      if (options.isHex) {
        sb.write('0x${bytes[i].toRadixString(16).padLeft(2, '0').toUpperCase()}');
      } else {
        sb.write('${bytes[i].toString().padLeft(3, ' ')}');
      }

      if (i < bytes.length - 1) {
        sb.write(', ');
      }
    }

    sb.writeln();
    sb.writeln('};');

    return sb.toString();
  }

  /// 获取取模方式名称
  static String _getScanModeName(ScanMode mode) {
    switch (mode) {
      case ScanMode.rowByRow:
        return '逐行';
      case ScanMode.columnByColumn:
        return '逐列';
      case ScanMode.rowColumn:
        return '行列';
      case ScanMode.columnRow:
        return '列行';
    }
  }
}
