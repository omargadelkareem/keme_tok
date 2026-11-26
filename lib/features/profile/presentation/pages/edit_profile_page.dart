import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/local_profile_store.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}
class _EditProfilePageState extends State<EditProfilePage> {
  final store = LocalProfileStore.instance;
  late final name = TextEditingController(text: store.name);
  late final bio = TextEditingController(text: store.bio);
  String? photo;
  bool saving = false;
  @override
  void initState() { super.initState(); photo = store.photo; }
  @override
  void dispose() { name.dispose(); bio.dispose(); super.dispose(); }
  Future<void> choosePhoto() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75);
      if (picked == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final copy = await File(picked.path).copy('${dir.path}/keme_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');
      if (mounted) setState(() => photo = copy.path);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر اختيار الصورة: $e')));
    }
  }
  Future<void> save() async {
    if (name.text.trim().isEmpty || saving) return;
    setState(() => saving = true);
    try {
      await store.save(name: name.text, bio: bio.text, photo: photo);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
      }
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      Center(child: GestureDetector(onTap: choosePhoto,
        child: CircleAvatar(radius: 52, backgroundColor: AppColors.surface,
          backgroundImage: photo != null && File(photo!).existsSync() ? FileImage(File(photo!)) : null,
          child: photo == null ? const Icon(Icons.add_a_photo_outlined, size: 36) : null))),
      const SizedBox(height: 8),
      TextButton(onPressed: choosePhoto, child: const Text('تغيير الصورة')),
      const SizedBox(height: 20),
      TextField(controller: name, maxLength: 35,
        decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder())),
      const SizedBox(height: 15),
      TextField(controller: bio, maxLength: 150, maxLines: 3,
        decoration: const InputDecoration(labelText: 'النبذة الشخصية', border: OutlineInputBorder())),
      const SizedBox(height: 20),
      FilledButton(onPressed: saving ? null : save, child: Text(saving ? 'جاري الحفظ...' : 'حفظ التغييرات')),
    ]),
  );
}
