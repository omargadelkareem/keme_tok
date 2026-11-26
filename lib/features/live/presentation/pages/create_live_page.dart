import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'live_room_page.dart';

class CreateLivePage extends StatefulWidget {
  const CreateLivePage({super.key});
  @override
  State<CreateLivePage> createState() => _CreateLivePageState();
}

class _CreateLivePageState extends State<CreateLivePage> {
  final title = TextEditingController();
  bool paid = false;
  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const SizedBox(height: 10),
      const Text('ابدأ رحلتك كمبدع', style: TextStyle(
        fontSize: 27, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('جهّز غرفة لايف تجريبية قبل ربط الكاميرا والبث الحقيقي',
        style: TextStyle(color: AppColors.textSecondary)),
      const SizedBox(height: 25),
      Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(colors: [
            Color(0xFF672A67), Color(0xFF183C4B)])),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.sensors, color: AppColors.cyan, size: 55),
          SizedBox(height: 12),
          Text('GO LIVE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        ]),
      ),
      const SizedBox(height: 24),
      TextField(controller: title, maxLength: 60,
        decoration: const InputDecoration(labelText: 'عنوان اللايف',
          hintText: 'مثلاً: سهرة ودردشة مع أصحابي',
          border: OutlineInputBorder())),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        activeColor: AppColors.pink,
        title: const Text('لايف حصري'),
        subtitle: const Text('تجربة شكل الغرفة المدفوعة فقط'),
        value: paid, onChanged: (v) => setState(() => paid = v)),
      const SizedBox(height: 22),
      FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.pink,
          padding: const EdgeInsets.symmetric(vertical: 16)),
        icon: const Icon(Icons.videocam),
        label: const Text('معاينة غرفة اللايف'),
        onPressed: () {
          final name = title.text.trim();
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => LiveRoomPage(room: LiveRoomData(
              'أنت', name.isEmpty ? 'لايف جديد' : name, '0', 'تجريبي',
              const Color(0xFF623269), paid: paid))));
        },
      ),
      const SizedBox(height: 12),
      const Text('لا يتم تشغيل الكاميرا أو تحصيل أي مبالغ في هذه المرحلة.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    ],
  );
}
