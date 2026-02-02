import 'dart:math';
import 'package:flutter/material.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';

class HandDrawnContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final double? width;
  final double? height;

  const HandDrawnContainer({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.borderRadius = 12,
    this.borderColor,
    this.borderWidth = 1.5,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor =
        borderColor ?? AppColors.getBorderColor(context);
    final effectiveFillColor = color ?? AppColors.getCardColor(context);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: CustomPaint(
        painter: _HandDrawnBorderPainter(
          color: effectiveBorderColor,
          width: borderWidth,
          borderRadius: borderRadius,
          fillColor: effectiveFillColor,
          mode: _PainterMode.background,
        ),
        foregroundPainter: _HandDrawnBorderPainter(
          color: effectiveBorderColor,
          width: borderWidth,
          borderRadius: borderRadius,
          fillColor: effectiveFillColor,
          mode: _PainterMode.foreground,
        ),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );
  }
}

enum _PainterMode { background, foreground }

class _HandDrawnBorderPainter extends CustomPainter {
  final Color color;
  final double width;
  final double borderRadius;
  final Color fillColor;
  final _PainterMode mode;

  _HandDrawnBorderPainter({
    required this.color,
    required this.width,
    required this.borderRadius,
    required this.fillColor,
    required this.mode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final sizeFactor = min(size.width, size.height);
    final scale = (sizeFactor / 80).clamp(0.2, 1.0);
    final random = Random(rect.hashCode);

    if (mode == _PainterMode.background) {
      // Layer 1: Soft diffuse shadow
      final shadowBlur = 6.0 * scale;
      final softShadowPaint = Paint()
        ..color = color.withValues(alpha: 0.04)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur);

      final shadowOffset = Offset(2 * scale, 2 * scale);
      canvas.drawPath(
        _createWobblyPath(
          rect.shift(shadowOffset),
          borderRadius,
          random,
          scale: scale,
        ),
        softShadowPaint,
      );

      // Layer 2: More defined "sketchy" shadow
      final sketchShadowPaint = Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill;

      final sketchShadowOffset = Offset(4 * scale, 4 * scale);
      final shadowPath = _createWobblyPath(
        rect.shift(sketchShadowOffset),
        borderRadius,
        random,
        scale: scale,
      );
      canvas.drawPath(shadowPath, sketchShadowPaint);

      // Draw fill
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      final wobblyPath = _createWobblyPath(
        rect,
        borderRadius,
        random,
        scale: scale,
      );
      canvas.drawPath(wobblyPath, fillPaint);
    } else {
      // Draw sketchy border (multiple passes for that hand-drawn feel)
      final borderPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // First pass: Main border
      _drawSketchyBorder(
        canvas,
        rect,
        borderRadius,
        borderPaint,
        random,
        scale: scale,
      );

      // Second pass: Slight offset/lighter for sketch effect
      final sketchPaint = Paint()
        ..color = color.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 0.7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      _drawSketchyBorder(
        canvas,
        rect,
        borderRadius,
        sketchPaint,
        Random(rect.hashCode + 1),
        scale: scale,
      );
    }
  }

  Path _createWobblyPath(
    Rect rect,
    double radius,
    Random random, {
    double scale = 1.0,
  }) {
    final path = Path();

    double wobble() => (random.nextDouble() - 0.5) * 2.0 * scale;

    // Corners with slight irregularity
    final tr = Radius.circular(radius + wobble());
    final tl = Radius.circular(radius + wobble());
    final br = Radius.circular(radius + wobble());
    final bl = Radius.circular(radius + wobble());

    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: tl,
      topRight: tr,
      bottomLeft: bl,
      bottomRight: br,
    );

