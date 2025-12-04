import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../bitmap_model.dart';
import '../text_renderer.dart';

/// 字符模式面板
class CharacterPanel extends StatefulWidget {
  const CharacterPanel({super.key});

  @override
  State<CharacterPanel> createState() => _CharacterPanelState();
}

class _CharacterPanelState extends State<CharacterPanel> {
  final TextEditingController _textController = TextEditingController();
  String _selectedFont = 'sans-serif';
  double _fontSize = 16.0;
  bool _bold = false;
  bool _italic = false;
  bool _isGenerating = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文字输入
          _buildSection(
            '输入文字',
            [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: '要生成的文字',
                  hintText: '输入单个字符或多个字符',
                  border: OutlineInputBorder(),
                  helperText: '支持中英文、数字、符号',
                ),
                maxLines: 3,
                maxLength: 100,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickTextButton('A'),
                  _buildQuickTextButton('中'),
                  _buildQuickTextButton('0-9'),
                  _buildQuickTextButton('Hello'),
                  _buildQuickTextButton('你好'),
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
                          min: 8,
                          max: 64,
                          divisions: 56,
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
              const SizedBox(height: 8),
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

          // 生成按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateText,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.text_fields),
              label: Text(_isGenerating ? '生成中...' : '生成到点阵'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 说明文字
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      '使用提示',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text('• 输入的文字会被渲染到当前点阵大小'),
                Text('• 多个字符会自动排列'),
                Text('• 建议先设置合适的点阵大小'),
                Text('• 中文字符建议使用较大的点阵（如16×16以上）'),
                Text('• 英文字符可以使用较小的点阵（如8×8）'),
              ],
            ),
          ),
        ],
      ),
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

  /// 构建快速文本按钮
  Widget _buildQuickTextButton(String text) {
    return OutlinedButton(
      onPressed: () {
        _textController.text = text;
      },
      child: Text(text),
    );
  }

  /// 生成文字到点阵
  Future<void> _generateText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入要生成的文字')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final model = context.read<BitmapModel>();
      
      // 渲染文字为图像
      final image = await TextRenderer.renderText(
        text: text,
        width: model.width,
        height: model.height,
        fontFamily: _selectedFont,
        fontSize: _fontSize,
        bold: _bold,
        italic: _italic,
      );

      if (image != null && mounted) {
        // 加载到点阵模型
        final success = model.loadFromImage(image);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('文字生成成功')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('文字生成失败')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('文字渲染失败')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('错误: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}
