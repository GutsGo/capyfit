import 'package:flutter/material.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/data/services/level_service.dart';
import 'package:capyfit/data/utils/constants.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LevelSystemPage extends StatelessWidget {
  const LevelSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          GlobalConstants.profileLevelSystem,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.getTextMainColor(context),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appState, child) {
          final stats = appState.userStats;
          final levelInfo = LevelService.getLevelInfo(stats.activeDays);
          final progress = LevelService.getStageProgress(stats.activeDays);

          return ListView.builder(
            padding: const EdgeInsets.all(16).copyWith(top: 0),
            itemCount: LevelService.realms.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCurrentProgressHeader(
                  context,
                  levelInfo,
                  progress,
                );
              }
              final realm = LevelService.realms[index - 1];
              return _buildRealmSection(context, realm);
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrentProgressHeader(
    BuildContext context,
    LevelInfo levelInfo,
    double progress,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 8),
      child: HandDrawnCard(
        color: levelInfo.mainColor.withValues(alpha: 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: levelInfo.mainColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.sparkles,
                    color: levelInfo.mainColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '当前境界：${levelInfo.fullDisplayName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '获得称号：${levelInfo.title}',
                        style: TextStyle(
                          fontSize: 14,
                          color: levelInfo.mainColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomProgressBar(progress: progress),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '修炼进度',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextMutedColor(context),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: levelInfo.mainColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '“${levelInfo.description}”',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.getTextMutedColor(
                  context,
                ).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealmSection(BuildContext context, RealmData realm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 16, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: realm.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                realm.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: realm.color,
                ),
              ),
            ],
          ),
        ),
        ...realm.stages.map((stage) => _buildStageCard(context, realm, stage)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStageCard(
    BuildContext context,
    RealmData realm,
    StageData stage,
  ) {
    final isMaxDays = stage.maxDays > 10000;
    final dayRange = isMaxDays
        ? '${stage.minDays}天+'
        : '${stage.minDays}-${stage.maxDays}天';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: HandDrawnCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextMainColor(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: realm.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stage.title,
                          style: TextStyle(
                            fontSize: 12,
                            color: realm.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  dayRange,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextMutedColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              stage.description,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.getTextMutedColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
