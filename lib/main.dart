import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'models/exercise.dart';
import 'providers/app_provider.dart';
import 'theme/app_colors.dart';
// Home module
import 'screens/home/home_page.dart';
// Diet module
import 'screens/diet/diet_page.dart';
import 'screens/diet/diet_library_page.dart';
import 'screens/diet/food_detail_page.dart';
// Exercise module
import 'screens/exercise/exercise_page.dart';
import 'screens/exercise/exercise_detail_page.dart';
// Plan module
import 'screens/plan/plan_page.dart';
import 'screens/plan/add_plan_page.dart';
// Profile module
import 'screens/profile/profile_page.dart';
import 'screens/profile/profile_settings_page.dart';
import 'screens/profile/goals_page.dart';
import 'screens/profile/reminders_page.dart';
import 'screens/profile/data_backup_page.dart';
// Settings module
import 'screens/settings/help_page.dart';
import 'screens/settings/feedback_page.dart';
// Onboarding module
import 'screens/onboarding/onboarding_page.dart';
import 'models/food_database.dart';
import 'widgets/main_scaffold.dart';

late final GoRouter _router;
late final AppProvider _appProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize AppProvider with Hive
  _appProvider = AppProvider();
  await _appProvider.init();

  // Create router once with initial state
  _router = _createRouter(_appProvider.hasUserProfile);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: _appProvider)],
      child: const MyApp(),
    ),
  );
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter _createRouter(bool hasUserProfile) {
  // 开发模式下每次启动都显示引导页，方便调试
  final shouldShowOnboarding = kDebugMode || !hasUserProfile;
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: shouldShowOnboarding ? '/onboarding' : '/',
    routes: [
      GoRoute(
        path: '/onboarding',
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
              GoRoute(path: '/', builder: (context, state) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plan',
                builder: (context, state) => const PlanPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/diet',
                builder: (context, state) => const DietPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/plan/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddPlanPage(),
      ),
      GoRoute(
        path: '/exercise',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExercisePage(),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (context, state) =>
                ExerciseDetailPage(exercise: state.extra as Exercise),
          ),
        ],
      ),
      GoRoute(
        path: '/diet/library',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DietLibraryPage(),
      ),
      GoRoute(
        path: '/diet/food',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            FoodDetailPage(food: state.extra as FoodDatabaseItem),
      ),
      GoRoute(
        path: '/profile/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileSettingsPage(),
      ),
      GoRoute(
        path: '/profile/reminders',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RemindersPage(),
      ),
      GoRoute(
        path: '/profile/goals',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GoalsPage(),
      ),
      GoRoute(
        path: '/profile/backup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DataBackupPage(),
      ),
      GoRoute(
        path: '/profile/help',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HelpPage(),
      ),
      GoRoute(
        path: '/profile/feedback',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FeedbackPage(),
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
      title: 'CapyFit',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: appState.themeMode,
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
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
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
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        fontFamily: '.SF Pro Text',
      ),
    );
  }
}
