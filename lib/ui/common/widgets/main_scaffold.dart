import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/data/utils/constants.dart';
import 'package:capyfit/data/utils/routes.dart';

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
    final String location = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;
    final bool showBottomBar = !location.contains('/detail');
    final appState = context.watch<AppProvider>();
    final bool showProfileReminder =
        showBottomBar &&
        (appState.userProfile.height == null ||
            appState.userProfile.weight == null ||
            appState.userProfile.age == null);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: showBottomBar
          ? _buildCapsuleNavigationBar(context, showProfileReminder)
          : null,
    );
  }

  Widget _buildProfileReminder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GestureDetector(
        onTap: () => context.push(GlobalRoutes.profileSettings),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.accentOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.info, color: AppColors.accentOrange, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  GlobalConstants.homeProfileReminder,
                  style: TextStyle(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: AppColors.accentOrange,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapsuleNavigationBar(
    BuildContext context,
    bool showProfileReminder,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showProfileReminder) _buildProfileReminder(context),
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: bottomPadding > 0 ? bottomPadding * 0.5 : 16,
            ),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.getCardColor(context),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / 4;
                  // 背景高亮的宽度和垂直偏移，需与 _buildNavItem 内部保持一致
                  const pillWidth = 54.0;
                  const pillHeight = 30.0;
                  const topPadding = 10.0;

                  return Stack(
                    children: [
                      // 滑动背景块
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutBack,
                        left:
                            widget.selectedIndex * itemWidth +
                            (itemWidth - pillWidth) / 2,
                        top: topPadding,
                        child: Container(
                          width: pillWidth,
                          height: pillHeight,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      // 导航图标 Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(0, LucideIcons.home, '首页'),
                          _buildNavItem(1, LucideIcons.calendar, '计划'),
                          _buildNavItem(2, LucideIcons.utensils, '饮食'),
                          _buildNavItem(3, LucideIcons.user, '我的'),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = widget.selectedIndex == index;
    final color = isSelected
        ? AppColors.primary
        : AppColors.getTextMutedColor(context);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          context.read<AppProvider>().setTabIndex(index);
          widget.onItemSelected(index);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
