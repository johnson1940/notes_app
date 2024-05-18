import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String categories;
  final List<String> tags;
  final Timestamp timeStamp;

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.categories,
    required this.tags,
    required this.timeStamp,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      categories: data['categories'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      timeStamp: data['timeStamp'] ?? Timestamp.now(),
    );
  }
}