import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../text_renderer.dart';
import '../font_generator.dart';
import '../bitmap_converter.dart';

/// 字库生成面板
class FontLibraryPanel extends StatefulWidget {
  final ConversionOptions options;

  const FontLibraryPanel({
    super.key,
    required this.options,
  });

  @override
  State<FontLibraryPanel> createState() => _FontLibraryPanelState();
}

class _FontLibraryPanelState extends State<FontLibraryPanel> {
  final TextEditingController _charactersController = TextEditingController();
  final TextEditingController _widthController = TextEditingController(text: '16');
  final TextEditingController _heightController = TextEditingController(text: '16');
  final TextEditingController _libraryNameController = TextEditingController(text: 'font');
  
  String _selectedFont = 'sans-serif';
  double _fontSize = 14.0;
  bool _bold = false;
  bool _italic = false;
  bool _generateIndex = true;
  bool _isGenerating = false;
  double _progress = 0.0;
  String _statusText = '';
  
  FontLibraryResult? _result;
  String _generatedCode = '';

  @override
  void dispose() {
    _charactersController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _libraryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 字符集输入
                _buildSection(
                  '字符集',
                  [
                    TextField(
                      controller: _charactersController,
                      decoration: const InputDecoration(
                        labelText: '要生成的字符',
                        hintText: '输入所有需要的字符',
                        border: OutlineInputBorder(),
                        helperText: '支持中英文、数字、符号，重复字符会自动去重',
                      ),
                      maxLines: 5,
                      maxLength: 10000,
                    ),
                    const SizedBox(height: 8),
                    const Text('快速选择字符集:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: TextRenderer.getCharacterSets().entries.map((entry) {
                        return OutlinedButton(
                          onPressed: () {
                            _charactersController.text = entry.value;
                          },
                          child: Text(entry.key),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const Divider(height: 32),

                // 字符大小
                _buildSection(
                  '字符大小',
                  [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _widthController,
                            decoration: const InputDecoration(
                              labelText: '宽度',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('×'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _heightController,
                            decoration: const InputDecoration(
                              labelText: '高度',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSizeButton('8×8'),
                        _buildSizeButton('8×16'),
                        _buildSizeButton('16×16'),
                        _buildSizeButton('16×32'),
                        _buildSizeButton('24×24'),
                        _buildSizeButton('32×32'),
                      ],
                    ),
                  ],
                ),

                const Divider(height: 32),

                // 字体设置
                _buildSection(
                  '字体设置',
                  [
                    DropdownButtonFormField<String>(
                      value: _selectedFont,
                      decoration: const InputDecoration(
                        labelText: '字体',
                        border: OutlineInputBorder(),
                      ),
                      items: TextRenderer.getAvailableFonts()
                          .map((font) => DropdownMenuItem(
                                value: font,
                                child: Text(font),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedFont = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('字号: ${_fontSize.toInt()}'),
                              Slider(
                                value: _fontSize,
                                min: 6,
                                max: 48,
                                divisions: 42,
                                label: _fontSize.toInt().toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _fontSize = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('粗体'),
                            value: _bold,
                            onChanged: (value) {
                              setState(() {
                                _bold = value ?? false;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('斜体'),
                            value: _italic,
                            onChanged: (value) {
                              setState(() {
                                _italic = value ?? false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Divider(height: 32),

                // 输出设置
                _buildSection(
                  '输出设置',
                  [
                    TextField(
                      controller: _libraryNameController,
                      decoration: const InputDecoration(
                        labelText: '字库名称',
                        hintText: '用于生成变量名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('生成索引表'),
                      subtitle: const Text('包含字符查找函数'),
                      value: _generateIndex,
                      onChanged: (value) {
                        setState(() {
                          _generateIndex = value ?? true;
                        });
                      },
                    ),
                  ],
                ),

                const Divider(height: 32),

                // 生成按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateFontLibrary,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_isGenerating ? '生成中...' : '生成字库'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),

                if (_isGenerating) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: _progress),
                  const SizedBox(height: 8),
                  Text(_statusText, textAlign: TextAlign.center),
                ],

                if (_result != null) ...[
                  const SizedBox(height: 16),
                  _buildResultInfo(),
                ],
              ],
            ),
          ),
        ),

        // 底部操作按钮
        if (_generatedCode.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(top: BorderSide(color: Colors.grey[400]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _viewCode,
                    icon: const Icon(Icons.visibility),
                    label: const Text('查看代码'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _copyCode,
                    icon: const Icon(Icons.copy),
                    label: const Text('复制代码'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveCode,
                    icon: const Icon(Icons.save),
                    label: const Text('保存文件'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建分组标题
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  /// 构建尺寸按钮
  Widget _buildSizeButton(String label) {
    return OutlinedButton(
      onPressed: () {
        final parts = label.split('×');
        if (parts.length == 2) {
          _widthController.text = parts[0];
          _heightController.text = parts[1];
        }
      },
      child: Text(label),
    );
  }

  /// 构建结果信息
  Widget _buildResultInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                '字库生成成功',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('字符数量: ${_result!.characterCount}'),
          Text('字符大小: ${_result!.charWidth}×${_result!.charHeight}'),
          Text('总字节数: ${_result!.totalBytes}'),
          Text('平均每字符: ${_result!.bytesPerChar.toStringAsFixed(1)} 字节'),
        ],
      ),
    );
  }

  /// 生成字库
  Future<void> _generateFontLibrary() async {
    final characters = _charactersController.text;
    if (characters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入要生成的字符')),
      );
      return;
    }

    final width = int.tryParse(_widthController.text);
    final height = int.tryParse(_heightController.text);

    if (width == null || height == null || width <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的字符大小')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _progress = 0.0;
      _statusText = '正在生成字库...';
    });

    try {
      final result = await FontGenerator.generateFontLibrary(
        characters: characters,
        charWidth: width,
        charHeight: height,
        options: widget.options,
        fontFamily: _selectedFont,
        fontSize: _fontSize,
        bold: _bold,
        italic: _italic,
        onProgress: (current, total) {
          setState(() {
            _progress = current / total;
            _statusText = '正在处理: $current / $total';
          });
        },
      );

      final code = FontGenerator.generateFontLibraryCode(
        result: result,
        options: widget.options,
        libraryName: _libraryNameController.text.isEmpty
            ? 'font'
            : _libraryNameController.text,
        generateIndex: _generateIndex,
      );

      setState(() {
        _result = result;
        _generatedCode = code;
        _isGenerating = false;
        _statusText = '完成';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('字库生成成功！共 ${result.characterCount} 个字符'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成失败: $e')),
        );
      }
    }
  }

  /// 查看代码
  void _viewCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('字库代码'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: SelectableText(
              _generatedCode,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
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

  /// 复制代码
  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _generatedCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('代码已复制到剪贴板')),
    );
  }

  /// 保存代码
  Future<void> _saveCode() async {
    try {
      final homeDir = Platform.environment['HOME'] ?? '/home/ubuntu';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final libraryName = _libraryNameController.text.isEmpty
          ? 'font'
          : _libraryNameController.text;
      final fileName = '${libraryName}_library_$timestamp.c';
      final filePath = '$homeDir/$fileName';

      final file = File(filePath);
      await file.writeAsString(_generatedCode);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已保存到: $filePath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }
}
