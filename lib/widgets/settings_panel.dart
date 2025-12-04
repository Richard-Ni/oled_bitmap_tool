import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../bitmap_model.dart';
import '../bitmap_converter.dart';

/// 设置面板组件
class SettingsPanel extends StatefulWidget {
  final ConversionOptions options;
  final Function(ConversionOptions) onOptionsChanged;

  const SettingsPanel({
    super.key,
    required this.options,
    required this.onOptionsChanged,
  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  ImageScaleMode _scaleMode = ImageScaleMode.stretch;

  @override
  void initState() {
    super.initState();
    final model = context.read<BitmapModel>();
    _widthController = TextEditingController(text: model.width.toString());
    _heightController = TextEditingController(text: model.height.toString());
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BitmapModel>(
      builder: (context, model, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 文件操作
              _buildSection(
                '文件操作',
                [
                  ElevatedButton.icon(
                    onPressed: () => _loadImage(model),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('导入图像'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _saveImage(model),
                    icon: const Icon(Icons.save),
                    label: const Text('导出图像'),
                  ),
                ],
              ),

              const Divider(height: 32),

              // 图像缩放模式
              _buildSection(
                '图像缩放模式',
                [
                  RadioListTile<ImageScaleMode>(
                    title: const Text('保持纵横比（留白）'),
                    subtitle: const Text('图像居中，周围留白'),
                    value: ImageScaleMode.aspectFit,
                    groupValue: _scaleMode,
                    onChanged: (value) {
                      setState(() {
                        _scaleMode = value!;
                      });
                    },
                  ),
                  RadioListTile<ImageScaleMode>(
                    title: const Text('保持纵横比（裁剪）'),
                    subtitle: const Text('图像填充，超出部分裁剪'),
                    value: ImageScaleMode.aspectFill,
                    groupValue: _scaleMode,
                    onChanged: (value) {
                      setState(() {
                        _scaleMode = value!;
                      });
                    },
                  ),
                  RadioListTile<ImageScaleMode>(
                    title: const Text('拉伸填充'),
                    subtitle: const Text('拉伸图像以填充整个区域'),
                    value: ImageScaleMode.stretch,
                    groupValue: _scaleMode,
                    onChanged: (value) {
                      setState(() {
                        _scaleMode = value!;
                      });
                    },
                  ),
                  RadioListTile<ImageScaleMode>(
                    title: const Text('平铺'),
                    subtitle: const Text('重复平铺图像'),
                    value: ImageScaleMode.tile,
                    groupValue: _scaleMode,
                    onChanged: (value) {
                      setState(() {
                        _scaleMode = value!;
                      });
                    },
                  ),
                ],
              ),

              const Divider(height: 32),

              // 点阵大小
              _buildSection(
                '点阵大小',
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
                  ElevatedButton(
                    onPressed: () => _applySize(model),
                    child: const Text('应用尺寸'),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPresetButton(model, '128×64'),
                      _buildPresetButton(model, '128×32'),
                      _buildPresetButton(model, '64×48'),
                      _buildPresetButton(model, '96×96'),
                    ],
                  ),
                ],
              ),

              const Divider(height: 32),

              // 取模方式
              _buildSection(
                '取模方式',
                [
                  RadioListTile<ScanMode>(
                    title: const Text('逐行'),
                    subtitle: const Text('横向逐行取点'),
                    value: ScanMode.rowByRow,
                    groupValue: widget.options.scanMode,
                    onChanged: (value) {
                      widget.onOptionsChanged(
                        widget.options.copyWith(scanMode: value),
                      );
                    },
                  ),
                  RadioListTile<ScanMode>(
                    title: const Text('逐列'),
                    subtitle: const Text('纵向逐列取点'),
                    value: ScanMode.columnByColumn,
                    groupValue: widget.options.scanMode,
                    onChanged: (value) {
                      widget.onOptionsChanged(
                        widget.options.copyWith(scanMode: value),
                      );
                    },
                  ),
                  RadioListTile<ScanMode>(
                    title: const Text('行列'),
                    subtitle: const Text('先横向后纵向'),
                    value: ScanMode.rowColumn,
                    groupValue: widget.options.scanMode,
                    onChanged: (value) {
                      widget.onOptionsChanged(
                        widget.options.copyWith(scanMode: value),
                      );
                    },
                  ),
                  RadioListTile<ScanMode>(
                    title: const Text('列行'),
                    subtitle: const Text('先纵向后横向'),
                    value: ScanMode.columnRow,
                    groupValue: widget.options.scanMode,
                    onChanged: (value) {
                      widget.onOptionsChanged(
                        widget.options.copyWith(scanMode: value),
                      );
                    },
                  ),
                ],
              ),

              const Divider(height: 32),

              // 取模选项
              _buildSection(
                '取模选项',
                [
                  SwitchListTile(
                    title: const Text('阴码'),
                    subtitle: const Text('亮点为1（关闭则为阳码）'),
                    value: widget.options.isPositive,
                    onChanged: (value) {
                      widget.onOptionsChanged(
                        widget.options.copyWith(isPositive: value),
                      );
                    },
                  ),
                  SwitchListTile(
                    title: const Text('纵向'),
                    subtitle: const Text('低位在前（关闭则为倒向）'),
                    value: widget.options.isLsbFirst,
                    onChanged: (value) {
                      widget.onOptionsChanged(
                        widget.options.copyWith(isLsbFirst: value),
                      );
                    },
                  ),
                  SwitchListTile(
                    title: const Text('16进制'),
                    subtitle: const Text('使用16进制输出'),
                    value: widget.options.isHex,
                    onChanged: (value) {
                      widget.onOptionsChanged(
                        widget.options.copyWith(isHex: value),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

  /// 构建预设尺寸按钮
  Widget _buildPresetButton(BitmapModel model, String label) {
    return OutlinedButton(
      onPressed: () {
        final parts = label.split('×');
        if (parts.length == 2) {
          final width = int.tryParse(parts[0]);
          final height = int.tryParse(parts[1]);
          if (width != null && height != null) {
            model.setSize(width, height);
            _widthController.text = width.toString();
            _heightController.text = height.toString();
          }
        }
      },
      child: Text(label),
    );
  }

  /// 应用尺寸
  void _applySize(BitmapModel model) {
    final width = int.tryParse(_widthController.text);
    final height = int.tryParse(_heightController.text);

    if (width != null && height != null) {
      if (width > 0 && height > 0 && width <= 1024 && height <= 1024) {
        model.setSize(width, height);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('尺寸已更新')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('尺寸必须在 1-1024 之间')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的数字')),
      );
    }
  }

  /// 加载图像
  Future<void> _loadImage(BitmapModel model) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final success = await model.loadFromFile(
          result.files.single.path!,
          scaleMode: _scaleMode,
        );
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('图像加载成功')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('图像加载失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('错误: $e')),
        );
      }
    }
  }

  /// 保存图像
  Future<void> _saveImage(BitmapModel model) async {
    // 由于 file_picker 在 Linux 上的限制，这里简化处理
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('图像导出功能待实现')),
    );
  }
}
