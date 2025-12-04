import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bitmap_model.dart';

/// 点阵编辑器组件
class BitmapEditor extends StatefulWidget {
  const BitmapEditor({super.key});

  @override
  State<BitmapEditor> createState() => _BitmapEditorState();
}

class _BitmapEditorState extends State<BitmapEditor> {
  double _scale = 1.0;
  bool _isDrawing = false;
  bool _drawValue = true; // true=画黑点, false=擦除

  @override
  Widget build(BuildContext context) {
    return Consumer<BitmapModel>(
      builder: (context, model, child) {
        return Column(
          children: [
            // 工具栏
            _buildToolbar(model),
            const SizedBox(height: 8),
            // 编辑区域
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.white,
                ),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 10.0,
                  boundaryMargin: const EdgeInsets.all(100),
                  child: Center(
                    child: GestureDetector(
                      onPanStart: (details) {
                        _handlePanStart(details, model);
                      },
                      onPanUpdate: (details) {
                        _handlePanUpdate(details, model);
                      },
                      onPanEnd: (details) {
                        setState(() {
                          _isDrawing = false;
                        });
                      },
                      child: CustomPaint(
                        size: Size(
                          model.width * 8.0,
                          model.height * 8.0,
                        ),
                        painter: BitmapPainter(
                          pixels: model.pixels,
                          width: model.width,
                          height: model.height,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 状态栏
            _buildStatusBar(model),
          ],
        );
      },
    );
  }

  /// 构建工具栏
  Widget _buildToolbar(BitmapModel model) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: '清空',
            onPressed: () {
              model.clear();
            },
          ),
          IconButton(
            icon: const Icon(Icons.invert_colors),
            tooltip: '反转',
            onPressed: () {
              model.invert();
            },
          ),
          const VerticalDivider(),
          IconButton(
            icon: const Icon(Icons.flip),
            tooltip: '水平翻转',
            onPressed: () {
              model.flipHorizontal();
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip),
            tooltip: '垂直翻转',
            onPressed: () {
              model.flipVertical();
            },
          ),
          const VerticalDivider(),
          IconButton(
            icon: const Icon(Icons.rotate_right),
            tooltip: '顺时针旋转',
            onPressed: () {
              model.rotateClockwise();
            },
          ),
          IconButton(
            icon: const Icon(Icons.rotate_left),
            tooltip: '逆时针旋转',
            onPressed: () {
              model.rotateCounterClockwise();
            },
          ),
        ],
      ),
    );
  }

  /// 构建状态栏
  Widget _buildStatusBar(BitmapModel model) {
    final stats = model.getStatistics();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(top: BorderSide(color: Colors.grey[400]!)),
      ),
      child: Row(
        children: [
          Text('点阵: ${stats['width']}×${stats['height']}'),
          const SizedBox(width: 24),
          Text('黑点: ${stats['blackPixels']}'),
          const SizedBox(width: 24),
          Text('填充率: ${stats['fillRate']}%'),
        ],
      ),
    );
  }

  /// 处理拖动开始
  void _handlePanStart(DragStartDetails details, BitmapModel model) {
    setState(() {
      _isDrawing = true;
    });
    _handlePanUpdate(
      DragUpdateDetails(
        globalPosition: details.globalPosition,
        localPosition: details.localPosition,
        delta: Offset.zero,
      ),
      model,
    );
  }

  /// 处理拖动更新
  void _handlePanUpdate(DragUpdateDetails details, BitmapModel model) {
    if (!_isDrawing) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    // 计算点击的像素位置
    final pixelSize = 8.0;
    final col = (localPosition.dx / pixelSize).floor();
    final row = (localPosition.dy / pixelSize).floor();

    if (row >= 0 && row < model.height && col >= 0 && col < model.width) {
      model.setPixel(row, col, _drawValue);
    }
  }
}

/// 点阵绘制器
class BitmapPainter extends CustomPainter {
  final List<List<bool>> pixels;
  final int width;
  final int height;

  BitmapPainter({
    required this.pixels,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = size.width / width;

    // 绘制网格背景
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // 绘制像素
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        final rect = Rect.fromLTWH(
          col * pixelSize,
          row * pixelSize,
          pixelSize,
          pixelSize,
        );

        // 绘制像素
        if (pixels[row][col]) {
          canvas.drawRect(rect, blackPaint);
        }

        // 绘制网格（当像素较大时）
        if (pixelSize > 4) {
          canvas.drawRect(rect, gridPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(BitmapPainter oldDelegate) {
    return oldDelegate.pixels != pixels ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }
}
