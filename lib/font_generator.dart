import 'dart:io';
import 'package:flutter/foundation.dart';
import 'text_renderer.dart';
import 'bitmap_converter.dart';

/// 字符信息
class CharacterInfo {
  final String char;
  final List<List<bool>> bitmap;
  final int width;
  final int height;
  final int offset; // 在字库中的偏移量

  CharacterInfo({
    required this.char,
    required this.bitmap,
    required this.width,
    required this.height,
    required this.offset,
  });
}

/// 字库生成器
class FontGenerator {
  /// 生成单个字符的字模
  static Future<String?> generateCharacterCode({
    required String char,
    required int width,
    required int height,
    required ConversionOptions options,
    String fontFamily = 'sans-serif',
    double fontSize = 16.0,
    bool bold = false,
    bool italic = false,
  }) async {
    final bitmap = await TextRenderer.renderCharacter(
      char: char,
      width: width,
      height: height,
      fontFamily: fontFamily,
      fontSize: fontSize,
      bold: bold,
      italic: italic,
    );

    if (bitmap == null) {
      return null;
    }

    final bytes = BitmapConverter.convertToBytes(bitmap, options);
    final charCode = char.codeUnitAt(0);
    final charName = _getCharName(char);

    return BitmapConverter.generateCCode(
      bytes,
      options,
      arrayName: 'char_${charName}_${charCode}',
      width: width,
      height: height,
    );
  }

  /// 生成字库
  static Future<FontLibraryResult> generateFontLibrary({
    required String characters,
    required int charWidth,
    required int charHeight,
    required ConversionOptions options,
    String fontFamily = 'sans-serif',
    double fontSize = 16.0,
    bool bold = false,
    bool italic = false,
    Function(int current, int total)? onProgress,
  }) async {
    final List<CharacterInfo> charInfos = [];
    final List<int> allBytes = [];
    final Map<String, int> indexMap = {};

    final chars = characters.split('');
    int currentOffset = 0;

    for (int i = 0; i < chars.length; i++) {
      final char = chars[i];
      
      // 跳过重复字符
      if (indexMap.containsKey(char)) {
        continue;
      }

      // 渲染字符
      final bitmap = await TextRenderer.renderCharacter(
        char: char,
        width: charWidth,
        height: charHeight,
        fontFamily: fontFamily,
        fontSize: fontSize,
        bold: bold,
        italic: italic,
      );

      if (bitmap == null) {
        continue;
      }

      // 转换为字节
      final bytes = BitmapConverter.convertToBytes(bitmap, options);

      // 记录信息
      charInfos.add(CharacterInfo(
        char: char,
        bitmap: bitmap,
        width: charWidth,
        height: charHeight,
        offset: currentOffset,
      ));

      indexMap[char] = currentOffset;
      allBytes.addAll(bytes);
      currentOffset += bytes.length;

      // 报告进度
      if (onProgress != null) {
        onProgress(i + 1, chars.length);
      }
    }

    return FontLibraryResult(
      characters: charInfos,
      bytes: allBytes,
      indexMap: indexMap,
      charWidth: charWidth,
      charHeight: charHeight,
    );
  }

