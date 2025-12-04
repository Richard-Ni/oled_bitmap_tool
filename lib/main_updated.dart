import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bitmap_model.dart';
import 'bitmap_converter.dart';
import 'widgets/bitmap_editor.dart';
import 'widgets/settings_panel.dart';
import 'widgets/code_output_panel.dart';
import 'widgets/character_panel.dart';
import 'widgets/font_library_panel.dart';

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

enum WorkMode {
  graphic, // 图形模式
  character, // 字符模式
  fontLibrary, // 字库生成
}

class _MainPageState extends State<MainPage> {
  ConversionOptions _options = ConversionOptions();
  WorkMode _currentMode = WorkMode.graphic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OLED 点阵取模工具'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 模式切换
          SegmentedButton<WorkMode>(
            segments: const [
              ButtonSegment(
                value: WorkMode.graphic,
                label: Text('图形模式'),
                icon: Icon(Icons.image),
              ),
              ButtonSegment(
                value: WorkMode.character,
                label: Text('字符模式'),
                icon: Icon(Icons.text_fields),
              ),
              ButtonSegment(
                value: WorkMode.fontLibrary,
                label: Text('字库生成'),
                icon: Icon(Icons.library_books),
              ),
            ],
            selected: {_currentMode},
            onSelectionChanged: (Set<WorkMode> newSelection) {
              setState(() {
                _currentMode = newSelection.first;
              });
            },
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '关于',
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// 构建主体内容
  Widget _buildBody() {
    switch (_currentMode) {
      case WorkMode.graphic:
        return _buildGraphicMode();
      case WorkMode.character:
        return _buildCharacterMode();
      case WorkMode.fontLibrary:
        return _buildFontLibraryMode();
    }
  }

  /// 构建图形模式界面
  Widget _buildGraphicMode() {
    return Row(
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
    );
  }

  /// 构建字符模式界面
  Widget _buildCharacterMode() {
    return Row(
      children: [
        // 左侧：字符设置面板
        SizedBox(
          width: 300,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: const CharacterPanel(),
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
    );
  }

  /// 构建字库生成模式界面
  Widget _buildFontLibraryMode() {
    return Row(
      children: [
        // 左侧和中间：字库设置面板
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: FontLibraryPanel(options: _options),
          ),
        ),

        // 右侧：取模设置
        SizedBox(
          width: 300,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '取模设置',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 取模方式
                  const Text(
                    '取模方式',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<ScanMode>(
                    title: const Text('逐行'),
                    value: ScanMode.rowByRow,
                    groupValue: _options.scanMode,
                    onChanged: (value) {
                      setState(() {
                        _options = _options.copyWith(scanMode: value);
                      });
                    },
                  ),
                  RadioListTile<ScanMode>(
                    title: const Text('逐列'),
                    value: ScanMode.columnByColumn,
                    groupValue: _options.scanMode,
                    onChanged: (value) {
                      setState(() {
                        _options = _options.copyWith(scanMode: value);
                      });
                    },
                  ),
                  RadioListTile<ScanMode>(
                    title: const Text('行列'),
                    value: ScanMode.rowColumn,
                    groupValue: _options.scanMode,
                    onChanged: (value) {
                      setState(() {
                        _options = _options.copyWith(scanMode: value);
                      });
                    },
                  ),
                  RadioListTile<ScanMode>(
                    title: const Text('列行'),
                    value: ScanMode.columnRow,
                    groupValue: _options.scanMode,
                    onChanged: (value) {
                      setState(() {
                        _options = _options.copyWith(scanMode: value);
                      });
                    },
                  ),

                  const Divider(),

                  // 取模选项
                  const Text(
                    '取模选项',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SwitchListTile(
                    title: const Text('阴码'),
                    subtitle: const Text('亮点为1'),
                    value: _options.isPositive,
                    onChanged: (value) {
                      setState(() {
                        _options = _options.copyWith(isPositive: value);
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('纵向'),
                    subtitle: const Text('低位在前'),
                    value: _options.isLsbFirst,
                    onChanged: (value) {
                      setState(() {
                        _options = _options.copyWith(isLsbFirst: value);
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('16进制'),
                    value: _options.isHex,
                    onChanged: (value) {
                      setState(() {
                        _options = _options.copyWith(isHex: value);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 显示关于对话框
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于'),
        content: const SingleChildScrollView(
          child: Column(
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
              Text('版本: 2.0.0'),
              SizedBox(height: 16),
              Text('功能特性:'),
              SizedBox(height: 8),
              Text('• 图形模式：导入图像并转换为点阵'),
              Text('• 字符模式：输入文字自动生成字模'),
              Text('• 字库生成：批量生成字符字库'),
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
