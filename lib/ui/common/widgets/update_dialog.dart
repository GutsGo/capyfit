import 'package:flutter/material.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/data/services/app_update_service.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  static Future<void> show(BuildContext context, UpdateInfo updateInfo) {
    return showDialog(
      context: context,
      barrierDismissible: !updateInfo.isForceUpdate,
      routeSettings: const RouteSettings(name: '/update_dialog'),
      builder: (context) => PopScope(
        canPop: !updateInfo.isForceUpdate,
        child: UpdateDialog(updateInfo: updateInfo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: HandDrawnContainer(
          color: AppColors.getBackgroundColor(context),
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.system_update,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '发现新版本 ${updateInfo.latestVersion}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 更新日志
              const Text(
                '更新内容：',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      updateInfo.releaseNotes,
                      style: TextStyle(
                        color: AppColors.getTextMainColor(
                          context,
                        ).withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!updateInfo.isForceUpdate)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        '以后再说',
                        style: TextStyle(
                          color: AppColors.getTextMutedColor(context),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  HandDrawnButton(
                    onPressed: () async {
                      final url = Uri.parse(updateInfo.downloadUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                      if (!updateInfo.isForceUpdate && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    label: '立即下载',
                    backgroundColor: AppColors.primary,
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
}
