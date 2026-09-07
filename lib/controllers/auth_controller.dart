import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../app/routes.dart';
import '../models/student_model.dart';
import '../services/session_service.dart';

class AuthController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final SessionService _session = Get.find();

  static const _adminPassword = 'mrj6070';

  final isLoading = false.obs;
  final errorText = RxnString();
  final currentStudent = Rxn<StudentModel>();
  final isAdmin = false.obs;

  Future<void> login(String input) async {
    final value = input.trim();
    if (value.isEmpty) {
      errorText.value = 'ID yoki parolni kiriting';
      return;
    }

    isLoading.value = true;
    errorText.value = null;

    try {
      if (value == _adminPassword) {
        await _session.saveSession(role: 'admin');
        isAdmin.value = true;
        Get.offAllNamed(AppRoutes.adminHome);
        return;
      }

      final query = await _firestore
          .collection('LinguistaStudents')
          .where('items.uniqueId', isEqualTo: value)
          .get();

      if (query.docs.isEmpty) {
        errorText.value = 'Bunday ID topilmadi. Qaytadan tekshiring';
        return;
      }

      final doc = query.docs.first;
      final student = StudentModel.fromFirestore(
        doc.id,
        doc['items'] as Map<String, dynamic>,
      );

      currentStudent.value = student;
      isAdmin.value = false;
      await _session.saveSession(role: 'student', studentId: student.id);

     

// Ilovadan foydalanish tarixini yozib qo'yamiz — Analitika shundan foydalanadi
      await doc.reference.update({
        'items.appLastLoginAt': FieldValue.serverTimestamp(),
        'items.appLoginCount': FieldValue.increment(1),
      });

      currentStudent.value = student;
      isAdmin.value = false;
      await _session.saveSession(role: 'student', studentId: student.id);

      Get.offAllNamed(AppRoutes.studentHome);    } catch (e, stackTrace) {
      print('LOGIN ERROR: $e');
      print('STACK TRACE:\n$stackTrace');
      errorText.value = 'Xatolik yuz berdi, qayta urinib ko\'ring';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> restoreSession() async {
    final role = _session.role;

    if (role == 'admin') {
      isAdmin.value = true;
      return AppRoutes.adminHome;
    }

    final studentId = _session.studentId;
    if (role == 'student' && studentId != null) {
      final doc =
      await _firestore.collection('LinguistaStudents').doc(studentId).get();
      if (doc.exists) {
        currentStudent.value = StudentModel.fromFirestore(
          doc.id,
          doc['items'] as Map<String, dynamic>,
        );
        isAdmin.value = false;
        return AppRoutes.studentHome;
      }
    }

    return AppRoutes.login;
  }

  Future<void> logout() async {
    await _session.clear();
    currentStudent.value = null;
    isAdmin.value = false;
    Get.offAllNamed(AppRoutes.login);
  }
}