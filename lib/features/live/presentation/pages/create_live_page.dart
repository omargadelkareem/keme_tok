import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'live_room_page.dart';
import 'live_camera_preview_page.dart';

class CreateLivePage extends StatefulWidget {
  const CreateLivePage({super.key});

  @override
  State<CreateLivePage> createState() => _CreateLivePageState();
}

class _CreateLivePageState extends State<CreateLivePage> {
  final TextEditingController _titleController = TextEditingController();
  bool _isPaid = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _openLivePreview() {
    final String enteredTitle = _titleController.text.trim();
    final String roomTitle =
        enteredTitle.isEmpty ? 'لايف جديد' : enteredTitle;

    final LiveRoomData room = LiveRoomData(
      'أنت',
      roomTitle,
      '0',
      'تجريبي',
      const Color(0xFF623269),
      paid: _isPaid,
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return LiveRoomPage(room: room);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: <Widget>[
        const SizedBox(height: 10),
        const Text(
          'ابدأ رحلتك كمبدع',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'جهّز غرفة لايف تجريبية قبل ربط الكاميرا والبث الحقيقي',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 25),
        Container(
          height: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: <Color>[
                Color(0xFF672A67),
                Color(0xFF183C4B),
              ],
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.sensors, color: AppColors.cyan, size: 55),
              SizedBox(height: 12),
              Text(
                'GO LIVE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _titleController,
          maxLength: 60,
          decoration: const InputDecoration(
            labelText: 'عنوان اللايف',
            hintText: 'مثلاً: سهرة ودردشة مع أصحابي',
            border: OutlineInputBorder(),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.pink,
          title: const Text('لايف حصري'),
          subtitle: const Text('تجربة شكل الغرفة المدفوعة فقط'),
          value: _isPaid,
          onChanged: (bool value) {
            setState(() {
              _isPaid = value;
            });
          },
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: _openLivePreview,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.pink,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(Icons.videocam),
          label: const Text('معاينة غرفة اللايف'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => LiveCameraPreviewPage(
            title: _titleController.text.trim().isEmpty ? 'لايف جديد' : _titleController.text.trim()))),
          icon: const Icon(Icons.camera_front), label: const Text('تجربة الكاميرا قبل اللايف')),
        const SizedBox(height: 12),
        const Text(
          'يمكن تجربة الكاميرا محليًا، لكن البث للمشاهدين والدفع غير مفعّلين بعد.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
