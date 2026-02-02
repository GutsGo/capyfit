import 'package:flutter/material.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'hand_drawn_widgets.dart';

class HandDrawnCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? color;

  const HandDrawnCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.width,
    this.height,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return HandDrawnContainer(
      width: width,
      height: height,
      color: color ?? AppColors.getCardColor(context),
      borderRadius: 20,
      borderWidth: 1.5,
      // No padding here because we want InkWell to fill the container
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class CustomProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const CustomProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return HandDrawnContainer(
      width: double.infinity,
      height: 12, // Slightly taller to account for border
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkInputFill
          : Colors.white,
      borderRadius: 7, // Rounded ends
      borderColor: AppColors.getBorderColor(context),
      borderWidth: 1.2,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.transparent, width: 0),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum ToastType { success, error, info }

void showHandDrawnSnackBar(
  BuildContext context,
  String message, {
  ToastType type = ToastType.success,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  // Determine colors and icon based on type
  final Color backgroundColor;
  final IconData icon;
  final Color textColor = Colors.white;

  switch (type) {
    case ToastType.success:
      backgroundColor = AppColors.accentGreen;
      icon = LucideIcons.checkCircle2;
      break;
    case ToastType.error:
      backgroundColor = Colors.red;
      icon = LucideIcons.alertCircle;
      break;
    case ToastType.info:
      backgroundColor = AppColors.accentBlue;
      icon = LucideIcons.info;
      break;
  }

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: _HandDrawnToastWidget(
          message: message,
          backgroundColor: backgroundColor,
          textColor: textColor,
          icon: icon,
          duration: duration,
          onDismiss: () {
            if (entry.mounted) {
              entry.remove();
            }
          },
        ),
      ),
    ),
  );

  overlay.insert(entry);
}

class _HandDrawnToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDismiss;

  const _HandDrawnToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_HandDrawnToastWidget> createState() => _HandDrawnToastWidgetState();
}

class _HandDrawnToastWidgetState extends State<_HandDrawnToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _offset = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: HandDrawnContainer(
          color: widget.backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: widget.textColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
