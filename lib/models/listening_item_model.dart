import 'package:cloud_firestore/cloud_firestore.dart';

class ListeningItemModel {
  final String id;
  final String title;
  final String audioUrl;
  final int order;
  final bool isPaid;

  ListeningItemModel({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.order,
    this.isPaid = false,
  });

  factory ListeningItemModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListeningItemModel(
      id: doc.id,
      title: data['title'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      order: data['order'] ?? 0,
      isPaid: data['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'audioUrl': audioUrl,
      'order': order,
      'isPaid': isPaid,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}