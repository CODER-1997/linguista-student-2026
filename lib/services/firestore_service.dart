import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listening_section_model.dart';
import '../models/listening_item_model.dart';
import '../models/video_model.dart';

/// Barcha Firestore o'qish/yozish shu yerda to'planadi —
/// controller'lar UI logikasiga, bu servis ma'lumot bazasiga javobgar.
class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ---------- STUDENTS ----------
  Future<DocumentSnapshot> getStudent(String studentId) {
    return _db.collection('students').doc(studentId).get();
  }

  // ---------- LISTENING SECTIONS (folders) ----------
  Stream<List<ListeningSectionModel>> sectionsStream() {
    return _db
        .collection('listening_sections')
        .orderBy('order')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ListeningSectionModel.fromDoc(d)).toList());
  }

  Future<void> addSection(String title, int order) {
    return _db.collection('listening_sections').add(
          ListeningSectionModel(id: '', title: title, order: order).toMap(),
        );
  }

  Future<void> deleteSection(String sectionId) {
    return _db.collection('listening_sections').doc(sectionId).delete();
  }

  // ---------- LISTENING ITEMS (audio ichida har bir folder) ----------
  Stream<List<ListeningItemModel>> itemsStream(String sectionId) {
    return _db
        .collection('listening_sections')
        .doc(sectionId)
        .collection('items')
        .orderBy('order')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ListeningItemModel.fromDoc(d)).toList());
  }

  Future<void> addItem(String sectionId, String title, String audioUrl, int order, bool isPaid) {
    return _db
        .collection('listening_sections')
        .doc(sectionId)
        .collection('items')
        .add(ListeningItemModel(
      id: '',
      title: title,
      audioUrl: audioUrl,
      order: order,
      isPaid: isPaid,
    ).toMap());
  }
  Future<void> deleteItem(String sectionId, String itemId) {
    return _db
        .collection('listening_sections')
        .doc(sectionId)
        .collection('items')
        .doc(itemId)
        .delete();
  }

  // ---------- VIDEOS ----------
  Stream<List<VideoModel>> videosStream() {
    return _db
        .collection('videos')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((d) => VideoModel.fromDoc(d)).toList());
  }

  Future<void> addVideo(String title, String videoUrl, int order) {
    return _db.collection('videos').add(
          VideoModel(id: '', title: title, videoUrl: videoUrl, order: order).toMap(),
        );
  }

  Future<void> deleteVideo(String videoId) {
    return _db.collection('videos').doc(videoId).delete();
  }
}
