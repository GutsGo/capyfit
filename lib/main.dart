import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'models/exercise.dart';
import 'providers/app_provider.dart';
import 'theme/app_colors.dart';
import 'screens/home_page.dart';
import 'screens/plan_page.dart';
import 'screens/diet_page.dart';
import 'screens/exercise_page.dart';
import 'screens/exercise_detail_page.dart';
import 'screens/profile_page.dart';
import 'screens/add_plan_page.dart';
import 'widgets/main_scaffold.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider())],
      child: const MyApp(),
    ),
  );
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
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
              path: '/exercise',
              builder: (context, state) => const ExercisePage(),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) =>
                      ExerciseDetailPage(exercise: state.extra as Exercise),
                ),
              ],
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
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kapi Fit',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.background,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        fontFamily: '.SF Pro Text', // System font on Mac/iOS
      ),
    );
  }
}
