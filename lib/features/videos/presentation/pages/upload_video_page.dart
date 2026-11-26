import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/local_video_store.dart';

class UploadVideoPage extends StatefulWidget {
  const UploadVideoPage({super.key});
  @override
  State<UploadVideoPage> createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  final caption = TextEditingController();
  VideoPlayerController? player;
  String? sourcePath;
  bool saving = false;
  String? error;

  Future<void> pick({ImageSource source = ImageSource.gallery}) async {
    try {
      final selected = await ImagePicker().pickVideo(source: source, maxDuration: const Duration(minutes: 5));
      if (selected == null) return;
      final next = VideoPlayerController.file(File(selected.path));
      await next.initialize();
      if (!mounted) { await next.dispose(); return; }
      final old = player;
      setState(() { player = next; sourcePath = selected.path; error = null; });
      await old?.dispose();
      await next.setLooping(true);
      await next.play();
    } catch (e) {
      if (mounted) setState(() => error = 'تعذر فتح الفيديو: $e');
    }
  }

  Future<void> publish() async {
    if (sourcePath == null || saving) return;
    setState(() => saving = true);
    try {
      await LocalVideoStore.instance.publish(sourcePath!, caption.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نشر الفيديو محليًا في الريلز')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() { saving = false; error = 'فشل حفظ الفيديو: $e'; });
    }
  }

  @override
  void dispose() { player?.dispose(); caption.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('نشر فيديو جديد')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      InkWell(
        onTap: saving ? null : () => pick(),
        child: Container(
          height: 300,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: AppColors.surface,
            borderRadius: BorderRadius.circular(20)),
          child: player != null && player!.value.isInitialized
            ? Center(child: AspectRatio(aspectRatio: player!.value.aspectRatio,
                child: VideoPlayer(player!)))
            : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.video_library_outlined, color: AppColors.cyan, size: 60),
                SizedBox(height: 12), Text('اضغط لاختيار فيديو من المعرض'),
              ]),
        ),
      ),
      const SizedBox(height: 15),
      OutlinedButton.icon(onPressed: saving ? null : () => pick(),
        icon: const Icon(Icons.folder_open), label: const Text('اختيار / تغيير الفيديو')),
      const SizedBox(height: 10),
      FilledButton.icon(onPressed: saving ? null : () => pick(source: ImageSource.camera),
        icon: const Icon(Icons.videocam), label: const Text('تصوير فيديو بالكاميرا')),
      const SizedBox(height: 20),
      TextField(controller: caption, maxLength: 220, maxLines: 3,
        decoration: const InputDecoration(labelText: 'وصف الفيديو',
          border: OutlineInputBorder(), hintText: 'اكتب وصفًا للفيديو...')),
      if (error != null) Padding(padding: const EdgeInsets.only(bottom: 10),
        child: Text(error!, style: const TextStyle(color: Colors.redAccent))),
      FilledButton.icon(
        onPressed: sourcePath == null || saving ? null : publish,
        style: FilledButton.styleFrom(backgroundColor: AppColors.pink,
          padding: const EdgeInsets.symmetric(vertical: 16)),
        icon: saving ? const SizedBox(width: 18, height: 18,
          child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.publish),
        label: Text(saving ? 'جاري الحفظ...' : 'نشر في الريلز'),
      ),
      const SizedBox(height: 12),
      const Text('الفيديو محفوظ على هذا الجهاز فقط، ولا يظهر للمستخدمين الآخرين.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    ]),
  );
}