  /// 生成字库代码
  static String generateFontLibraryCode({
    required FontLibraryResult result,
    required ConversionOptions options,
    String libraryName = 'font',
    bool generateIndex = true,
  }) {
    final sb = StringBuffer();

    // 文件头注释
    sb.writeln('/*');
    sb.writeln(' * 字库文件');
    sb.writeln(' * 字符数量: ${result.characters.length}');
    sb.writeln(' * 字符大小: ${result.charWidth}x${result.charHeight}');
    sb.writeln(' * 取模方式: ${_getScanModeName(options.scanMode)}');
    sb.writeln(' * 取模选项: ${options.isPositive ? "阴码" : "阳码"}, ${options.isLsbFirst ? "纵向" : "倒向"}, ${options.isHex ? "16进制" : "10进制"}');
    sb.writeln(' * 字节总数: ${result.bytes.length}');
    sb.writeln(' */');
    sb.writeln();

    // 字库数据
    sb.writeln('// 字库数据');
    sb.write('const unsigned char ${libraryName}_data[${result.bytes.length}] = {');
    
    for (int i = 0; i < result.bytes.length; i++) {
      if (i % options.bytesPerLine == 0) {
        sb.writeln();
        sb.write('    ');
      }

      if (options.isHex) {
        sb.write('0x${result.bytes[i].toRadixString(16).padLeft(2, '0').toUpperCase()}');
      } else {
        sb.write('${result.bytes[i].toString().padLeft(3, ' ')}');
      }

      if (i < result.bytes.length - 1) {
        sb.write(', ');
      }
    }

    sb.writeln();
    sb.writeln('};');
    sb.writeln();

    // 生成索引表
    if (generateIndex) {
      sb.writeln('// 字符索引表');
      sb.writeln('typedef struct {');
      sb.writeln('    unsigned int code;    // 字符编码');
      sb.writeln('    unsigned int offset;  // 数据偏移量');
      sb.writeln('} ${libraryName}_index_t;');
      sb.writeln();

      sb.writeln('const ${libraryName}_index_t ${libraryName}_index[${result.characters.length}] = {');
      
      for (int i = 0; i < result.characters.length; i++) {
        final charInfo = result.characters[i];
        final code = charInfo.char.codeUnitAt(0);
        sb.write('    {0x${code.toRadixString(16).padLeft(4, '0').toUpperCase()}, ${charInfo.offset}}');
        
        if (i < result.characters.length - 1) {
          sb.write(',');
        }
        
        sb.writeln('  // \'${_escapeChar(charInfo.char)}\'');
      }
      
      sb.writeln('};');
      sb.writeln();

      // 生成查找函数
      sb.writeln('// 查找字符偏移量');
      sb.writeln('int ${libraryName}_find_offset(unsigned int code) {');
      sb.writeln('    for (int i = 0; i < ${result.characters.length}; i++) {');
      sb.writeln('        if (${libraryName}_index[i].code == code) {');
      sb.writeln('            return ${libraryName}_index[i].offset;');
      sb.writeln('        }');
      sb.writeln('    }');
      sb.writeln('    return -1;  // 未找到');
      sb.writeln('}');
      sb.writeln();

      // 生成获取字符数据函数
      sb.writeln('// 获取字符数据');
      sb.writeln('const unsigned char* ${libraryName}_get_char(unsigned int code) {');
      sb.writeln('    int offset = ${libraryName}_find_offset(code);');
      sb.writeln('    if (offset >= 0) {');
      sb.writeln('        return &${libraryName}_data[offset];');
      sb.writeln('    }');
      sb.writeln('    return NULL;');
      sb.writeln('}');
    }

    // 字符列表（注释）
    sb.writeln();
    sb.writeln('/*');
    sb.writeln(' * 字符列表:');
    final charList = result.characters.map((c) => c.char).join('');
    // 每行60个字符
    for (int i = 0; i < charList.length; i += 60) {
      final end = (i + 60 < charList.length) ? i + 60 : charList.length;
      sb.writeln(' * ${charList.substring(i, end)}');
    }
    sb.writeln(' */');

    return sb.toString();
  }

  /// 获取字符名称（用于变量命名）
  static String _getCharName(String char) {
    final code = char.codeUnitAt(0);
    if (code >= 48 && code <= 57) return 'num'; // 0-9
    if (code >= 65 && code <= 90) return 'upper'; // A-Z
    if (code >= 97 && code <= 122) return 'lower'; // a-z
    if (code >= 0x4E00 && code <= 0x9FFF) return 'cjk'; // 中文
    return 'char';
  }

  /// 转义特殊字符
  static String _escapeChar(String char) {
    switch (char) {
      case '\n': return '\\n';
      case '\r': return '\\r';
      case '\t': return '\\t';
      case '\\': return '\\\\';
      case '\'': return '\\\'';
      case '"': return '\\"';
      default: return char;
    }
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

/// 字库生成结果
class FontLibraryResult {
  final List<CharacterInfo> characters;
  final List<int> bytes;
  final Map<String, int> indexMap;
  final int charWidth;
  final int charHeight;

  FontLibraryResult({
    required this.characters,
    required this.bytes,
    required this.indexMap,
    required this.charWidth,
    required this.charHeight,
  });

  /// 获取字符数量
  int get characterCount => characters.length;

  /// 获取总字节数
  int get totalBytes => bytes.length;

  /// 获取平均每字符字节数
  double get bytesPerChar => totalBytes / characterCount;
}
