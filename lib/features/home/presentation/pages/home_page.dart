import 'package:flutter/material.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../videos/presentation/pages/videos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const _items = <_NavItem>[
    _NavItem('الرئيسية', Icons.explore_outlined, Icons.explore),
    _NavItem('فيديوهات', Icons.play_circle_outline, Icons.play_circle_fill),
    _NavItem('لايف', Icons.live_tv_outlined, Icons.live_tv),
    _NavItem('إنشاء', Icons.add_circle_outline, Icons.add_circle),
    _NavItem('حسابي', Icons.person_outline, Icons.person),
  ];

  Future<void> _logout() async {
    await SessionService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _discoverHome(),
              VideosPage(isActive: _selectedIndex == 1),
              _emptySection(Icons.live_tv_rounded, 'البث المباشر',
                  'لايفات مجانية وحصرية في مكان واحد'),
              _emptySection(Icons.add_circle_rounded, 'أنشئ محتوى',
                  'قريبًا: تصوير فيديو أو بدء بث مباشر'),
              _profileSection(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: Color(0xFF2C2C3B))),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  final active = _selectedIndex == index;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedIndex = index),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(active ? item.activeIcon : item.icon,
                                color: active ? AppColors.pink : AppColors.textSecondary,
                                size: index == 3 ? 29 : 25),
                            const SizedBox(height: 5),
                            Text(item.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: active ? AppColors.pink : AppColors.textSecondary,
                                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );

  Widget _discoverHome() => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: 'Keme ', style: TextStyle(color: Colors.white)),
                        TextSpan(text: 'Tok', style: TextStyle(color: AppColors.pink)),
                      ]),
                      style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900),
                    ),
                  ),
                  _headerIcon(Icons.search_rounded, () => _showComingSoon('البحث')),
                  const SizedBox(width: 10),
                  _headerIcon(Icons.notifications_none_rounded,
                      () => _showComingSoon('الإشعارات')),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('عالمك يبدأ هنا ✨',
                      style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 7),
                  const Text('اكتشف ناس جديدة، محتوى مختلف، ولايفات تستاهل',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF59235C), Color(0xFF29203D), Color(0xFF162E3C)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.auto_awesome, color: AppColors.cyan, size: 19),
                          SizedBox(width: 7),
                          Text('اكتشف Keme Tok',
                              style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 13),
                        const Text('المكان اللي بيجمع\nالمبدعين والجمهور',
                            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, height: 1.35)),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => setState(() => _selectedIndex = 2),
                          icon: const Icon(Icons.live_tv, size: 19),
                          label: const Text('استكشف اللايف'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.pink,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _sectionHeader('لايف دلوقتي', 'شوف الكل', () => setState(() => _selectedIndex = 2)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 205,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                scrollDirection: Axis.horizontal,
                children: [
                  _liveCard('موسيقى ووناسة', 'Maya', '1.2K', const Color(0xFF8E326C)),
                  _liveCard('دردشة معانا', 'Adam', '856', const Color(0xFF176A75)),
                  _liveCard('تحدي مباشر', 'Nour', '2.4K', const Color(0xFF6652A6)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: _sectionHeader('مبدعين يستاهلوا المتابعة', 'اكتشف', () => _showComingSoon('المبدعين')),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 145,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _creator('Maya', '@maya.live', AppColors.pink),
                  _creator('Adam', '@adam.creates', AppColors.cyan),
                  _creator('Nour', '@nour.show', Colors.deepPurpleAccent),
                  _creator('Sara', '@sara.vibes', Colors.orangeAccent),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('ليك أنت', 'فيديوهات أكتر', () => setState(() => _selectedIndex = 1)),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () => setState(() => _selectedIndex = 1),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            radius: 27,
                            backgroundColor: Color(0xFF36314C),
                            child: Icon(Icons.play_arrow_rounded, color: AppColors.cyan, size: 34),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('شوف أحدث الفيديوهات', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 5),
                                Text('محتوى قصير على ذوقك',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _headerIcon(IconData icon, VoidCallback onTap) => Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: IconButton(onPressed: onTap, icon: Icon(icon)),
      );

  Widget _sectionHeader(String title, String action, VoidCallback onTap) => Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
          TextButton(onPressed: onTap, child: Text(action, style: const TextStyle(color: AppColors.cyan))),
        ],
      );

  Widget _liveCard(String title, String creator, String viewers, Color color) =>
      GestureDetector(
        onTap: () => _showComingSoon('غرفة اللايف'),
        child: Container(
          width: 154,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, AppColors.surface],
            ),
            borderRadius: BorderRadius.circular(19),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.pink, borderRadius: BorderRadius.circular(6)),
                  child: const Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                ),
                const Spacer(),
                const Icon(Icons.visibility_outlined, size: 13),
                const SizedBox(width: 3),
                Text(viewers, style: const TextStyle(fontSize: 11)),
              ]),
              const Spacer(),
              const Icon(Icons.mic_external_on_rounded, size: 36, color: Colors.white70),
              const Spacer(),
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(creator, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      );

  Widget _creator(String name, String handle, Color color) => Container(
        width: 116,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(.20),
              child: Text(name.substring(0, 1),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 24)),
            ),
            const SizedBox(height: 9),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text(handle, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      );

  Widget _emptySection(IconData icon, String title, String subtitle) => Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.pink, size: 70),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(subtitle, textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );

  Widget _profileSection() => FutureBuilder<String?>(
        future: SessionService.getPhone(),
        builder: (context, snapshot) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.person_rounded, size: 49, color: AppColors.cyan),
                ),
                const SizedBox(height: 16),
                const Text('حسابي', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(snapshot.data ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 25),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                ),
              ],
            ),
          ),
        ),
      );

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title — قريبًا')),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavItem(this.label, this.icon, this.activeIcon);
}
