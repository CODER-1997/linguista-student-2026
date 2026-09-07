import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  final String id;
  final String title;
  final String videoUrl;
  final int order;

  VideoModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.order,
  });

  factory VideoModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoModel(
      id: doc.id,
      title: data['title'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'videoUrl': videoUrl,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
