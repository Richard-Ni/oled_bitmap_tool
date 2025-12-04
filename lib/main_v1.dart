import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bitmap_model.dart';
import 'bitmap_converter.dart';
import 'widgets/bitmap_editor.dart';
import 'widgets/settings_panel.dart';
import 'widgets/code_output_panel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BitmapModel(),
      child: MaterialApp(
        title: 'OLED 点阵取模工具',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MainPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ConversionOptions _options = ConversionOptions();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OLED 点阵取模工具'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '关于',
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: Row(
        children: [
          // 左侧：设置面板
          SizedBox(
            width: 300,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: SettingsPanel(
                options: _options,
                onOptionsChanged: (newOptions) {
                  setState(() {
                    _options = newOptions;
                  });
                },
              ),
            ),
          ),

          // 中间：点阵编辑区域
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const BitmapEditor(),
            ),
          ),

          // 右侧：代码输出区域
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: CodeOutputPanel(options: _options),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示关于对话框
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OLED 点阵取模工具',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('版本: 1.0.0'),
            SizedBox(height: 16),
            Text('功能特性:'),
            SizedBox(height: 8),
            Text('• 支持导入图像并转换为点阵'),
            Text('• 可视化点阵编辑器'),
            Text('• 4种取模方式（逐行、逐列、行列、列行）'),
            Text('• 支持阴码/阳码、纵向/倒向'),
            Text('• 生成 C 语言数组代码'),
            Text('• 图像旋转、翻转、反转'),
            SizedBox(height: 16),
            Text('类似于 PCtoLCD2002 的取模软件'),
            Text('使用 Flutter 开发，支持 Linux 桌面'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
