import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/splash_screen.dart';

class KemeTokApp extends StatelessWidget {
  const KemeTokApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Keme Tok',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    home: const SplashScreen(),
  );
}
