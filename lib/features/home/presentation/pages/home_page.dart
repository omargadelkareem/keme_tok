import 'package:flutter/material.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await SessionService.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Keme Tok', style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          tooltip: 'تسجيل الخروج',
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('اكتشف عالمك', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('صنّاع محتوى، فيديوهات ولايفات في مكان واحد', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 30),
          _featureTile(Icons.live_tv_rounded, 'لايف دلوقتي', 'اكتشف البثوث المباشرة', AppColors.pink),
          _featureTile(Icons.play_circle_fill_rounded, 'فيديوهات قصيرة', 'محتوى جديد كل يوم', AppColors.cyan),
          _featureTile(Icons.confirmation_number_rounded, 'لايف حصري', 'فعاليات وتذاكر مدفوعة', Colors.deepPurpleAccent),
          _featureTile(Icons.people_alt_rounded, 'المبدعون', 'اتعرف على صناع محتوى جدد', Colors.orangeAccent),
          const SizedBox(height: 20),
          const Text('الصفحة دي بداية تجريبية، هنكمل تصميمها في المرحلة الجاية.', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    ),
  );

  Widget _featureTile(IconData icon, String title, String subtitle, Color color) =>
      Card(
        color: AppColors.surface,
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(.16), child: Icon(icon, color: color)),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
                ],
              )),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      );
}
