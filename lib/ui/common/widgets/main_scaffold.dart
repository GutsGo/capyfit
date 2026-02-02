import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/data/utils/constants.dart';
import 'package:capyfit/data/utils/routes.dart';

import 'hand_drawn_widgets.dart';

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
          ? Container(
              decoration: BoxDecoration(
                color: AppColors.getCardColor(context),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showProfileReminder)
                    GestureDetector(
                      onTap: () => context.push(GlobalRoutes.profileSettings),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withOpacity(0.1),
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.accentOrange.withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              LucideIcons.info,
                              color: AppColors.accentOrange,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                GlobalConstants.homeProfileReminder,
                                style: TextStyle(
                                  color: AppColors.accentOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
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
                  SizedBox(
                    height: 2,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: HandDrawnLinePainter(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                    ),
                  ),
                  BottomNavigationBar(
                    currentIndex: widget.selectedIndex,
                    onTap: (index) {
                      context.read<AppProvider>().setTabIndex(index);
                      widget.onItemSelected(index);
                    },
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: AppColors.getCardColor(context),
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor: AppColors.getTextMutedColor(context),
                    selectedFontSize: 12,
                    unselectedFontSize: 12,
                    elevation: 0,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(LucideIcons.home),
                        label: '首页',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(LucideIcons.calendar),
                        label: '计划',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(LucideIcons.utensils),
                        label: '饮食',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(LucideIcons.user),
                        label: '我的',
                      ),
                    ],
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
