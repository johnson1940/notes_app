
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import '../firebase_cloud_storage/cloud_service.dart';
import '../user_auth/fire_base_auth_service.dart';
import '../utilities /reusable_textfield.dart';
import '../viewModel/notes_app_viewModel.dart';

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
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FireStoreService fireStoreService = FireStoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoriesController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  bool isSigningUp = false;

  String? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final notesProvider = Provider.of<NoteProvider>(context,listen: true);
    notesProvider.fetchNotes(auth.currentUser?.uid);
    List<DocumentSnapshot> noteList = notesProvider.noteList;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: (){
                  notesProvider.clearSelectedTags();
                  Navigator.pop(context);
                }
            ),
          backgroundColor: Color.fromRGBO(252, 208, 75, 1),
          actions: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Add Tag'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _tagsController,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                            hintText: 'Enter tag name',
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Wrap(
                          children: [
                            for (var tag in notesProvider.tags)...[
                              GestureDetector(
                                onTap: () {
                                  notesProvider.addSelectedTags(tag);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  margin: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:  Colors.white70,
                                  ),
                                  child: Text(tag),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _tagsController.clear();
                        },
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        child: Text('Add'),
                        onPressed: () {
                          Navigator.pop(context);
                           notesProvider.addTags([_tagsController.text]);
                           notesProvider.addSelectedTags(_tagsController.text);
                          _tagsController.clear();
                        },
                        // onPressed: () {
                        //
                        //   Navigator.pop(context);
                        //    notesProvider.addTag(_tagsController.text);
                        //   _tagsController.clear();
                        // },
                      ),
                    ],
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.bookmark),
              ),
            ),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.bookmark),
          ]
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(
                height: 20,
              ),
              Text('Categories'),
              SizedBox(
                height: 5,
              ),
              Container(
                width: size.width * 1,
                height: 40,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(246, 245, 245, 1),
                ),
                child: PopupMenuButton(
                  color: Color.fromRGBO(246, 245, 245, 1),
                  offset: Offset(0, 40),
                  onSelected: (value) {
                    notesProvider.setNewCategories = notesProvider.categoriesList?[value - 1] ?? '';
                    // Handle selection with the single value
                    print('Selected: $value');
                  },
                  itemBuilder: (context) {
                    // Generate a list of PopupMenuItem widgets using List.generate
                    return List.generate(
                         notesProvider.categoriesList?.length ?? 0, // Number of items you want in the popup menu
                          (index) => PopupMenuItem(
                           value: index + 1, // Adjust the value if needed
                           child: Text(notesProvider.categoriesList?[index] ?? ''), // Adjust the label as needed
                      ),
                    );
                  },

                  child: Row(
                    children: [
                      Padding(
                          padding : EdgeInsets.only(left: 10),
                          child: Text(notesProvider.selectedCategories ?? 'Select the Categories')),
                      Spacer(),
                      Icon(Icons.arrow_drop_down_outlined)
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Wrap(
                spacing: 8, // Adjust spacing between containers
                runSpacing: 8, // Adjust spacing between rows of containers
                children: notesProvider.tagsSelected.map((tagName) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue, // Set background color of container
                      borderRadius: BorderRadius.circular(8), // Optional: Add border radius for rounded corners
                    ),
                    child: Text(
                      '# ${tagName}',
                      style: TextStyle(color: Colors.white), // Set text color
                    ),
                  );
                }).toList(),
              ),
              // TypeAheadField(
              //   itemBuilder: (BuildContext context, value) {  },
              //   onSelected: (Object? value) {  },
              //   suggestionsCallback: (String search) {  },
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
           child: Icon(Icons.save_sharp),
           backgroundColor: Color.fromRGBO(252, 208, 75, 1),
           onPressed: () {
             String tagsString = _tagsController.text.trim(); // Remove leading/trailing whitespace
             List<String> tags = tagsString.split(',');
               fireStoreService.addNotes(
                   _titleController.text,
                   _descriptionController.text,
                    user.uid,
                    notesProvider.selectedCategories ?? '',
                    notesProvider.tagsSelected as List<String>,
               );
               _titleController.clear();
               _descriptionController.clear();
               _tagsController.clear();
                notesProvider.clearSelectedTags();
                Navigator.pop(context);
             },
          ),
      );
  }
}
