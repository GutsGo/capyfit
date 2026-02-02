import 'package:flutter/material.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
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
