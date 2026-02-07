import 'dart:math';
import 'package:flutter/material.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';

/// 手绘风基础 Painter，提供波浪线和不规则形状的绘制能力
abstract class _HandDrawnPainter extends CustomPainter {
  final int seed;
  late final Random _random;

  _HandDrawnPainter({required this.seed}) {
    _random = Random(seed);
  }

  double _wobble(double scale) => (_random.nextDouble() - 0.5) * 2.0 * scale;

  void drawWobblyLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double scale = 1.0,
    double segmentsFactor = 8.0,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len < 1) return;

    final path = Path();
    path.moveTo(start.dx, start.dy);

    final segments = (len / segmentsFactor).clamp(2, 20).toInt();
    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final px = start.dx + dx * t;
      final py = start.dy + dy * t;

      final midX = start.dx + dx * (t - 0.5 / segments);
      final midY = start.dy + dy * (t - 0.5 / segments);

      final wobbleFactor = 1.5 * scale;
      path.quadraticBezierTo(
        midX + _wobble(wobbleFactor),
        midY + _wobble(wobbleFactor),
        px,
        py,
      );
    }
    canvas.drawPath(path, paint);
  }

  void drawHandDrawnRect(
    Canvas canvas,
    Rect rect,
    Paint borderPaint, {
    Paint? fillPaint,
    double scale = 1.0,
  }) {
    if (fillPaint != null) {
      // 填充使用略微不规则的路径
      final fillPath = Path();
      fillPath.moveTo(rect.left + _wobble(scale), rect.top + _wobble(scale));
      fillPath.lineTo(rect.right + _wobble(scale), rect.top + _wobble(scale));
      fillPath.lineTo(
        rect.right + _wobble(scale),
        rect.bottom + _wobble(scale),
      );
      fillPath.lineTo(rect.left + _wobble(scale), rect.bottom + _wobble(scale));
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
    }

    // 四条边分别绘制以产生手绘感
    final corners = [
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      Offset(rect.left, rect.bottom),
    ];

    for (int i = 0; i < 4; i++) {
      drawWobblyLine(
        canvas,
        corners[i],
        corners[(i + 1) % 4],
        borderPaint,
        scale: scale,
      );
    }
  }
}

/// 手绘风柱状图
class HandDrawnBarChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;
  final double height;
  final Color? barColor;
  final double maxValue;

  const HandDrawnBarChart({
    super.key,
    required this.data,
    required this.labels,
    this.height = 200,
    this.barColor,
    required this.maxValue,
  });

  @override
  State<HandDrawnBarChart> createState() => _HandDrawnBarChartState();
}

class _HandDrawnBarChartState extends State<HandDrawnBarChart> {
  final int _seed = Random().nextInt(1000000);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _BarChartPainter(
            data: widget.data,
            labels: widget.labels,
            color: widget.barColor ?? AppColors.primary,
            borderColor: AppColors.getBorderColor(context),
            textColor: AppColors.getTextMutedColor(context),
            valueColor: AppColors.getTextMainColor(context),
            maxValue: widget.maxValue,
            seed: _seed,
          ),
        ),
      ),
    );
  }
}

class _BarChartPainter extends _HandDrawnPainter {
  final List<double> data;
  final List<String> labels;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final Color valueColor;
  final double maxValue;

  _BarChartPainter({
    required this.data,
    required this.labels,
    required this.color,
    required this.borderColor,
    required this.textColor,
    required this.valueColor,
    required this.maxValue,
    required super.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final barWidth = (size.width / (data.length * 1.5 + 0.5));
    final spacing = barWidth * 0.5;
    const topMargin = 20.0;
    const bottomMargin = 45.0;
    final chartHeight = size.height - bottomMargin;
    final drawHeight = chartHeight - topMargin;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final fillPaint = Paint()
      ..color = color.withAlpha((0.1 * 255).round())
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = spacing + i * (barWidth + spacing);
      final normalizedValue = maxValue > 0 ? (data[i] / maxValue) : 0.0;
      final barH = normalizedValue * drawHeight;
      final rect = Rect.fromLTWH(x, chartHeight - barH, barWidth, barH);

      if (barH > 0) {
        drawHandDrawnRect(canvas, rect, borderPaint, fillPaint: fillPaint);
      } else {
        // 即使是0也画一条底线
        drawWobblyLine(
          canvas,
          Offset(x, chartHeight),
          Offset(x + barWidth, chartHeight),
          borderPaint,
        );
      }

      // 绘制标签
      final int labelInterval = (data.length / 5).ceil();
      if (i % labelInterval == 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: TextStyle(color: textColor, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(x + (barWidth - textPainter.width) / 2, chartHeight + 15),
        );
      }

      // 绘制顶部数值
      if (data[i] > 0) {
        final valueStr = data[i] == data[i].toInt()
            ? data[i].toInt().toString()
            : data[i].toStringAsFixed(1);
        final valuePainter = TextPainter(
          text: TextSpan(
            text: valueStr,
            style: TextStyle(
              color: valueColor,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        valuePainter.paint(
          canvas,
          Offset(
            x + (barWidth - valuePainter.width) / 2,
            chartHeight - barH - valuePainter.height - 4,
          ),
        );
      }
    }

    // 绘制底座 X 轴
    drawWobblyLine(
      canvas,
      Offset(0, chartHeight),
      Offset(size.width, chartHeight),
      borderPaint,
      scale: 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.seed != seed ||
        oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor;
  }
}

/// 手绘风折线图
class HandDrawnLineChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;
  final double height;
  final Color? lineColor;
  final double maxValue;

  const HandDrawnLineChart({
    super.key,
    required this.data,
    required this.labels,
    this.height = 200,
    this.lineColor,
    required this.maxValue,
  });

  @override
  State<HandDrawnLineChart> createState() => _HandDrawnLineChartState();
}

class _HandDrawnLineChartState extends State<HandDrawnLineChart> {
  final int _seed = Random().nextInt(1000000);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _LineChartPainter(
            data: widget.data,
            labels: widget.labels,
            color: widget.lineColor ?? AppColors.primary,
            borderColor: AppColors.getBorderColor(context),
            textColor: AppColors.getTextMutedColor(context),
            valueColor: AppColors.getTextMainColor(context),
            maxValue: widget.maxValue,
            seed: _seed,
          ),
        ),
      ),
    );
  }
}

