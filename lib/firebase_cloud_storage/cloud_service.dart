import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  final CollectionReference notes = FirebaseFirestore.instance.collection('notes');


  Future<String> addNotes(
      String title,
      String description,
      String userId,
      String categories,
      List<String> tags,
      {String? timeStamp}
      ) async {
    DocumentReference docRef = await notes.add({
      'title': title,
      'description' : description,
      'userId' : userId,
      'categories' : categories,
      'tags' : tags,
      'timeStamp' : Timestamp.now(),
    });
    print('doc Id : ${docRef.id}');
    return docRef.id; // Return the document ID
  }

  Future<void> updateNotes(// Add this parameter for document ID
      String title,
      String description,
      String userId,
      String categories,
      List<String> tags,
      {String? timeStamp, String? docId}
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

  Future<void> addOrUpdateNotes(
      String title,
      String description,
      String userId,
      String categories,
      List<String> tags,
      {String? documentId} // Optional document ID for update
      ) async {
    CollectionReference notes = FirebaseFirestore.instance.collection('notes');
    if (documentId != null) {
      // Update existing document
      await notes.doc(documentId).update({
        'title': title,
        'description': description,
        'userId': userId,
        'categories': categories,
        'tags': tags,
        'timeStamp': Timestamp.now(), // Update timestamp if needed
      });
    } else {
      // Add new document
      await notes.add({
        'title': title,
        'description': description,
        'userId': userId,
        'categories': categories,
        'tags': tags,
        'timeStamp': Timestamp.now(),
      });
    }
  }

  // Read the data

  Stream<QuerySnapshot> getNotesStreams() {
    final noteStreams = notes.orderBy('timeStamp',descending: true).snapshots();
    return noteStreams;
  }

}