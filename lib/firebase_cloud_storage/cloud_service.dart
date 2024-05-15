import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  final CollectionReference notes = FirebaseFirestore.instance.collection('notes');


  Future<void> addNotes(
      String title,
      String description,
      String userId,
      String categories,
      List<String> tags,
      {String? timeStamp}
      ) {
    return notes.add({
      'title': title,
      'description' : description,
      'userId' : userId,
      'categories' : categories,
      'tags' : tags,
      'timeStamp' : Timestamp.now(),
    });
  }

  // Read the data

  Stream<QuerySnapshot> getNotesStreams() {
    final noteStreams = notes.orderBy('timeStamp',descending: true).snapshots();
    return noteStreams;
  }

}