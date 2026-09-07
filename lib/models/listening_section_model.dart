import 'package:cloud_firestore/cloud_firestore.dart';

class ListeningSectionModel {
  final String id;
  final String title; // masalan: "Foundation"
  final int order;

  ListeningSectionModel({
    required this.id,
    required this.title,
    required this.order,
  });

  factory ListeningSectionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListeningSectionModel(
      id: doc.id,
      title: data['title'] ?? '',
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