class _LineChartPainter extends _HandDrawnPainter {
  final List<double> data;
  final List<String> labels;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final Color valueColor;
  final double maxValue;

  _LineChartPainter({
    required this.data,
    required this.labels,
    required this.color,
    required this.borderColor,
    required this.textColor,
    required this.valueColor,
    required this.maxValue,
    required super.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final chartHeight = size.height - 45;
    final spacing = size.width / (data.length > 1 ? data.length - 1 : 1);
    const topMargin = 20.0;
    final drawHeight = chartHeight - topMargin;

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final x = i * spacing;
      final normalizedValue = maxValue > 0 ? (data[i] / maxValue) : 0.0;
      final y = chartHeight - (normalizedValue * drawHeight);
      points.add(Offset(x, y));

      // 绘制虚位背景竖线
      drawWobblyLine(
        canvas,
        Offset(x, chartHeight),
        Offset(x, topMargin),
        borderPaint,
        segmentsFactor: 20,
      );

      // 绘制标签
      final int labelInterval = (data.length / 6).ceil();
      if (i % labelInterval == 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: TextStyle(color: textColor, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, chartHeight + 15),
        );
      }

      // 绘制数值
      if (data[i] > 0) {
        final valueStr = data[i] == data[i].toInt()
            ? data[i].toInt().toString()
            : data[i].toStringAsFixed(1);
        final valuePainter = TextPainter(
          text: TextSpan(
            text: valueStr,
            style: TextStyle(
              color: valueColor,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        valuePainter.paint(
          canvas,
          Offset(x - valuePainter.width / 2, y - valuePainter.height - 4),
        );
      }
    }

    // 连线
    for (int i = 0; i < points.length - 1; i++) {
      drawWobblyLine(canvas, points[i], points[i + 1], linePaint, scale: 1.2);
    }

    // 画点
    for (final p in points) {
      canvas.drawCircle(p + Offset(_wobble(1), _wobble(1)), 4, dotPaint);
    }

    // 绘制底座 X 轴
    drawWobblyLine(
      canvas,
      Offset(0, chartHeight),
      Offset(size.width, chartHeight),
      borderPaint..color = borderColor,
      scale: 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.seed != seed ||
        oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor;
  }
}

/// 手绘风饼图
class HandDrawnPieChart extends StatefulWidget {
  final List<double> data;
  final List<Color> colors;
  final double size;
  final Color? textColor;

  const HandDrawnPieChart({
    super.key,
    required this.data,
    required this.colors,
    this.size = 150,
    this.textColor,
  });

  @override
  State<HandDrawnPieChart> createState() => _HandDrawnPieChartState();
}

class _HandDrawnPieChartState extends State<HandDrawnPieChart> {
  final int _seed = Random().nextInt(1000000);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _PieChartPainter(
          data: widget.data,
          colors: widget.colors,
          borderColor: AppColors.getBorderColor(context),
          textColor: widget.textColor ?? AppColors.getTextMainColor(context),
          seed: _seed,
        ),
      ),
    );
  }
}

class _PieChartPainter extends _HandDrawnPainter {
  final List<double> data;
  final List<Color> colors;
  final Color borderColor;
  final Color textColor;

  _PieChartPainter({
    required this.data,
    required this.colors,
    required this.borderColor,
    required this.textColor,
    required super.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final originalTotal = data.fold(0.0, (sum, item) => sum + item);
    final isAllZero = originalTotal <= 0;
    // 如果全为0，则按项数均分圆饼，但显示时仍标记为0%
    final total = isAllZero ? data.length.toDouble() : originalTotal;
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2;

    for (int i = 0; i < data.length; i++) {
      final percentage = isAllZero ? (1.0 / data.length) : (data[i] / total);
      final sweepAngle = percentage * 2 * pi;
      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..color = colors[i % colors.length].withAlpha((0.2 * 255).round())
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        rect.inflate(_wobble(1.5)),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawArc(
        rect.inflate(_wobble(1.0)),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // 绘制百分比
      // 如果原本全为0，显示0%；否则正常按比例显示（仅显示占比>5%的）
      final displayPercentage = isAllZero ? 0.0 : (data[i] / originalTotal);
      if (isAllZero || displayPercentage > 0.05) {
        final labelAngle = startAngle + sweepAngle / 2;
        final labelRadius = radius * 0.7;
        final lx = center.dx + cos(labelAngle) * labelRadius;
        final ly = center.dy + sin(labelAngle) * labelRadius;

        final pctStr = isAllZero
            ? '0%'
            : '${(displayPercentage * 100).toInt()}%';
        final pctPainter = TextPainter(
          text: TextSpan(
            text: pctStr,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: textColor.withAlpha((0.2 * 255).round()),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        pctPainter.paint(
          canvas,
          Offset(lx - pctPainter.width / 2, ly - pctPainter.height / 2),
        );
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.seed != seed ||
        oldDelegate.borderColor != borderColor;
  }
}
