import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:capyfit/data/models/exercise.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/data/models/workout_plan.dart';
// Home module
import 'package:capyfit/ui/features/home/home.dart';
// Diet module
import 'package:capyfit/ui/features/diet/diet.dart';
import 'package:capyfit/ui/features/diet/diet_library_page.dart';
import 'package:capyfit/ui/features/diet/food_detail_page.dart';
// Exercise module
import 'package:capyfit/ui/features/exercise/exercise_page.dart';
import 'package:capyfit/ui/features/exercise/exercise_detail_page.dart';
// Plan module
import 'package:capyfit/ui/features/plan/plan_page.dart';
import 'package:capyfit/ui/features/plan/add_plan_page.dart';
import 'package:capyfit/ui/features/plan/plan_detail_page.dart';
import 'package:capyfit/ui/features/plan/plan_timer_page.dart';
// Profile module
import 'package:capyfit/ui/features/profile/profile.dart';
import 'package:capyfit/ui/features/profile/profile_settings_page.dart';
import 'package:capyfit/ui/features/profile/goals_page.dart';
import 'package:capyfit/ui/features/profile/reminders_page.dart';
import 'package:capyfit/ui/features/profile/data_backup_page.dart';
import 'package:capyfit/ui/features/profile/medal_library_page.dart';
import 'package:capyfit/ui/features/stats/stats_page.dart';
// Settings module
import 'package:capyfit/ui/features/settings/help.dart';
import 'package:capyfit/ui/features/settings/feedback_page.dart';
// Onboarding module
import 'package:capyfit/ui/features/onboarding/onboarding.dart';
import 'package:capyfit/ui/features/profile/about_us_page.dart';
import 'package:capyfit/ui/features/profile/level_system_page.dart';
import 'package:capyfit/ui/common/widgets/webview_page.dart';
import 'package:capyfit/data/models/food_database.dart';
import 'package:capyfit/ui/common/widgets/main_scaffold.dart';
import 'package:capyfit/data/utils/routes.dart';
import 'package:capyfit/data/utils/constants.dart';

// ViewModels
import 'package:capyfit/ui/features/home/home_vm.dart';
import 'package:capyfit/ui/features/diet/diet_vm.dart';
import 'package:capyfit/ui/features/exercise/exercise_vm.dart';
import 'package:capyfit/ui/features/plan/plan_vm.dart';
import 'package:capyfit/ui/features/stats/stats_vm.dart';

late final GoRouter _router;
late final AppProvider _appProvider;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 1. 立即配置沉浸式 UI 样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 2. 初始化核心业务数据 (已优化为分阶段加载)
  _appProvider = AppProvider();
  await _appProvider.init();

  // 3. 构建路由与应用
  _router = _createRouter(_appProvider.hasUserProfile);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _appProvider),
        ChangeNotifierProvider(create: (_) => HomeViewModel()..init()),
        ChangeNotifierProvider(create: (_) => DietViewModel()..init()),
        ChangeNotifierProvider(create: (_) => ExerciseViewModel()..init()),
        ChangeNotifierProvider(create: (_) => PlanViewModel()..init()),
        ChangeNotifierProvider(create: (_) => StatsViewModel()..init()),
      ],
      child: const MyApp(),
    ),
  );

  // 4. 应用构建后第一时间移除启动页，实现丝滑切换
  FlutterNativeSplash.remove();
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter _createRouter(bool hasUserProfile) {
  final shouldShowOnboarding = !hasUserProfile;
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: shouldShowOnboarding
        ? GlobalRoutes.onboarding
        : GlobalRoutes.home,
    routes: [
      GoRoute(
        path: GlobalRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(
            selectedIndex: navigationShell.currentIndex,
            onItemSelected: (index) => navigationShell.goBranch(index),
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: GlobalRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: GlobalRoutes.plan,
                builder: (context, state) => const PlanPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: GlobalRoutes.diet,
                builder: (context, state) => const DietPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: GlobalRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: GlobalRoutes.planAdd,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          if (state.extra is Map<String, dynamic>) {
            final data = state.extra as Map<String, dynamic>;
            return AddPlanPage(
              initialPlan: data['plan'] as WorkoutPlan?,
              date: data['date'] as String?,
            );
          }
          return AddPlanPage(initialPlan: state.extra as WorkoutPlan?);
        },
      ),
      GoRoute(
        path: GlobalRoutes.planDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          if (state.extra is Map<String, dynamic>) {
            final data = state.extra as Map<String, dynamic>;
            return PlanDetailPage(
              plan: data['plan'] as WorkoutPlan,
              date: data['date'] as String?,
            );
          }
          return PlanDetailPage(plan: state.extra as WorkoutPlan);
        },
      ),
      GoRoute(
        path: GlobalRoutes.planTimer,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            PlanTimerPage(plan: state.extra as WorkoutPlan),
      ),
      GoRoute(
        path: GlobalRoutes.exercise,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExercisePage(),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (context, state) {
              if (state.extra is Exercise) {
                return ExerciseDetailPage(exercise: state.extra as Exercise);
              } else if (state.extra is Map<String, dynamic>) {
                final map = state.extra as Map<String, dynamic>;
                return ExerciseDetailPage(
                  exercise: map['exercise'] as Exercise,
                  showCreatePlanButton:
                      map['showCreatePlanButton'] as bool? ?? true,
                );
              }
              // Fallback or error handling if needed, though usually extra is provided
              return ExerciseDetailPage(exercise: state.extra as Exercise);
            },
          ),
        ],
      ),
      GoRoute(
        path: GlobalRoutes.dietLibrary,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DietLibraryPage(),
      ),
      GoRoute(
        path: GlobalRoutes.dietFoodDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            FoodDetailPage(food: state.extra as FoodDatabaseItem),
      ),
      GoRoute(
        path: GlobalRoutes.profileSettings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileSettingsPage(),
      ),
      GoRoute(
        path: GlobalRoutes.profileReminders,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RemindersPage(),
      ),
      GoRoute(
        path: GlobalRoutes.profileGoals,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GoalsPage(),
      ),
      GoRoute(
        path: GlobalRoutes.profileBackup,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DataBackupPage(),
      ),
      GoRoute(
        path: GlobalRoutes.profileHelp,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HelpPage(),
      ),
      GoRoute(
        path: GlobalRoutes.profileFeedback,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FeedbackPage(),
      ),
      GoRoute(
        path: GlobalRoutes.profileAbout,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutUsPage(),
      ),
      GoRoute(
        path: GlobalRoutes.profileLevelSystem,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LevelSystemPage(),
      ),
      GoRoute(
        path: GlobalRoutes.profileMedals,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MedalLibraryPage(),
      ),
      GoRoute(
        path: GlobalRoutes.stats,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StatsPage(),
      ),
      GoRoute(
        path: GlobalRoutes.terms,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WebviewPage(
          title: GlobalConstants.profileTerms,
          url: GlobalConstants.termsUrl,
        ),
      ),
      GoRoute(
        path: GlobalRoutes.privacy,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WebviewPage(
          title: GlobalConstants.profilePrivacy,
          url: GlobalConstants.privacyUrl,
        ),
      ),
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();

    return MaterialApp.router(
      title: GlobalConstants.appNameEn,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: appState.themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      locale: const Locale('zh', 'CN'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.background,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: TextStyle(
            color: AppColors.textMain,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        fontFamily: '.SF Pro Text', // System font on Mac/iOS
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.darkBackground,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: TextStyle(
            color: AppColors.darkTextMain,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        fontFamily: '.SF Pro Text',
      ),
    );
  }
}
