import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

class HandDrawnDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final double? width;

  const HandDrawnDialog({
    super.key,
    required this.title,
    required this.child,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: HandDrawnContainer(
        width: width ?? 300,
        color: AppColors.getCardColor(context),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextMainColor(context),
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

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
  final VoidCallback? onLongPress;
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const HandDrawnButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.fontSize,
    this.padding,
  });

  @override
  State<HandDrawnButton> createState() => _HandDrawnButtonState();
}

class _HandDrawnButtonState extends State<HandDrawnButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _progressController;
  bool _longPressTriggered = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // 长按 1 秒触发
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!_longPressTriggered && widget.onLongPress != null) {
          _longPressTriggered = true;
          widget.onLongPress!();
          // 可以在触发后重置
          _stopLongPress();
        }
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _startLongPress() {
    setState(() {
      _isPressed = true;
      _longPressTriggered = false;
    });
    if (widget.onLongPress != null) {
      _progressController.forward(from: 0);
    }
  }

  void _stopLongPress() {
    setState(() {
      _isPressed = false;
    });
    if (widget.onLongPress != null) {
      if (!_longPressTriggered) {
        _progressController.reverse();
      } else {
        _progressController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor =
        widget.backgroundColor ?? AppColors.getCardColor(context);
    final effectiveTextColor =
        widget.textColor ?? AppColors.getTextMainColor(context);

    return GestureDetector(
      onTapDown: (_) => _startLongPress(),
      onTapUp: (_) {
        if (widget.onLongPress == null) {
          widget.onPressed();
        } else if (!_longPressTriggered) {
          widget.onPressed();
        }
        _stopLongPress();
      },
      onTapCancel: () => _stopLongPress(),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: HandDrawnContainer(
          width: widget.width,
          height: widget.height,
          color: effectiveBgColor,
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  if (_progressController.value > 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          value: _progressController.value,
                          strokeWidth: 3,
                          color: effectiveTextColor,
                          backgroundColor: effectiveTextColor.withOpacity(0.2),
                        ),
                      ),
                    );
                  }
                  if (widget.icon != null) {
                    return Row(
                      children: [
                        Icon(widget.icon, color: effectiveTextColor, size: 20),
                        const SizedBox(width: 8),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              Flexible(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: widget.fontSize ?? 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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

class HandDrawnTextField extends StatefulWidget {
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
  final bool autofocus;

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
    this.autofocus = false,
  });

  @override
  State<HandDrawnTextField> createState() => _HandDrawnTextFieldState();
}

class _HandDrawnTextFieldState extends State<HandDrawnTextField> {
  final LayerLink _layerLink = LayerLink();
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final effectiveFillColor =
        widget.fillColor ?? AppColors.getCardColor(context);
    final effectiveTextColor = AppColors.getTextMainColor(context);
    final effectiveHintColor = AppColors.getTextMutedColor(context);
    final effectiveBorderColor = _errorText != null
        ? Colors.redAccent
        : AppColors.getBorderColor(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return CompositedTransformTarget(
          link: _layerLink,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              HandDrawnContainer(
                color: effectiveFillColor,
                borderRadius: 12,
                borderColor: effectiveBorderColor,
                borderWidth: 1.5,
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: widget.keyboardType,
                  validator: (val) {
                    final result = widget.validator?.call(val);
                    if (result != _errorText) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _errorText = result;
                          });
                        }
                      });
                    }
                    return result;
                  },
                  maxLines: widget.maxLines,
                  obscureText: widget.obscureText,
                  textInputAction: widget.textInputAction,
                  onChanged: (val) {
                    if (_errorText != null) {
                      final result = widget.validator?.call(val);
                      setState(() {
                        _errorText = result;
                      });
                    }
                    widget.onChanged?.call(val);
                  },
                  autofocus: widget.autofocus,
                  style:
                      widget.style ??
                      TextStyle(
                        fontSize: 16,
                        color: effectiveTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                  decoration: InputDecoration(
                    labelText: widget.labelText,
                    labelStyle: TextStyle(color: effectiveHintColor),
                    hintText: widget.hintText,
                    hintStyle: TextStyle(color: effectiveHintColor),
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: widget.suffixIcon,
                    border: InputBorder.none,
                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                    contentPadding:
                        widget.contentPadding ??
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                  ),
                ),
              ),
              if (_errorText != null)
                CompositedTransformFollower(
                  link: _layerLink,
                  targetAnchor: Alignment.bottomLeft,
                  followerAnchor: Alignment.topLeft,
                  showWhenUnlinked: false,
                  offset: const Offset(0, 0),
                  child: _HandDrawnErrorTag(
                    message: _errorText!,
                    maxWidth: constraints.maxWidth,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HandDrawnErrorTag extends StatelessWidget {
  final String message;
  final double maxWidth;

  const _HandDrawnErrorTag({required this.message, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: Alignment.topLeft,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: CustomPaint(
                      size: const Size(12, 6),
                      painter: _StemPainter(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  CustomPaint(
                    painter: _ScribblePainter(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              LucideIcons.alertCircle,
                              color: Colors.redAccent,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              message,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StemPainter extends CustomPainter {
  final Color color;
  _StemPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScribblePainter extends CustomPainter {
  final Color color;

  _ScribblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = Random(size.hashCode);
    final path = Path();

    // 创建一个不规则的、像手绘涂鸦的背景
    double w = size.width;
    double h = size.height;

    path.moveTo(random.nextDouble() * 4, random.nextDouble() * 4);
    path.lineTo(w - random.nextDouble() * 4, random.nextDouble() * 2);
    path.lineTo(w + random.nextDouble() * 2, h - random.nextDouble() * 2);
    path.lineTo(-random.nextDouble() * 2, h + random.nextDouble() * 2);
    path.close();

    canvas.drawPath(path, paint);

    // 添加一些细节干扰线（红笔划过的感觉）
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final startX = random.nextDouble() * w;
      final startY = random.nextDouble() * h;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(
          startX + (random.nextDouble() - 0.5) * 15,
          startY + (random.nextDouble() - 0.5) * 10,
        ),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HandDrawnBottomSheet extends StatelessWidget {
  final Widget child;

  const HandDrawnBottomSheet({super.key, required this.child});

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return HandDrawnBottomSheet(child: builder(context));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HandDrawnContainer(
      color: AppColors.getBackgroundColor(context),
      borderRadius: 32,
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 12,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.getBorderColor(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          child,
          const SizedBox(height: 8),
        ],
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
