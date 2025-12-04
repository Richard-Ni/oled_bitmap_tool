import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// 字符渲染器
class TextRenderer {
  /// 将文字渲染为图像
  static Future<img.Image?> renderText({
    required String text,
    required int width,
    required int height,
    String fontFamily = 'sans-serif',
    double fontSize = 16.0,
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    TextAlign textAlign = TextAlign.center,
    bool bold = false,
    bool italic = false,
  }) async {
    try {
      // 创建文字画笔
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.bold : fontWeight,
            fontStyle: italic ? FontStyle.italic : fontStyle,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: textAlign,
      );

      // 布局文字
      textPainter.layout(
        minWidth: 0,
        maxWidth: width.toDouble(),
      );

      // 创建画布
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // 绘制白色背景
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        Paint()..color = Colors.white,
      );

      // 计算文字位置（居中）
      final xOffset = (width - textPainter.width) / 2;
      final yOffset = (height - textPainter.height) / 2;

      // 绘制文字
      textPainter.paint(canvas, Offset(xOffset, yOffset));

      // 转换为图像
      final picture = recorder.endRecording();
      final uiImage = await picture.toImage(width, height);
      final byteData = await uiImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (byteData == null) {
        return null;
      }

      // 转换为 image 包的格式
      final image = img.Image.fromBytes(
        width: width,
        height: height,
        bytes: byteData.buffer,
        format: img.Format.uint8,
        numChannels: 4,
      );

      return image;
    } catch (e) {
      print('渲染文字失败: $e');
      return null;
    }
  }

  /// 获取单个字符的点阵数据
  static Future<List<List<bool>>?> renderCharacter({
    required String char,
    required int width,
    required int height,
    String fontFamily = 'sans-serif',
    double fontSize = 16.0,
    bool bold = false,
    bool italic = false,
  }) async {
    final image = await renderText(
      text: char,
      width: width,
      height: height,
      fontFamily: fontFamily,
      fontSize: fontSize,
      bold: bold,
      italic: italic,
    );

    if (image == null) {
      return null;
    }

    // 转换为点阵数据
    return _imageToBitmap(image);
  }

  /// 将图像转换为点阵数据
  static List<List<bool>> _imageToBitmap(img.Image image) {
    final width = image.width;
    final height = image.height;
    final bitmap = List.generate(
      height,
      (row) => List.generate(width, (col) => false),
    );

    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        final pixel = image.getPixel(col, row);
        
        // 计算灰度值
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final gray = (0.299 * r + 0.587 * g + 0.114 * b).round();

        // 二值化：灰度值小于128为黑色（true）
        bitmap[row][col] = gray < 128;
      }
    }

    return bitmap;
  }

  /// 获取系统可用字体列表
  static List<String> getAvailableFonts() {
    // Flutter 中获取系统字体比较复杂，这里提供常见字体列表
    return [
      'sans-serif',
      'serif',
      'monospace',
      'Arial',
      'Times New Roman',
      'Courier New',
      'Verdana',
      'Georgia',
      'Comic Sans MS',
      'Trebuchet MS',
      'Impact',
      'Ubuntu',
      'DejaVu Sans',
      'Liberation Sans',
      'Noto Sans',
      'Noto Sans CJK SC', // 中文字体
      'WenQuanYi Micro Hei', // 文泉驿微米黑
      'WenQuanYi Zen Hei', // 文泉驿正黑
    ];
  }

  /// 获取常用字符集
  static Map<String, String> getCharacterSets() {
    return {
      'ASCII 可见字符': _generateAsciiPrintable(),
      'ASCII 完整': _generateAsciiComplete(),
      '数字': '0123456789',
      '大写字母': 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
      '小写字母': 'abcdefghijklmnopqrstuvwxyz',
      '常用标点': ',.!?;:\'"()[]{}+-*/=<>@#\$%&',
      '常用汉字（一级）': _getCommonChineseLevel1(),
      '常用汉字（二级）': _getCommonChineseLevel2(),
    };
  }

  /// 生成 ASCII 可见字符 (32-126)
  static String _generateAsciiPrintable() {
    return String.fromCharCodes(
      List.generate(95, (index) => index + 32),
    );
  }

  /// 生成 ASCII 完整字符 (0-127)
  static String _generateAsciiComplete() {
    return String.fromCharCodes(
      List.generate(128, (index) => index),
    );
  }

  /// 获取常用汉字（一级，部分）
  static String _getCommonChineseLevel1() {
    return '的一是在不了有和人这中大为上个国我以要他时来用们生到作地于出就分对成会可主发年动同工也能下过子说产种面而方后多定行学法所民得经十三之进着等部度家电力里如水化高自二理起小物现实加量都两体制机当使点从业本去把性好应开它合还因由其些然前外天政四日那社义事平形相全表间样与关各重新线内数正心反你明看原又么利比或但质气第向道命此变条只没结解问意建月公无系军很情者最立代想已通并提直题党程展五果料象员革位入常文总次品式活设及管特件长求老头基资边流路级少图山统接知较将组见计别她手角期根论运农指几九区强放决西被干做必战先回则任取据处队南给色光门即保治北造百规热领七海口东导器压志世金增争济阶油思术极交受联什认六共权收证改清己美再采转更单风切打白教速花带安场身车例真务具万每目至达走积示议声报斗完类八离华名确才科张信马节话米整空元况今集温传土许步群广石记需段研界拉林律叫且究观越织装影算低持音众书布复容儿须际商非验连断深难近矿千周委素技备半办青省列习响约支般史感劳便团往酸历市克何除消构府称太准精值号率族维划选标写存候毛亲快效斯院查江型眼王按格养易置派层片始却专状育厂京识适属圆包火住调满县局照参红细引听该铁价严';
  }

  /// 获取常用汉字（二级，部分）
  static String _getCommonChineseLevel2() {
    return '龙程论礼社首勇术推岁择传师浪械批岛束刻齿剂丰抓洋际陆阿探族乱摇杂概竞卷怕迁绪密谈胜临旧准均负责贸预岩康遗误护岛批评岩察迹船货敌欲罪庄善播宪余帝刚纪益秘密圣宋忠扩晶雷露园游权床季宙衣笔倍浓翻组织宝趋奖沙洲软杯渐塔纳肉黄绝富慢散宜康秀闭爱脑筑摆贝艰奋盾垂扎牛羊鸡鸭兔猪狗猫鼠虎豹狼熊鹿象猴鹰鸽鸦鹅鸭鸡鹤鸿鹏鹰鹤凤凰麒麟龙虎豹狮象鹿马牛羊猪狗猫鼠';
  }
}
