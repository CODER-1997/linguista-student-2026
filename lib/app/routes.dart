import 'package:get/get.dart';

import '../screens/login/login_screen.dart';
import '../screens/student/student_home_screen.dart';
import '../screens/admin/admin_home_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const studentHome = '/student-home';
  static const adminHome = '/admin-home';

  static final pages = <GetPage>[
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: studentHome, page: () => const StudentHomeScreen()),
    GetPage(name: adminHome, page: () => const AdminHomeScreen()),
  ];
}