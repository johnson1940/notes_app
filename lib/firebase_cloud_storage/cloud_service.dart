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

  Future<void> updateNotes(
      String docId,// Add this parameter for document ID
      String title,
      String description,
      String userId,
      String categories,
      List<String> tags,
      {String? timeStamp}
      ) async {
    await notes.doc(docId).update({
      'title': title,
      'description' : description,
      'userId' : userId,
      'categories' : categories,
      'tags' : tags,
      'timeStamp' : timeStamp != null ? Timestamp.fromDate(DateTime.parse(timeStamp)) : Timestamp.now(), // Update timeStamp if provided
    });
    print('Document with ID $docId updated successfully');
  }

  void deleteNote(String docId) async {
    try {
      await notes.doc(docId).delete();
      print('Note deleted successfully');
    } catch (e) {
      print('Error deleting note: $e');
    }
  }

  // Read the data

  Stream<QuerySnapshot> getNotesStreams() {
    final noteStreams = notes.orderBy('timeStamp',descending: true).snapshots();
    return noteStreams;
  }

}