import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/utilities%20/flutter_toast.dart';
import '../common/conts_text.dart';

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
  }

  void deleteNote(String docId) async {
    try {
      await notes.doc(docId).delete();
      showToast(message: notesDeleterSuccessfully);
    } catch (e) {
      showToast(message: '$errorDeletingNotes : $e');
    }
  }


  Stream<QuerySnapshot> getNotesStreams() {
    final noteStreams = notes.orderBy('timeStamp',descending: true).snapshots();
    return noteStreams;
  }

}