    path.addRRect(rrect);
    // Note: We could manually generate a wobbly path for the fill,
    // but a slightly irregular RRect is usually enough for the background.
    return path;
  }

  void _drawSketchyBorder(
    Canvas canvas,
    Rect rect,
    double radius,
    Paint paint,
    Random random, {
    double scale = 1.0,
  }) {
    // Helper for wobbly points
    Offset wobble(Offset p, double amount) =>
        p +
        Offset(
          (random.nextDouble() - 0.5) * amount * scale,
          (random.nextDouble() - 0.5) * amount * scale,
        );

    // We draw 4 separate lines with overshoots
    final overshoot = (4.0 + random.nextDouble() * 2.0) * scale;
    final amount = 2.4 * scale;

    // Top edge
    _drawWobblyLine(
      canvas,
      wobble(Offset(rect.left + radius, rect.top), amount),
      wobble(Offset(rect.right - radius, rect.top), amount),
      paint,
      random,
      overshootStart: overshoot,
      overshootEnd: overshoot,
      scale: scale,
    );

    // Right edge
    _drawWobblyLine(
      canvas,
      wobble(Offset(rect.right, rect.top + radius), amount),
      wobble(Offset(rect.right, rect.bottom - radius), amount),
      paint,
      random,
      overshootStart: overshoot,
      overshootEnd: overshoot,
    );

    // Bottom edge
    _drawWobblyLine(
      canvas,
      wobble(Offset(rect.right - radius, rect.bottom), amount),
      wobble(Offset(rect.left + radius, rect.bottom), amount),
      paint,
      random,
      overshootStart: overshoot,
      overshootEnd: overshoot,
    );

    // Left edge
    _drawWobblyLine(
      canvas,
      wobble(Offset(rect.left, rect.bottom - radius), amount),
      wobble(Offset(rect.left, rect.top + radius), amount),
      paint,
      random,
      overshootStart: overshoot,
      overshootEnd: overshoot,
    );

    // Corners
    _drawWobblyArc(
      canvas,
      Rect.fromLTRB(
        rect.left,
        rect.top,
        rect.left + radius * 2,
        rect.top + radius * 2,
      ),
      180,
      90,
      paint,
      random,
    );
    _drawWobblyArc(
      canvas,
      Rect.fromLTRB(
        rect.right - radius * 2,
        rect.top,
        rect.right,
        rect.top + radius * 2,
      ),
      270,
      90,
      paint,
      random,
    );
    _drawWobblyArc(
      canvas,
      Rect.fromLTRB(
        rect.right - radius * 2,
        rect.bottom - radius * 2,
        rect.right,
        rect.bottom,
      ),
      0,
      90,
      paint,
      random,
    );
    _drawWobblyArc(
      canvas,
      Rect.fromLTRB(
        rect.left,
        rect.bottom - radius * 2,
        rect.left + radius * 2,
        rect.bottom,
      ),
      90,
      90,
      paint,
      random,
      scale: scale,
    );
  }

  void _drawWobblyLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    Random random, {
    double overshootStart = 0,
    double overshootEnd = 0,
    double scale = 1.0,
  }) {
    final path = Path();

    // Calculate direction vector
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = sqrt(dx * dx + dy * dy);
    final ux = dx / len;
    final uy = dy / len;

    final s = start - Offset(ux * overshootStart, uy * overshootStart);
    final e = end + Offset(ux * overshootEnd, uy * overshootEnd);

    path.moveTo(s.dx, s.dy);

    // Add wobbly segments
    final segments = (len / 8).clamp(3, 15).toInt();
    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final px = s.dx + (e.dx - s.dx) * t;
      final py = s.dy + (e.dy - s.dy) * t;

      // Control point for curve
      final midX = s.dx + (e.dx - s.dx) * (t - 0.5 / segments);
      final midY = s.dy + (e.dy - s.dy) * (t - 0.5 / segments);

      final wobbleFactor = 2.2 * scale;
      final wobbleX = (random.nextDouble() - 0.5) * wobbleFactor;
      final wobbleY = (random.nextDouble() - 0.5) * wobbleFactor;

      path.quadraticBezierTo(midX + wobbleX, midY + wobbleY, px, py);
    }

    canvas.drawPath(path, paint);
  }

  void _drawWobblyArc(
    Canvas canvas,
    Rect rect,
    double startAngleDeg,
    double sweepAngleDeg,
    Paint paint,
    Random random, {
    double scale = 1.0,
  }) {
    final path = Path();
    final startAngle = startAngleDeg * pi / 180;
    final sweepAngle = sweepAngleDeg * pi / 180;

    final center = rect.center;
    final radiusX = rect.width / 2;
    final radiusY = rect.height / 2;

    final steps = (radiusX.clamp(5, 12)).toInt();
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final angle = startAngle + sweepAngle * t;
      final wobbleRadius = (random.nextDouble() - 0.5) * 1.2 * scale;

      final px = center.dx + (radiusX + wobbleRadius) * cos(angle);
      final py = center.dy + (radiusY + wobbleRadius) * sin(angle);

      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HandDrawnBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.width != width ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.fillColor != fillColor;
  }
}

class HandDrawnButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const HandDrawnButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  });

  @override
  State<HandDrawnButton> createState() => _HandDrawnButtonState();
}

class _HandDrawnButtonState extends State<HandDrawnButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor =
        widget.backgroundColor ?? AppColors.getCardColor(context);
    final effectiveTextColor =
        widget.textColor ?? AppColors.getTextMainColor(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: HandDrawnContainer(
          width: widget.width,
          height: widget.height,
          color: effectiveBgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: effectiveTextColor, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: effectiveTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HandDrawnFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color backgroundColor;
  final String? heroTag;
  final double size;

  const HandDrawnFAB({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = AppColors.primary,
    this.heroTag,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      elevation: 0,
      highlightElevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      splashColor: Colors.transparent,
      heroTag: heroTag,
      child: HandDrawnContainer(
        width: size,
        height: size,
        borderRadius: size / 2, // Circle
        color: backgroundColor,
        padding: EdgeInsets.zero,
        child: Center(child: child),
      ),
    );
  }
}

class HandDrawnTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final int? maxLines;
  final TextStyle? style;
  final EdgeInsetsGeometry? contentPadding;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? labelText;

  const HandDrawnTextField({
    super.key,
    this.controller,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.fillColor,
    this.maxLines = 1,
    this.style,
    this.contentPadding,
    this.obscureText = false,
    this.textInputAction,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFillColor = fillColor ?? AppColors.getCardColor(context);
    final effectiveTextColor = AppColors.getTextMainColor(context);
    final effectiveHintColor = AppColors.getTextMutedColor(context);
    final effectiveBorderColor = AppColors.getBorderColor(context);

    return HandDrawnContainer(
      color: effectiveFillColor,
      borderRadius: 12,
      borderColor: effectiveBorderColor,
      borderWidth: 1.5,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        obscureText: obscureText,
        textInputAction: textInputAction,
        onChanged: onChanged,
        style:
            style ??
            TextStyle(
              fontSize: 16,
              color: effectiveTextColor,
              fontWeight: FontWeight.w500,
            ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: effectiveHintColor),
          hintText: hintText,
          hintStyle: TextStyle(color: effectiveHintColor),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding:
              contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class HandDrawnLinePainter extends CustomPainter {
  final Color color;
  final double width;
  final Axis axis;

  HandDrawnLinePainter({
    required this.color,
    required this.width,
    this.axis = Axis.horizontal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(color.hashCode);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final sketchPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = (min(size.width, size.height) / 80).clamp(0.2, 1.0);

    if (axis == Axis.horizontal) {
      final start = Offset(0, size.height / 2);
      final end = Offset(size.width, size.height / 2);
      _drawWobblyLine(canvas, start, end, paint, random, scale: scale);
      _drawWobblyLine(
        canvas,
        start + const Offset(0, 0.5),
        end + const Offset(0, 0.5),
        sketchPaint,
        Random(color.hashCode + 1),
        scale: scale,
      );
    } else {
      final start = Offset(size.width / 2, 0);
      final end = Offset(size.width / 2, size.height);
      _drawWobblyLine(canvas, start, end, paint, random, scale: scale);
      _drawWobblyLine(
        canvas,
        start + const Offset(0.5, 0),
        end + const Offset(0.5, 0),
        sketchPaint,
        Random(color.hashCode + 1),
        scale: scale,
      );
    }
  }

  void _drawWobblyLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    Random random, {
    double scale = 1.0,
  }) {
    final path = Path();
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = sqrt(dx * dx + dy * dy);

    path.moveTo(start.dx, start.dy);

    final segments = (len / 10).clamp(3, 20).toInt();
    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final px = start.dx + dx * t;
      final py = start.dy + dy * t;

      final midX = start.dx + dx * (t - 0.5 / segments);
      final midY = start.dy + dy * (t - 0.5 / segments);

      final wobbleFactor = 2.5 * scale;
      final wobbleX = (random.nextDouble() - 0.5) * wobbleFactor;
      final wobbleY = (random.nextDouble() - 0.5) * wobbleFactor;

      path.quadraticBezierTo(midX + wobbleX, midY + wobbleY, px, py);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HandDrawnLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.width != width ||
        oldDelegate.axis != axis;
  }
}
