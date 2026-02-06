class GlobalConstants {
  static const String cnbIssuesUrl =
      'https://api.cnb.cool/bytebites.ai/CapyFit/-/issues';

  // --- URLs ---
  static const String docsUrl = 'https://capyfit.brace.fun';
  static const String termsUrl = '$docsUrl/terms.html';
  static const String privacyUrl = '$docsUrl/privacy.html';
  static const String updateBaseUrl = '$docsUrl/__dev__';

  // --- UI 字符串 ---
  // App Name
  static const String appName = '猛练豚';
  static const String appNameEn = 'CapyFit';

  // Common
  static const String confirm = '确定';
  static const String cancel = '取消';
  static const String save = '保存';
  static const String delete = '删除';
  static const String edit = '编辑';
  static const String add = '添加';
  static const String loading = '加载中...';
  static const String success = '操作成功';
  static const String error = '发生错误';

  // Home
  static const String homeTitle = '今日训练计划';
  static const String homeProgress = '今日完成进度';
  static const String homeQuickActions = '快捷入口';
  static const String homeExerciseLibrary = '动作库';
  static const String homeDietLibrary = '食物库';
  static const String homeEmptyPlans = '今天还没有计划哦~';
  static const String homeGreetingMorning = '早安';
  static const String homeGreetingAfternoon = '午安';
  static const String homeGreetingEvening = '晚安';
  static const String homeMotto = '今天也要加油哦~';

  // Plan
  static const String planHighIntensity = '高强度';
  static const String planMediumIntensity = '中等强度';
  static const String planLowIntensity = '低强度';

  // Profile
  static const String profileTitle = '个人中心';
  static const String profileThemeToggle = '切换主题模式';
  static const String profileUserDefaultName = '皮大王';
  static const String profileDefaultAvatar = 'assets/logo.jpg';
  static const String profileMemberLevel = '初级会员';
  static const String profileAchievements = '我的成就';
  static const String profileAchievementActiveDays = '坚持天数';
  static const String profileAchievementTotalWorkouts = '完成训练';
  static const String profileAchievementTotalHours = '训练小时';
  static const String profileSettingsHeader = '设置';
  static const String profileAboutHeader = '关于';
  static const String profileSettings = '个人资料';
  static const String profileGoals = '目标设置';
  static const String profileReminders = '提醒设置';
  static const String profileBackup = '数据备份';
  static const String profileHelp = '使用帮助';
  static const String profileFeedback = '意见反馈';
  static const String profileUpdate = '检查更新';
  static const String profileAbout = '关于我们';
  static const String profileTerms = '用户协议';
  static const String profilePrivacy = '隐私政策';
  static const String profileLevelSystem = '等级系统说明';
  static const List<String> profileMottos = [
    '今天也要元气满满哦 ✨',
    '每一滴汗水都是成功的阶梯 💪',
    '坚持就是胜利，卡皮为你加油！🧡',
    '健康生活，从现在开始 🍎',
    '慢慢来，比较快 🐝',
    '做一只猛猛的卡皮巴拉 💪',
  ];
  static const int maxAvatarSize = 3 * 1024 * 1024; // 3MB

  // Onboarding
  static const String onboardingWelcomeSubtitle = '你的专属健身与饮食伙伴';
  static const String onboardingWelcomeDesc = '让我们花几分钟设置你的个人资料\n以便为你提供更精准的建议';
  static const String onboardingStart = '开始设置 →';
  static const String onboardingBodyDataTitle = '身体数据';
  static const String onboardingBodyDataSubtitle = '这些数据帮助我们计算你的每日所需热量';

  // Home Profile Reminder
  static const String homeProfileReminder = '完善身体数据，让卡皮更懂你 →';

  // --- Security ---
  // 用于备份数据的 HMAC 签名私钥
  // 提示：由于是离线单机应用，该密钥编译在代码中。主要用于拦截普通用户的明文篡改行为。
  static const String backupAuthKey = 'CSBK_2026_v2';
}
