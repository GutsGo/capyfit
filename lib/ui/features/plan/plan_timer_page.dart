import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/data/models/workout_plan.dart';

class PlanTimerPage extends StatefulWidget {
  final WorkoutPlan plan;

  const PlanTimerPage({super.key, required this.plan});

  @override
  State<PlanTimerPage> createState() => _PlanTimerPageState();
}

class _PlanTimerPageState extends State<PlanTimerPage> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = true;
  bool _canPop = false;

  // 长按完成相关
  double _longPressProgress = 0.0;
  Timer? _longPressTimer;
  static const int _longPressDurationMs = 1200; // 1.2秒完成
  static const int _tickMs = 50; // 每50ms更新一次进度

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.plan.duration * 60;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _onComplete();
      }
    });
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _startLongPress() {
    _longPressTimer?.cancel();
    setState(() => _longPressProgress = 0.0);
    _longPressTimer = Timer.periodic(const Duration(milliseconds: _tickMs), (
      timer,
    ) {
      setState(() {
        _longPressProgress += _tickMs / _longPressDurationMs;
        if (_longPressProgress >= 1.0) {
          _longPressProgress = 1.0;
          _longPressTimer?.cancel();
          _onComplete();
        }
      });
    });
  }

  void _stopLongPress() {
    _longPressTimer?.cancel();
    setState(() => _longPressProgress = 0.0);
  }

  void _onComplete() {
    _timer?.cancel();
    setState(() => _canPop = true);
    final todayStr = DateTime.now().toString().split(' ')[0];
    context.read<AppProvider>().togglePlanComplete(
      widget.plan.id,
      forDate: todayStr,
    );
    context.pop();
    showHandDrawnSnackBar(context, '太棒了！计划已完成 ✨');
  }

  void _onInterrupt() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: HandDrawnContainer(
          color: AppColors.getBackgroundColor(context),
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '确认中断',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('确定要放弃本次训练吗？'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '继续训练',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HandDrawnButton(
                    onPressed: () {
                      setState(() => _canPop = true);
                      Navigator.pop(context);
                      if (mounted) context.pop();
                    },
                    label: '放弃',
                    backgroundColor: Colors.redAccent,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _onInterrupt();
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            // 1. Background Gradient (Darker shade)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2C241E), AppColors.primaryDark],
                ),
              ),
            ),

            // 2. Decorative Blobs (Warm Tones)
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 200,
              left: -100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // 3. Frosted Glass Effect (Blur)
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.1,
                  ), // Slight darkness overlay
                ),
              ),
            ),

            // 4. Content
            SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.plan.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Timer Circle with semi-transparent background
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _formatTime(_remainingSeconds),
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildActionButton(
                              icon: _isRunning
                                  ? LucideIcons.pause
                                  : LucideIcons.play,
                              label: _isRunning ? '暂停' : '继续',
                              onTap: _toggleTimer,
                              color: Colors.white.withValues(alpha: 0.2),
                              iconColor: Colors.white,
                            ),
                            const SizedBox(width: 52),
                            _buildLongPressActionButton(
                              icon: LucideIcons.check,
                              label: '提前完成',
                              color: AppColors.accentMint,
                              iconColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(
                        LucideIcons.x,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _onInterrupt,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
    Color? iconColor,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: HandDrawnContainer(
            width: 72,
            height: 72,
            borderRadius: 36,
            color: color,
            child: Center(
              child: Icon(
                icon,
                color:
                    iconColor ??
                    (color == Colors.white ? AppColors.primary : Colors.white),
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLongPressActionButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    Color? iconColor,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => _startLongPress(),
          onTapUp: (_) => _stopLongPress(),
          onTapCancel: () => _stopLongPress(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 进度圆环
              SizedBox(
                width: 84,
                height: 84,
                child: CircularProgressIndicator(
                  value: _longPressProgress,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              // 按钮主体
              HandDrawnContainer(
                width: 72,
                height: 72,
                borderRadius: 36,
                color: color,
                child: Center(
                  child: Transform.scale(
                    scale: 1.0 + (_longPressProgress * 0.1), // 压下时轻微放大
                    child: Icon(
                      icon,
                      color: iconColor ?? Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
