import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/routes.dart';
import 'controllers/auth_controller.dart';
import 'controllers/listening_controller.dart';
import 'controllers/video_controller.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/session_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  final sessionService = SessionService();
  await sessionService.init();
  Get.put(sessionService);
  Get.put(FirestoreService());
  Get.put(StorageService());

  Get.put(AuthController());
  Get.put(ListeningController());
  Get.put(VideoController());

  final authController = Get.find<AuthController>();
  final initialRoute = await authController.restoreSession();

  // DIAGNOSTIKA — vaqtincha, muammoni topgach olib tashlang
  print('RO\'YXATDAGI ROUTE NOMLARI: ${AppRoutes.pages.map((p) => p.name).toList()}');
  print('BOSHLANG\'ICH ROUTE: $initialRoute');

  runApp(TalabaApp(initialRoute: initialRoute));
}

class TalabaApp extends StatelessWidget {
  final String initialRoute;

  const TalabaApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Talaba App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      getPages: AppRoutes.pages,
      // Xavfsizlik to'ri: nomi mos kelmagan route chaqirilsa,
      // ilova qulab tushmasdan shu ekran ko'rinadi
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => Scaffold(
          body: Center(
            child: Text(
              'Route topilmadi: tekshiring — AppRoutes.pages ro\'yxatida\nyo\'q nom chaqirilgan bo\'lishi mumkin',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}