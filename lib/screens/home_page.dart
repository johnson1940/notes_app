import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../firebase_cloud_storage/cloud_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FireStoreService fireStoreService = FireStoreService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight : 70,
          automaticallyImplyLeading : false,
          title: Row(
            children: [
              Text('All Notes'),
              Spacer(),
              Icon(Icons.search),
              SizedBox(width: 20,),
              PopupMenuButton(
                key: Key('myPopupMenu'),
                child: Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'Sign out',
                    child: Text('Sign out'),
                  ),
                ],
                onSelected: (value) {
                  if(value == 'Sign out') {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              )
              // GestureDetector(
              //   onTap: (){
              //     print('HI');
              //     PopupMenuButton(
              //         itemBuilder: (BuildContext context) {
              //       return [
              //         PopupMenuItem(
              //           child: Text('Sign Out'),
              //           value: 'sign_out',
              //         ),
              //       ];
              //     },
              //     onSelected: (value) {
              //     if (value == 'sign_out') {
              //       Navigator.pushReplacementNamed(context, '/login');
              //     }
              //    });
              //   },
              //     child: Icon(Icons.more_vert)
              // ),
            ],
          ),
          backgroundColor: Color.fromRGBO(252, 208, 75, 1),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: fireStoreService.getNotesStreams(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              List noteList = snapshot.data!.docs;
              print('NoteList : ${noteList}');
              return ListView.builder(
                  itemCount: noteList.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = noteList[index];
                    String docId = document.id;
                    String? currentUserUid = auth.currentUser?.uid;

                    Map<String, dynamic> data = document.data() as Map<
                        String,
                        dynamic>;

                    if (data['userId'] == currentUserUid) {
                      String noteText = data['title'];
                      String description = data['description'];

                      return ListTile(
                        title: Text(noteText),
                        subtitle: Text(description),
                      );
                    }
                    else {
                      return Container();
                    }
                  }
              );
            }
            else {
             return Text('No Notes Found');
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          // isExtended: true,
          child: Icon(Icons.add),
          backgroundColor: Color.fromRGBO(252, 208, 75, 1),
          onPressed: () {
            Navigator.pushNamed(context, '/notesScreen');
          },
        ),
      ),
    );
  }
}
