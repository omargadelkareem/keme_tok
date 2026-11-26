import 'package:get_storage/get_storage.dart';

abstract final class SessionService {
  static const _phoneKey = 'demo_phone';
  static final GetStorage _box = GetStorage();

  static Future<String?> getPhone() async {
    return _box.read<String>(_phoneKey);
  }

  static Future<void> signIn(String phone) async {
    await _box.write(_phoneKey, phone);
  }

  static Future<void> signOut() async {
    await _box.remove(_phoneKey);
  }
}
