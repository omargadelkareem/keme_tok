import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Local camera/microphone test; this does not transmit a live stream.
class LiveCameraPreviewPage extends StatefulWidget {
  const LiveCameraPreviewPage({super.key, required this.title});
  final String title;
  @override
  State<LiveCameraPreviewPage> createState() => _LiveCameraPreviewPageState();
}
class _LiveCameraPreviewPageState extends State<LiveCameraPreviewPage> {
  CameraController? controller;
  bool microphone = true;
  String? error;
  @override
  void initState() { super.initState(); setup(); }
  Future<void> setup() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception('لا توجد كاميرا متاحة');
      final selected = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first);
      final next = CameraController(selected, ResolutionPreset.medium, enableAudio: true);
      await next.initialize();
      if (!mounted) { await next.dispose(); return; }
      setState(() => controller = next);
    } catch (e) { if (mounted) setState(() => error = '$e'); }
  }
  Future<void> switchCamera() async {
    final cameras = await availableCameras();
    if (cameras.length < 2 || controller == null) return;
    final current = controller!;
    final nextCamera = cameras.firstWhere((c) => c.name != current.description.name,
      orElse: () => cameras.first);
    final next = CameraController(nextCamera, ResolutionPreset.medium, enableAudio: true);
    try {
      await next.initialize();
      if (!mounted) { await next.dispose(); return; }
      setState(() => controller = next);
      await current.dispose();
    } catch (e) { await next.dispose(); if (mounted) setState(() => error = '$e'); }
  }
  @override
  void dispose() { controller?.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(child: Stack(children: [
      Positioned.fill(child: controller?.value.isInitialized == true
        ? Center(child: CameraPreview(controller!))
        : Center(child: Text(error ?? 'جاري تشغيل الكاميرا...',
          textAlign: TextAlign.center))),
      Positioned(top: 12, left: 12, right: 12,
        child: Row(children: [
          const Chip(label: Text('معاينة فقط • غير متصل')),
          const Spacer(),
          IconButton(onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white)),
        ])),
      Positioned(bottom: 35, left: 15, right: 15,
        child: Column(children: [
          Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('الكاميرا شغالة على جهازك فقط. لا يوجد بث للمشاهدين.',
            textAlign: TextAlign.center),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton.filledTonal(onPressed: switchCamera,
              icon: const Icon(Icons.flip_camera_android)),
            const SizedBox(width: 18),
            FilledButton.icon(onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.stop_circle_outlined), label: const Text('إنهاء المعاينة')),
          ]),
        ])),
    ])),
  );
}
