import 'package:flutter/material.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../home/presentation/pages/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    final phone = await SessionService.getPhone();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => phone == null ? const LoginPage() : const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BrandLogo(size: 138, borderRadius: 32),
          SizedBox(height: 8),
          Text('Keme Tok', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Create. Connect. Go Live.', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    ),
  );
}
