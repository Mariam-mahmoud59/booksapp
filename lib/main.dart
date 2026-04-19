import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'services/database_helper.dart';
import 'services/supabase_service.dart';
import 'services/connectivity_service.dart';
import 'services/sync_service.dart';
import 'repositories/story_repository.dart';
import 'providers/story_provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  try {
    await SupabaseService().initialize();
  } catch (e) {
    debugPrint('[Main] Supabase init failed (offline mode): $e');
  }

  // Initialize local database
  await DatabaseHelper().database;

  // Initialize connectivity monitoring
  await ConnectivityService().initialize();

  // Initialize sync service (hooks into connectivity)
  SyncService().initialize();

  // Seed database with mock data on first launch
  await StoryRepository().seedIfNeeded();

  runApp(const StoryBookCreatorApp());
}

class StoryBookCreatorApp extends StatelessWidget {
  const StoryBookCreatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthState()),
        ChangeNotifierProvider(create: (_) => StoryProvider()..loadStories()),
      ],
      child: MaterialApp.router(
        title: 'Story Book Creator',
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
