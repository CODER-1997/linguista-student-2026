import 'package:get_storage/get_storage.dart';

/// Login sessiyasini (rol va talaba ID) qurilmada saqlaydi.
/// Eslatma: GetStorage.init() main.dart'da allaqachon chaqirilgan,
/// shuning uchun bu yerda faqat box ochamiz.
class SessionService {
  late final GetStorage _box;

  Future<void> init() async {
    _box = GetStorage();
  }

  String? get role => _box.read('role');
  String? get studentId => _box.read('studentId');

  Future<void> saveSession({required String role, String? studentId}) async {
    await _box.write('role', role);
    if (studentId != null) await _box.write('studentId', studentId);
  }

  Future<void> clear() async {
    await _box.remove('role');
    await _box.remove('studentId');
  }
}