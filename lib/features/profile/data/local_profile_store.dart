import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class LocalProfileStore extends ChangeNotifier {
  LocalProfileStore._();
  static final instance = LocalProfileStore._();
  final _box = GetStorage();
  String get name => _box.read<String>('profile_name_v1') ?? 'Keme Creator';
  String get bio => _box.read<String>('profile_bio_v1') ?? 'أهلاً بيكم في صفحتي على Keme Tok ✨';
  String? get photo => _box.read<String>('profile_photo_v1');
  Future<void> save({required String name, required String bio, String? photo}) async {
    await _box.write('profile_name_v1', name.trim());
    await _box.write('profile_bio_v1', bio.trim());
    if (photo != null) await _box.write('profile_photo_v1', photo);
    notifyListeners();
  }
}
