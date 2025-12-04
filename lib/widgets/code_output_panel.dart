import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../bitmap_model.dart';
import '../bitmap_converter.dart';
import 'dart:io';

/// 代码输出面板组件
class CodeOutputPanel extends StatefulWidget {
  final ConversionOptions options;

  const CodeOutputPanel({
    super.key,
    required this.options,
  });

  @override
  State<CodeOutputPanel> createState() => _CodeOutputPanelState();
}

class _CodeOutputPanelState extends State<CodeOutputPanel> {
  String _generatedCode = '';
  late TextEditingController _arrayNameController;
  late TextEditingController _bytesPerLineController;

  @override
  void initState() {
    super.initState();
    _arrayNameController = TextEditingController(text: 'bitmap');
    _bytesPerLineController = TextEditingController(
      text: widget.options.bytesPerLine.toString(),
    );
    _generateCode();
  }

  @override
  void dispose() {
    _arrayNameController.dispose();
    _bytesPerLineController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CodeOutputPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options != widget.options) {
      _generateCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BitmapModel>(
      builder: (context, model, child) {
        // 当模型更新时重新生成代码
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _generateCode();
        });

        return Column(
          children: [
            // 工具栏
            _buildToolbar(),
            const SizedBox(height: 8),
            // 代码显示区域
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey[50],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _generatedCode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            // 操作按钮
            _buildActionButtons(),
          ],
        );
      },
    );
  }

  /// 构建工具栏
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _arrayNameController,
              decoration: const InputDecoration(
                labelText: '数组名称',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                _generateCode();
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: TextField(
              controller: _bytesPerLineController,
              decoration: const InputDecoration(
                labelText: '每行字节数',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                _generateCode();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(top: BorderSide(color: Colors.grey[400]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy),
              label: const Text('复制代码'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saveToFile,
              icon: const Icon(Icons.save),
              label: const Text('保存到文件'),
            ),
          ),
        ],
      ),
    );
  }

  /// 生成代码
  void _generateCode() {
    final model = context.read<BitmapModel>();
    
    // 转换点阵数据为字节数组
    final bytes = BitmapConverter.convertToBytes(
      model.pixels,
      widget.options,
    );

    // 获取每行字节数
    int bytesPerLine = int.tryParse(_bytesPerLineController.text) ?? 16;
    if (bytesPerLine < 1) bytesPerLine = 16;

    // 生成 C 代码
    final code = BitmapConverter.generateCCode(
      bytes,
      widget.options.copyWith(bytesPerLine: bytesPerLine),
      arrayName: _arrayNameController.text.isEmpty
          ? 'bitmap'
          : _arrayNameController.text,
      width: model.width,
      height: model.height,
    );

    setState(() {
      _generatedCode = code;
    });
  }

  /// 复制到剪贴板
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('代码已复制到剪贴板')),
    );
  }

  /// 保存到文件
  Future<void> _saveToFile() async {
    try {
      // 在用户主目录下保存
      final homeDir = Platform.environment['HOME'] ?? '/home/ubuntu';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${_arrayNameController.text}_$timestamp.c';
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
