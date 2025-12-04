import 'dart:math' as math;

/// 绘图工具类型
enum DrawingTool {
  /// 画笔（自由绘制）
  pen,
  /// 橡皮擦
  eraser,
  /// 直线
  line,
  /// 矩形（空心）
  rectangle,
  /// 矩形（实心）
  filledRectangle,
  /// 圆形（空心）
  circle,
  /// 圆形（实心）
  filledCircle,
  /// 填充（油漆桶）
  fill,
}

/// 绘图工具辅助类
class DrawingToolHelper {
  /// 获取工具名称
  static String getToolName(DrawingTool tool) {
    switch (tool) {
      case DrawingTool.pen:
        return '画笔';
      case DrawingTool.eraser:
        return '橡皮擦';
      case DrawingTool.line:
        return '直线';
      case DrawingTool.rectangle:
        return '矩形';
      case DrawingTool.filledRectangle:
        return '实心矩形';
      case DrawingTool.circle:
        return '圆形';
      case DrawingTool.filledCircle:
        return '实心圆形';
      case DrawingTool.fill:
        return '填充';
    }
  }

  /// 绘制直线（Bresenham 算法）
  static List<Point> drawLine(int x0, int y0, int x1, int y1) {
    List<Point> points = [];
    
    int dx = (x1 - x0).abs();
    int dy = (y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx - dy;

    int x = x0;
    int y = y0;

    while (true) {
      points.add(Point(x, y));

      if (x == x1 && y == y1) break;

      int e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x += sx;
      }
      if (e2 < dx) {
        err += dx;
        y += sy;
      }
    }

    return points;
  }

  /// 绘制矩形（空心）
  static List<Point> drawRectangle(int x0, int y0, int x1, int y1) {
    List<Point> points = [];
    
    int left = math.min(x0, x1);
    int right = math.max(x0, x1);
    int top = math.min(y0, y1);
    int bottom = math.max(y0, y1);

    // 上边
    for (int x = left; x <= right; x++) {
      points.add(Point(x, top));
    }

    // 下边
    for (int x = left; x <= right; x++) {
      points.add(Point(x, bottom));
    }

    // 左边
    for (int y = top; y <= bottom; y++) {
      points.add(Point(left, y));
    }

    // 右边
    for (int y = top; y <= bottom; y++) {
      points.add(Point(right, y));
    }

    return points;
  }

  /// 绘制矩形（实心）
  static List<Point> drawFilledRectangle(int x0, int y0, int x1, int y1) {
    List<Point> points = [];
    
    int left = math.min(x0, x1);
    int right = math.max(x0, x1);
    int top = math.min(y0, y1);
    int bottom = math.max(y0, y1);

    for (int y = top; y <= bottom; y++) {
      for (int x = left; x <= right; x++) {
        points.add(Point(x, y));
      }
    }

    return points;
  }

  /// 绘制圆形（空心，中点圆算法）
  static List<Point> drawCircle(int cx, int cy, int radius) {
    List<Point> points = [];
    
    int x = 0;
    int y = radius;
    int d = 1 - radius;

    // 绘制8个对称点
    void addSymmetricPoints(int x, int y) {
      points.add(Point(cx + x, cy + y));
      points.add(Point(cx - x, cy + y));
      points.add(Point(cx + x, cy - y));
      points.add(Point(cx - x, cy - y));
      points.add(Point(cx + y, cy + x));
      points.add(Point(cx - y, cy + x));
      points.add(Point(cx + y, cy - x));
      points.add(Point(cx - y, cy - x));
    }

    addSymmetricPoints(x, y);

    while (x < y) {
      if (d < 0) {
        d += 2 * x + 3;
      } else {
        d += 2 * (x - y) + 5;
        y--;
      }
      x++;
      addSymmetricPoints(x, y);
    }

    return points;
  }

  /// 绘制圆形（实心）
  static List<Point> drawFilledCircle(int cx, int cy, int radius) {
    List<Point> points = [];
    
    for (int y = -radius; y <= radius; y++) {
      for (int x = -radius; x <= radius; x++) {
        if (x * x + y * y <= radius * radius) {
          points.add(Point(cx + x, cy + y));
        }
      }
    }

    return points;
  }

  /// 计算两点之间的距离
  static double distance(int x0, int y0, int x1, int y1) {
    int dx = x1 - x0;
    int dy = y1 - y0;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// 计算圆的半径
  static int calculateRadius(int x0, int y0, int x1, int y1) {
    return distance(x0, y0, x1, y1).round();
  }

  /// 洪水填充算法
  static List<Point> floodFill(
    List<List<bool>> pixels,
    int startX,
    int startY,
    bool fillValue,
  ) {
    List<Point> points = [];
    
    int width = pixels[0].length;
    int height = pixels.length;

    // 检查起始点是否有效
    if (startY < 0 || startY >= height || startX < 0 || startX >= width) {
      return points;
    }

    bool targetValue = pixels[startY][startX];
    
    // 如果目标值和填充值相同，不需要填充
    if (targetValue == fillValue) {
      return points;
    }

    // 使用栈实现非递归填充
    List<Point> stack = [Point(startX, startY)];
    Set<String> visited = {};

    while (stack.isNotEmpty) {
      Point p = stack.removeLast();
      String key = '${p.x},${p.y}';

      if (visited.contains(key)) continue;
      if (p.y < 0 || p.y >= height || p.x < 0 || p.x >= width) continue;
      if (pixels[p.y][p.x] != targetValue) continue;

      visited.add(key);
      points.add(p);

      // 添加四个方向的邻居
      stack.add(Point(p.x + 1, p.y));
      stack.add(Point(p.x - 1, p.y));
      stack.add(Point(p.x, p.y + 1));
      stack.add(Point(p.x, p.y - 1));
    }

    return points;
  }
}

/// 点坐标
class Point {
  final int x;
  final int y;

  Point(this.x, this.y);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Point && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => '($x, $y)';
}
