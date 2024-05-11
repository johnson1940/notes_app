
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../firebase_cloud_storage/cloud_service.dart';
import '../user_auth/fire_base_auth_service.dart';
import '../utilities /reusable_textfield.dart';

class NotesAddingScreen extends StatefulWidget {
  const NotesAddingScreen({super.key});

  @override
  State<NotesAddingScreen> createState() => _NotesAddingScreenState();
}

class _NotesAddingScreenState extends State<NotesAddingScreen> {

  Future<String?> getCurrentFirebaseUserUID() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return null;
    }
  }


  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FireStoreService fireStoreService = FireStoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool isSigningUp = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(252, 208, 75, 1),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            FormContainerWidget(
              controller: _titleController,
              labelText: 'Title',
              hintText: 'Enter title',
            ),
            SizedBox(
              height: 10,
            ),
            FormContainerWidget(
              controller: _descriptionController,
              labelText: 'Description',
              hintText: 'Notes',
              maxLines: 10,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
           child: Icon(Icons.save_sharp),
           backgroundColor: Color.fromRGBO(252, 208, 75, 1),
           onPressed: () {
               fireStoreService.addNotes(
                   _titleController.text,
                   _descriptionController.text,
                    user.uid,
               );
               _titleController.clear();
               _descriptionController.clear();
               Navigator.pop(context);
             },
          ),
      );
  }


}
