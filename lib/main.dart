import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_colors.dart';
import 'core/router/app_router.dart';
import 'core/router/connectivity_wrapper.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://knzoqcvlxmgsxgooizuk.supabase.co',
  );
  const supabaseKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtuem9xY3ZseG1nc3hnb29penVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTQwNTcsImV4cCI6MjA5NTkzMDA1N30.wttuOVO3mACoWdhtbJ9pklOwn1J0EwzPVWfjMPmfYnY',
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primary,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  if (supabaseUrl.isEmpty ||
      supabaseKey.isEmpty ||
      supabaseUrl.contains('example.supabase.co')) {
    runApp(const SupabaseConfigErrorApp());
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  final router = AppRouter.router;

  runApp(
    ProviderScope(
      child: MaterialApp.router(
        title: 'ParkSmart',
        theme: AppTheme.themeData(),
        routerConfig: router,
        builder: (context, child) {
          return ConnectivityWrapper(
            child: child ?? const SizedBox(),
          );
        },
      ),
    ),
  );
}

class SupabaseConfigErrorApp extends StatelessWidget {
  const SupabaseConfigErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkSmart',
      theme: AppTheme.themeData(),
      home: const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Configuration Supabase manquante.\n\n'
                'Compilez l APK avec --dart-define=SUPABASE_URL=... '
                'et --dart-define=SUPABASE_ANON_KEY=...',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
