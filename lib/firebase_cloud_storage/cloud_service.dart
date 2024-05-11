import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  final CollectionReference notes = FirebaseFirestore.instance.collection('notes');


  Future<void> addNotes(
      String title,
      String description,
      String userId,
      {String? timeStamp}
      ) {
    return notes.add({
      'title': title,
      'description' : description,
      'userId' : userId,
      'timeStamp' : Timestamp.now(),
    });
  }

  // Read the data

  Stream<QuerySnapshot> getNotesStreams() {
    final noteStreams = notes.orderBy('timeStamp',descending: true).snapshots();
    return noteStreams;
  }

}