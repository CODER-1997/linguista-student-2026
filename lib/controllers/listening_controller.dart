import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/listening_section_model.dart';
import '../models/listening_item_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ListeningController extends GetxController {
  final FirestoreService _firestoreService = Get.find();
  final StorageService _storageService = Get.find();

  final sections = <ListeningSectionModel>[].obs;
  final isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _firestoreService.sectionsStream().listen((data) => sections.value = data);
  }

  // Admin: yangi folder (masalan "Foundation") yaratadi
  Future<bool> addSection(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return false;

    try {
      await _firestoreService.addSection(trimmed, sections.length);
      return true;
    } catch (e, stackTrace) {
      debugPrint('ADD SECTION ERROR: $e');
      debugPrint('STACK TRACE:\n$stackTrace');
      Get.snackbar(
        'Xatolik',
        'Bo\'lim yaratilmadi: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  Future<void> deleteSection(String sectionId) {
    return _firestoreService.deleteSection(sectionId);
  }

  Stream<List<ListeningItemModel>> itemsOf(String sectionId) {
    return _firestoreService.itemsStream(sectionId);
  }

  Future<void> addAudioItem({
    required String sectionId,
    required String title,
    required File audioFile,
    required int order,
    required bool isPaid,
    void Function(double progress)? onProgress,
  }) async {
    isUploading.value = true;
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${title.trim()}';
      final url = await _storageService.uploadAudio(
        sectionId: sectionId,
        fileName: fileName,
        file: audioFile,
        onProgress: onProgress,
      );
      await _firestoreService.addItem(sectionId, title.trim(), url, order, isPaid);
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> deleteItem(String sectionId, String itemId, String audioUrl) async {
    await _storageService.deleteAudio(audioUrl);
    await _firestoreService.deleteItem(sectionId, itemId);
  }
}
