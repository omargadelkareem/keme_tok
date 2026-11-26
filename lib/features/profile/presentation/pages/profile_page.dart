import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/session_service.dart';
import '../../../videos/data/local_video_store.dart';
import '../../data/creator_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.creator, this.onLogout});
  final Creator? creator;
  final VoidCallback? onLogout;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final creators = CreatorStore.instance;
  final videos = LocalVideoStore.instance;
  bool get own => widget.creator == null;
  @override
  void initState() {
    super.initState();
    creators.addListener(refresh);
    videos.addListener(refresh);
  }
  void refresh() { if (mounted) setState(() {}); }
  @override
  void dispose() {
    creators.removeListener(refresh);
    videos.removeListener(refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creator = widget.creator;
    final mine = videos.videos;
    final color = creator == null ? AppColors.pink : Color(creator.color);
    final followed = creator != null && creators.isFollowing(creator.id);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !own,
        centerTitle: true,
        title: Text(creator?.handle ?? '@me', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (own) IconButton(onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_outlined), tooltip: 'تسجيل الخروج'),
          if (!own) IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('مشاركة البروفايل ستتاح بعد الربط الحقيقي'))),
            icon: const Icon(Icons.share_outlined)),
        ],
      ),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Column(children: [
          const SizedBox(height: 18),
          CircleAvatar(radius: 47, backgroundColor: color.withOpacity(.18),
            child: Text(creator?.name.substring(0, 1).toUpperCase() ?? 'K',
              style: TextStyle(fontSize: 43, fontWeight: FontWeight.bold, color: color))),
          const SizedBox(height: 14),
          Text(creator?.name ?? 'Keme Creator',
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          if (own) FutureBuilder<String?>(
            future: SessionService.getPhone(),
            builder: (context, snap) => Text(snap.data ?? '@me',
              style: const TextStyle(color: AppColors.textSecondary))),
          if (creator != null) Text(creator.handle,
            style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 23),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _stat(own ? creators.followingCount() : 0, 'المتابَعون'),
            _stat(own ? 0 : (creator?.followers ?? 0) + (followed ? 1 : 0), 'المتابعون'),
            _stat(own ? mine.fold<int>(0, (sum, v) => sum + v.likes) : (creator?.likes ?? 0), 'الإعجابات'),
          ]),
          const SizedBox(height: 20),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Text(creator?.bio ?? 'أهلاً بيكم في صفحتي على Keme Tok ✨',
              textAlign: TextAlign.center)),
          const SizedBox(height: 20),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              Expanded(child: FilledButton(
                onPressed: own
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تعديل بيانات الحساب بعد الربط الحقيقي')))
                  : () { if (creator != null) creators.toggle(creator.id); },
                style: FilledButton.styleFrom(
                  backgroundColor: followed ? AppColors.surface : AppColors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 13)),
                child: Text(own ? 'تعديل الملف الشخصي' : followed ? 'إلغاء المتابعة' : 'متابعة'),
              )),
              const SizedBox(width: 10),
              if (!own) OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرسائل الخاصة بعد الربط الحقيقي'))),
                icon: const Icon(Icons.mail_outline), label: const Text('رسالة')),
            ])),
          const SizedBox(height: 26),
          const Divider(height: 1),
          const Padding(padding: EdgeInsets.symmetric(vertical: 13),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Icon(Icons.grid_on, color: AppColors.pink),
              Icon(Icons.favorite_border, color: AppColors.textSecondary),
              Icon(Icons.lock_outline, color: AppColors.textSecondary),
            ])),
        ])),
        if (own && mine.isNotEmpty)
          SliverPadding(padding: const EdgeInsets.all(2),
            sliver: SliverGrid.builder(
              itemCount: mine.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2,
                childAspectRatio: .72),
              itemBuilder: (context, index) {
                final video = mine[index];
                return _VideoTile(video: video, onDelete: () => _delete(video));
              },
            ))
        else SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 75, horizontal: 30),
          child: Column(children: [
            const Icon(Icons.video_collection_outlined, size: 60, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(own ? 'لسه ما نشرتش فيديوهات' : 'لا توجد فيديوهات تجريبية لهذا المبدع',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary)),
          ]),
        )),
      ]),
    );
  }

  Widget _stat(int value, String label) => SizedBox(width: 106,
    child: Column(children: [
      Text(_compact(value), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]));
  String _compact(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

  Future<void> _delete(LocalVideo video) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('حذف الفيديو؟'),
      content: const Text('سيتم حذف الفيديو من هذا الجهاز نهائيًا.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
      ]));
    if (yes == true) await videos.delete(video.id);
  }
}

class _VideoTile extends StatefulWidget {
  const _VideoTile({required this.video, required this.onDelete});
  final LocalVideo video;
  final VoidCallback onDelete;
  @override
  State<_VideoTile> createState() => _VideoTileState();
}
class _VideoTileState extends State<_VideoTile> {
  VideoPlayerController? player;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final next = VideoPlayerController.file(File(widget.video.path));
    try {
      await next.initialize();
      if (!mounted) { await next.dispose(); return; }
      setState(() => player = next);
    } catch (_) { await next.dispose(); }
  }
  @override
  void dispose() { player?.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onLongPress: widget.onDelete,
    onTap: () => showModalBottomSheet<void>(context: context,
      builder: (ctx) => SafeArea(child: ListTile(
        leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
        title: const Text('حذف الفيديو'),
        onTap: () { Navigator.pop(ctx); widget.onDelete(); },
      ))),
    child: Stack(fit: StackFit.expand, children: [
      const ColoredBox(color: AppColors.surface),
      if (player != null) FittedBox(fit: BoxFit.cover,
        child: SizedBox(width: player!.value.size.width,
          height: player!.value.size.height, child: VideoPlayer(player!))),
      const Center(child: Icon(Icons.play_arrow_rounded, size: 35,
        color: Colors.white70)),
      Positioned(bottom: 7, left: 7, child: Row(children: [
        const Icon(Icons.favorite, size: 13),
        const SizedBox(width: 4),
        Text('${widget.video.likes}', style: const TextStyle(fontSize: 11)),
      ])),
    ]),
  );
}
