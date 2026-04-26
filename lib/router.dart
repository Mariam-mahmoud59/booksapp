import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_stories_screen.dart';
import 'screens/story_creation_screen.dart';
import 'screens/story_editor_screen.dart';
import 'screens/story_details_screen.dart';
import 'screens/reading_mode_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/main_scaffold.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/app/create',
      builder: (context, state) => const StoryCreationScreen(),
    ),
    GoRoute(
      path: '/app/story/:id',
      builder: (context, state) =>
          StoryDetailsScreen(storyId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/app/story/:id/edit',
      builder: (context, state) =>
          StoryEditorScreen(storyId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/app/story/:id/read',
      builder: (context, state) =>
          ReadingModeScreen(storyId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/app/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/app',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/app/stories',
          builder: (context, state) => const MyStoriesScreen(),
        ),
        GoRoute(
          path: '/app/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/app/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
