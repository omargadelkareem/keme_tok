import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/local_video_store.dart';
import 'upload_video_page.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key, required this.isActive});
  final bool isActive;
  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  final PageController pages = PageController();
  int current = 0;
  final store = LocalVideoStore.instance;

  @override
  void initState() { super.initState(); store.addListener(refresh); }
  void refresh() { if (mounted) setState(() {}); }
  @override
  void dispose() { store.removeListener(refresh); pages.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final videos = store.videos;
    if (videos.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.movie_creation_outlined, size: 75, color: AppColors.cyan),
          const SizedBox(height: 18),
          const Text('ابدأ أول ريلز ليك', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('اختار فيديو من معرض موبايلك وانشره محليًا',
            textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const UploadVideoPage())),
            icon: const Icon(Icons.add), label: const Text('ارفع فيديو'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.pink)),
        ])));
    }
    if (current >= videos.length) current = videos.length - 1;
    return Stack(children: [
      PageView.builder(
        key: const ValueKey('local-reels'),
        controller: pages,
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        onPageChanged: (i) => setState(() => current = i),
        itemBuilder: (context, i) => _ReelSlide(
          key: ValueKey(videos[i].id), video: videos[i],
          active: widget.isActive && i == current,
          onLike: () => store.toggleLike(videos[i].id),
          onComments: () => _comments(videos[i]),
        ),
      ),
      Positioned(top: 10, left: 12, right: 12,
        child: Row(children: [
          const Expanded(child: Text('ليك أنت',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 8, color: Colors.black)]))),
          IconButton(onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const UploadVideoPage())),
            icon: const Icon(Icons.add_circle, color: AppColors.pink, size: 30)),
        ])),
    ]);
  }

  void _comments(LocalVideo video) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(context: context, isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SafeArea(child: SizedBox(height: 350,
          child: Column(children: [
            const Padding(padding: EdgeInsets.all(14),
              child: Text('التعليقات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Expanded(child: ListView(children: [
              if (video.comments.isEmpty) const ListTile(title: Text('لسه مفيش تعليقات')),
              for (final comment in video.comments)
                ListTile(leading: const Icon(Icons.account_circle), title: Text(comment)),
            ])),
            Row(children: [
              Expanded(child: TextField(controller: controller,
                decoration: const InputDecoration(hintText: 'اكتب تعليق...'))),
              IconButton(onPressed: () async {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                await store.addComment(video.id, text);
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              }, icon: const Icon(Icons.send, color: AppColors.cyan)),
            ]),
          ]))),
      ),
    ).whenComplete(controller.dispose);
  }
}

class _ReelSlide extends StatefulWidget {
  const _ReelSlide({super.key, required this.video, required this.active,
    required this.onLike, required this.onComments});
  final LocalVideo video;
  final bool active;
  final VoidCallback onLike, onComments;
  @override
  State<_ReelSlide> createState() => _ReelSlideState();
}

class _ReelSlideState extends State<_ReelSlide> {
  late final VideoPlayerController player;
  bool ready = false, failed = false;
  @override
  void initState() {
    super.initState();
    player = VideoPlayerController.file(File(widget.video.path));
    initialize();
  }
  Future<void> initialize() async {
    try {
      await player.initialize();
      if (!mounted) return;
      await player.setLooping(true);
      if (!mounted) return;
      setState(() => ready = true);
      sync();
    } catch (_) { if (mounted) setState(() => failed = true); }
  }
  void sync() {
    if (!ready) return;
    if (widget.active) { player.play(); } else { player.pause(); }
  }
  @override
  void didUpdateWidget(covariant _ReelSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) sync();
  }
  @override
  void dispose() { player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
    const ColoredBox(color: Colors.black),
    if (ready) GestureDetector(
      onTap: () { setState(() {
        if (player.value.isPlaying) { player.pause(); } else { player.play(); }
      }); },
      child: Center(child: AspectRatio(aspectRatio: player.value.aspectRatio,
        child: VideoPlayer(player))),
    ) else Center(child: failed
      ? const Text('تعذر تشغيل الملف المحلي') : const CircularProgressIndicator()),
    const IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.transparent, Color(0xBB000000)])))),
    Positioned(bottom: 30, left: 18, right: 85, child: Column(
      mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('@me', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        Text(widget.video.caption.isEmpty ? 'فيديو جديد' : widget.video.caption),
        const SizedBox(height: 10),
        const Text('Keme Tok • فيديو محلي', style: TextStyle(color: AppColors.cyan)),
      ],
    )),
    Positioned(right: 16, bottom: 38, child: Column(children: [
      IconButton(onPressed: widget.onLike, icon: Icon(
        widget.video.liked ? Icons.favorite : Icons.favorite_border,
        size: 33, color: widget.video.liked ? AppColors.pink : Colors.white)),
      Text('${widget.video.likes}'),
      const SizedBox(height: 17),
      IconButton(onPressed: widget.onComments,
        icon: const Icon(Icons.mode_comment_outlined, size: 30)),
      Text('${widget.video.comments.length}'),
    ])),
    if (ready && !player.value.isPlaying)
      const Center(child: IgnorePointer(child: Icon(Icons.play_arrow_rounded,
        size: 66, color: Colors.white70))),
  ]);
}
