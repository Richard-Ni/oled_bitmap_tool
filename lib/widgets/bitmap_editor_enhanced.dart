import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bitmap_model.dart';
import '../drawing_tools.dart';

/// 增强的点阵编辑器组件
class BitmapEditorEnhanced extends StatefulWidget {
  const BitmapEditorEnhanced({super.key});

  @override
  State<BitmapEditorEnhanced> createState() => _BitmapEditorEnhancedState();
}

class _BitmapEditorEnhancedState extends State<BitmapEditorEnhanced> {
  DrawingTool _currentTool = DrawingTool.pen;
  bool _isDrawing = false;
  bool _drawValue = true; // true=画黑点, false=擦除
  int _brushSize = 1; // 画笔大小（1-5）
  
  // 用于形状工具的起始点
  int? _startX;
  int? _startY;
  
  // 预览点（用于显示正在绘制的形状）
  List<Point> _previewPoints = [];
  
  // CustomPaint 的 GlobalKey，用于准确获取坐标
  final GlobalKey _paintKey = GlobalKey();

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
                        _handlePanEnd(model);
                      },
                      child: CustomPaint(
                        key: _paintKey,
                        size: Size(
                          model.width * 8.0,
                          model.height * 8.0,
                        ),
                        painter: BitmapPainter(
                          pixels: model.pixels,
                          width: model.width,
                          height: model.height,
                          previewPoints: _previewPoints,
                          previewValue: _drawValue,
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
        border: Border(bottom: BorderSide(color: Colors.grey[400]!)),
      ),
      child: Column(
        children: [
          // 绘图工具
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildToolButton(
                DrawingTool.pen,
                Icons.edit,
                '画笔',
              ),
              _buildToolButton(
                DrawingTool.eraser,
                Icons.cleaning_services,
                '橡皮擦',
              ),
              _buildToolButton(
                DrawingTool.line,
                Icons.show_chart,
                '直线',
              ),
              _buildToolButton(
                DrawingTool.rectangle,
                Icons.crop_square,
                '矩形',
              ),
              _buildToolButton(
                DrawingTool.filledRectangle,
                Icons.rectangle,
                '实心矩形',
              ),
              _buildToolButton(
                DrawingTool.circle,
                Icons.circle_outlined,
                '圆形',
              ),
              _buildToolButton(
                DrawingTool.filledCircle,
                Icons.circle,
                '实心圆形',
              ),
              _buildToolButton(
                DrawingTool.fill,
                Icons.format_color_fill,
                '填充',
              ),
            ],
          ),
          
          // 画笔大小调节（仅在画笔或橡皮擦模式下显示）
          if (_currentTool == DrawingTool.pen || _currentTool == DrawingTool.eraser) ...[
            const Divider(height: 16),
            Row(
              children: [
                const Text('画笔大小: '),
                Expanded(
                  child: Slider(
                    value: _brushSize.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$_brushSize',
                    onChanged: (value) {
                      setState(() {
                        _brushSize = value.round();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$_brushSize',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
          
          const Divider(height: 16),
          // 编辑操作
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => model.clear(),
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('清空'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => model.invert(),
                icon: const Icon(Icons.invert_colors, size: 18),
                label: const Text('反转'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => model.flipHorizontal(),
                icon: const Icon(Icons.flip, size: 18),
                label: const Text('水平翻转'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => model.flipVertical(),
                icon: const Icon(Icons.flip, size: 18),
                label: const Text('垂直翻转'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => model.rotateClockwise(),
                icon: const Icon(Icons.rotate_right, size: 18),
                label: const Text('顺时针'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => model.rotateCounterClockwise(),
                icon: const Icon(Icons.rotate_left, size: 18),
                label: const Text('逆时针'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建工具按钮
  Widget _buildToolButton(DrawingTool tool, IconData icon, String label) {
    final isSelected = _currentTool == tool;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _currentTool = tool;
            // 橡皮擦自动设置为擦除模式
            if (tool == DrawingTool.eraser) {
              _drawValue = false;
            } else {
              _drawValue = true;
            }
          });
        }
      },
      selectedColor: Colors.blue[200],
      backgroundColor: Colors.grey[300],
    );
  }

  /// 构建状态栏
  Widget _buildStatusBar(BitmapModel model) {
    final stats = model.getStatistics();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(top: BorderSide(color: Colors.grey[400]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('当前工具: ${DrawingToolHelper.getToolName(_currentTool)}'),
          if (_currentTool == DrawingTool.pen || _currentTool == DrawingTool.eraser)
            Text('画笔大小: $_brushSize'),
          Text('尺寸: ${stats['width']}×${stats['height']}'),
          Text('黑点: ${stats['blackPixels']}'),
          Text('填充率: ${stats['fillRate']}%'),
        ],
      ),
    );
  }

  /// 处理绘制开始
  void _handlePanStart(DragStartDetails details, BitmapModel model) {
    final RenderBox? box = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    final localPosition = box.globalToLocal(details.globalPosition);
    
    // 计算点击的像素位置
    final col = (localPosition.dx / 8.0).floor();
    final row = (localPosition.dy / 8.0).floor();

    if (col >= 0 && col < model.width && row >= 0 && row < model.height) {
      setState(() {
        _isDrawing = true;
        _startX = col;
        _startY = row;
        _previewPoints = [];
      });

      // 对于即时工具（画笔、橡皮擦、填充），立即执行
      if (_currentTool == DrawingTool.pen || _currentTool == DrawingTool.eraser) {
        _drawBrush(model, col, row);
      } else if (_currentTool == DrawingTool.fill) {
        final points = DrawingToolHelper.floodFill(
          model.pixels,
          col,
          row,
          _drawValue,
        );
        for (var point in points) {
          model.setPixel(point.y, point.x, _drawValue);
        }
        setState(() {
          _isDrawing = false;
        });
      }
    }
  }

  /// 处理绘制更新
  void _handlePanUpdate(DragUpdateDetails details, BitmapModel model) {
    if (!_isDrawing) return;

    final RenderBox? box = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    final localPosition = box.globalToLocal(details.globalPosition);
    
    final col = (localPosition.dx / 8.0).floor();
    final row = (localPosition.dy / 8.0).floor();

    if (col >= 0 && col < model.width && row >= 0 && row < model.height) {
      if (_currentTool == DrawingTool.pen || _currentTool == DrawingTool.eraser) {
        // 画笔和橡皮擦：直接绘制
        _drawBrush(model, col, row);
      } else if (_startX != null && _startY != null) {
        // 形状工具：更新预览
        setState(() {
          _previewPoints = _calculateShapePoints(_startX!, _startY!, col, row);
        });
      }
    }
  }

  /// 处理绘制结束
  void _handlePanEnd(BitmapModel model) {
    if (!_isDrawing) return;

    // 对于形状工具，应用预览的点
    if (_previewPoints.isNotEmpty) {
      for (var point in _previewPoints) {
        if (point.y >= 0 && point.y < model.height &&
            point.x >= 0 && point.x < model.width) {
          model.setPixel(point.y, point.x, _drawValue);
        }
      }
    }

    setState(() {
      _isDrawing = false;
      _startX = null;
      _startY = null;
      _previewPoints = [];
    });
  }

  /// 绘制画笔（支持不同大小）
  void _drawBrush(BitmapModel model, int centerX, int centerY) {
    if (_brushSize == 1) {
      // 单像素
      model.setPixel(centerY, centerX, _drawValue);
    } else {
      // 多像素画笔（圆形）
      final radius = (_brushSize - 1) / 2;
      for (int dy = -_brushSize ~/ 2; dy <= _brushSize ~/ 2; dy++) {
        for (int dx = -_brushSize ~/ 2; dx <= _brushSize ~/ 2; dx++) {
          // 圆形画笔
          if (dx * dx + dy * dy <= radius * radius + radius) {
            final x = centerX + dx;
            final y = centerY + dy;
            if (y >= 0 && y < model.height && x >= 0 && x < model.width) {
              model.setPixel(y, x, _drawValue);
            }
          }
        }
      }
    }
  }

  /// 计算形状的点
  List<Point> _calculateShapePoints(int x0, int y0, int x1, int y1) {
    switch (_currentTool) {
      case DrawingTool.line:
        return DrawingToolHelper.drawLine(x0, y0, x1, y1);
      
      case DrawingTool.rectangle:
        return DrawingToolHelper.drawRectangle(x0, y0, x1, y1);
      
      case DrawingTool.filledRectangle:
        return DrawingToolHelper.drawFilledRectangle(x0, y0, x1, y1);
      
      case DrawingTool.circle:
        final radius = DrawingToolHelper.calculateRadius(x0, y0, x1, y1);
        return DrawingToolHelper.drawCircle(x0, y0, radius);
      
      case DrawingTool.filledCircle:
        final radius = DrawingToolHelper.calculateRadius(x0, y0, x1, y1);
        return DrawingToolHelper.drawFilledCircle(x0, y0, radius);
      
      default:
        return [];
    }
  }
}

/// 点阵绘制器
class BitmapPainter extends CustomPainter {
  final List<List<bool>> pixels;
  final int width;
  final int height;
  final List<Point> previewPoints;
  final bool previewValue;

  BitmapPainter({
    required this.pixels,
    required this.width,
    required this.height,
    this.previewPoints = const [],
    this.previewValue = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = 8.0;
    
    // 绘制网格
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= width; i++) {
      canvas.drawLine(
        Offset(i * pixelSize, 0),
        Offset(i * pixelSize, height * pixelSize),
        gridPaint,
      );
    }

    for (int i = 0; i <= height; i++) {
      canvas.drawLine(
        Offset(0, i * pixelSize),
        Offset(width * pixelSize, i * pixelSize),
        gridPaint,
      );
    }

    // 绘制像素
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        if (pixels[row][col]) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * pixelSize + 1,
              row * pixelSize + 1,
              pixelSize - 2,
              pixelSize - 2,
            ),
            blackPaint,
          );
        }
      }
    }

    // 绘制预览点
    if (previewPoints.isNotEmpty) {
      final previewPaint = Paint()
        ..color = previewValue ? Colors.blue.withOpacity(0.5) : Colors.red.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      for (var point in previewPoints) {
        if (point.y >= 0 && point.y < height &&
            point.x >= 0 && point.x < width) {
          canvas.drawRect(
            Rect.fromLTWH(
              point.x * pixelSize + 1,
              point.y * pixelSize + 1,
              pixelSize - 2,
              pixelSize - 2,
            ),
            previewPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BitmapPainter oldDelegate) {
    return oldDelegate.pixels != pixels ||
           oldDelegate.previewPoints != previewPoints;
  }
}
