import 'package:get/get.dart';
import '../models/video_model.dart';
import '../services/firestore_service.dart';

/// Eslatma: video uchun hozircha oddiy (folder'siz) ro'yxat qilib qo'ydim,
/// chunki siz faqat listening'ni folder qilishni aytgansiz. Video'ni ham
/// bo'lim-bo'lim qilish kerak bo'lsa, ListeningController bilan bir xil
/// naqshda (section -> items) qo'shish mumkin.
class VideoController extends GetxController {
  final FirestoreService _firestoreService = Get.find();

  final videos = <VideoModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _firestoreService.videosStream().listen((data) => videos.value = data);
  }

  Future<void> addVideo(String title, String videoUrl) async {
    if (title.trim().isEmpty || videoUrl.trim().isEmpty) return;
    await _firestoreService.addVideo(title.trim(), videoUrl.trim(), videos.length);
  }

  Future<void> deleteVideo(String videoId) {
    return _firestoreService.deleteVideo(videoId);
  }
}
