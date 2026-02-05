import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/data/models/medal.dart';
import 'package:capyfit/data/services/medal_service.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class MedalLibraryPage extends StatelessWidget {
  const MedalLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('猛练勋章'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appState, child) {
          final earnedMedals = appState.earnedMedals;
          final allMedalsBase = List<Medal>.from(MedalService.allMedals);

          // Sorting logic:
          // 1. Earned medals first, sorted by earnedDate descending
          // 2. Unearned medals second, in original order
          allMedalsBase.sort((a, b) {
            final earnedA = earnedMedals.any((m) => m.id == a.id);
            final earnedB = earnedMedals.any((m) => m.id == b.id);

            if (earnedA && !earnedB) return -1;
            if (!earnedA && earnedB) return 1;

            if (earnedA && earnedB) {
              final dateA =
                  earnedMedals.firstWhere((m) => m.id == a.id).earnedDate ??
                  DateTime(2000);
              final dateB =
                  earnedMedals.firstWhere((m) => m.id == b.id).earnedDate ??
                  DateTime(2000);
              return dateB.compareTo(dateA); // Descending order
            }

            return 0; // Keep relative order for unearned
          });

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: allMedalsBase.length,
            itemBuilder: (context, index) {
              final medal = allMedalsBase[index];
              final earned = earnedMedals.firstWhere(
                (m) => m.id == medal.id,
                orElse: () => medal,
              );
              final isEarned = earnedMedals.any((m) => m.id == medal.id);

              return _buildMedalCard(
                context,
                medal,
                isEarned,
                earned.earnedDate,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMedalCard(
    BuildContext context,
    Medal medal,
    bool isEarned,
    DateTime? earnedDate,
  ) {
    return GestureDetector(
      onTap: () => _showMedalDetail(context, medal, isEarned, earnedDate),
      child: HandDrawnCard(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        color: isEarned
            ? null
            : AppColors.getCardColor(context).withValues(alpha: 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'medal_${medal.id}',
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isEarned
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : Colors.grey.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isEarned
                      ? Image.asset(
                          medal.image,
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        )
                      : ColorFiltered(
                          colorFilter: const ColorFilter.matrix([
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                          child: Opacity(
                            opacity: 0.6,
                            child: Image.asset(
                              medal.image,
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              medal.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isEarned ? null : AppColors.getTextMutedColor(context),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isEarned ? '已获得' : '未获得',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.getTextMutedColor(
                  context,
                ).withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMedalDetail(
    BuildContext context,
    Medal medal,
    bool isEarned,
    DateTime? earnedDate,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.elasticOut,
              ),
              child: RotationTransition(
                turns: Tween<double>(begin: -0.5, end: 0.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: 'medal_${medal.id}',
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: isEarned
                                ? AppColors.getCardColor(context)
                                : Colors.grey.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: isEarned
                                ? Image.asset(
                                    medal.image,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.contain,
                                  )
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.matrix([
                                      0.2126,
                                      0.7152,
                                      0.0722,
                                      0,
                                      0,
                                      0.2126,
                                      0.7152,
                                      0.0722,
                                      0,
                                      0,
                                      0.2126,
                                      0.7152,
                                      0.0722,
                                      0,
                                      0,
                                      0,
                                      0,
                                      0,
                                      1,
                                      0,
                                    ]),
                                    child: Image.asset(
                                      medal.image,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      HandDrawnCard(
                        color: AppColors.getCardColor(
                          context,
                        ).withValues(alpha: 0.9),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              medal.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getTextMainColor(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isEarned ? '已成功解锁此勋章' : '勋章说明',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.getTextMutedColor(context),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                medal.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.getTextMainColor(context),
                                ),
                              ),
                            ),
                            if (isEarned && earnedDate != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                '解锁于 ${DateFormat('yyyy年MM月dd日').format(earnedDate)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.getTextMutedColor(context),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        '点击任何地方返回',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
