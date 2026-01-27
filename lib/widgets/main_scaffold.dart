import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const MainScaffold({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: widget.selectedIndex,
          onTap: widget.onItemSelected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: '首页'),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.calendar),
              label: '计划',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.utensils),
              label: '饮食',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.dumbbell),
              label: '动作',
            ),
            BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: '我的'),
          ],
        ),
      ),
    );
  }
}
