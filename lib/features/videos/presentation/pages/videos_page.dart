import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key, required this.isActive});
  final bool isActive;

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  final _pageController = PageController();
  int _currentIndex = 0;
  final Set<int> _liked = <int>{};

  static const _videos = <_DemoVideo>[
    _DemoVideo(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      '@keme.creator', 'أول فيديو على Keme Tok ✨', '12.4K'),
    _DemoVideo(
      'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      '@keme.studio', 'لحظات جديدة كل يوم 🎬', '8.1K'),
  ];

  @override
  void didUpdateWidget(covariant VideosPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videos.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) => _VideoSlide(
          key: ValueKey(index),
          video: _videos[index],
          active: widget.isActive && index == _currentIndex,
          liked: _liked.contains(index),
          onLike: () => setState(() {
            if (!_liked.add(index)) _liked.remove(index);
          }),
          onComment: () => _comments(context),
          onShare: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('المشاركة هتتفعل مع الفيديوهات الحقيقية')),
          ),
        ),
      ),
      const Positioned(
        top: 16, left: 0, right: 0,
        child: IgnorePointer(
          child: Center(
            child: Text('ليك أنت', style: TextStyle(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 12, color: Colors.black)],
            )),
          ),
        ),
      ),
    ],
  );

  void _comments(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (context) => const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('التعليقات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 18),
            Text('هنربط التعليقات بقاعدة البيانات في المرحلة الجاية',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}

class _DemoVideo {
  final String url;
  final String username;
  final String caption;
  final String likes;
  const _DemoVideo(this.url, this.username, this.caption, this.likes);
}

class _VideoSlide extends StatefulWidget {
  const _VideoSlide({
    super.key, required this.video, required this.active, required this.liked,
    required this.onLike, required this.onComment, required this.onShare,
  });
  final _DemoVideo video;
  final bool active;
  final bool liked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  State<_VideoSlide> createState() => _VideoSlideState();
}

class _VideoSlideState extends State<_VideoSlide> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.url));
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      await _controller.setLooping(true);
      if (!mounted) return;
      setState(() => _ready = true);
      _syncPlayback();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _syncPlayback() {
    if (!_ready) return;
    if (widget.active) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void didUpdateWidget(covariant _VideoSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _syncPlayback();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Container(color: Colors.black),
      if (_ready)
        GestureDetector(
          onTap: () => setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          }),
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        )
      else
        Center(child: _failed
          ? const Padding(
              padding: EdgeInsets.all(30),
              child: Text('تعذر تحميل الفيديو. تأكد من اتصال الإنترنت.',
                textAlign: TextAlign.center))
          : const CircularProgressIndicator(color: AppColors.pink)),
      const IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0x55000000), Colors.transparent, Color(0xBB000000)],
              stops: [0, .5, 1],
            ),
          ),
        ),
      ),
      Positioned(
        left: 18, right: 78, bottom: 26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.video.username,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.video.caption,
              style: const TextStyle(fontSize: 14, height: 1.4)),
            const SizedBox(height: 12),
            const Row(children: [
              Icon(Icons.music_note, size: 15, color: AppColors.cyan),
              SizedBox(width: 5),
              Text('Keme Tok • Original sound', style: TextStyle(fontSize: 12)),
            ]),
          ],
        ),
      ),
      Positioned(
        right: 12, bottom: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 23, backgroundColor: AppColors.surface,
              child: Icon(Icons.person, color: Colors.white)),
            const SizedBox(height: 26),
            _action(
              widget.liked ? Icons.favorite : Icons.favorite_border,
              widget.liked ? AppColors.pink : Colors.white,
              widget.video.likes, widget.onLike),
            const SizedBox(height: 22),
            _action(Icons.mode_comment_outlined, Colors.white, 'تعليق', widget.onComment),
            const SizedBox(height: 22),
            _action(Icons.share_outlined, Colors.white, 'مشاركة', widget.onShare),
          ],
        ),
      ),
      if (_ready && !_controller.value.isPlaying)
        const Center(
          child: IgnorePointer(
            child: Icon(Icons.play_arrow_rounded, color: Colors.white70, size: 68),
          ),
        ),
    ],
  );

  Widget _action(IconData icon, Color color, String label, VoidCallback onTap) =>
    InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
        ],
      ),
    );
}
