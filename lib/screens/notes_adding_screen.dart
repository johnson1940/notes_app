
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../firebase_cloud_storage/cloud_service.dart';
import '../user_auth/fire_base_auth_service.dart';
import '../utilities /reusable_textfield.dart';
import '../viewModel/notes_app_viewModel.dart';

class NotesAddingScreen extends StatefulWidget {
  final String? noteText;
  final String? description;
  final List<dynamic>? tags;

   NotesAddingScreen(
        this.noteText,
        this.description,
        this.tags,
        {super.key}
       );

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

  void _initialize() {
    _titleController.text = widget.noteText ?? _titleController.text;
    _descriptionController.text = widget.description ?? _descriptionController.text;
    final notesProvider = Provider.of<NoteProvider>(context, listen: false);
    notesProvider.fetchNotes(auth.currentUser?.uid);
    notesProvider.addSelectedTags(widget.tags ?? []);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // _titleController.text = widget.noteText ?? _titleController.text;
    // _descriptionController.text = widget.description ?? _descriptionController.text;
    final notesProvider = Provider.of<NoteProvider>(context, listen: true);
    notesProvider.fetchNotes(auth.currentUser?.uid);
    List<DocumentSnapshot> noteList = notesProvider.noteList;

    DateTime dateTime =  Timestamp.now().toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

    // _descriptionController.text = widget.description ?? '';


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            notesProvider.clearSelectedTags();
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
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
                        decoration: InputDecoration(
                          hintText: 'Enter tag name',
                        ),
                      ),
                      SizedBox(height: 20),
                      Wrap(
                        children: [
                          for (var tag in notesProvider.tags)...[
                            GestureDetector(
                              onTap: () {
                                notesProvider.addSelectedTags([tag]);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                margin: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white70,
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
                        notesProvider.addSelectedTags([_tagsController.text]);
                        _tagsController.clear();
                      },
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
        title: Text(''),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(formattedDate),
                  ),
                  IntrinsicWidth(
                    child: PopupMenuButton(
                      color: Color.fromRGBO(246, 245, 245, 1),
                      offset: Offset(0, 40),
                      onSelected: (value) {
                        notesProvider.setNewCategories = notesProvider.categoriesList?[value - 1] ?? '';
                      },
                      itemBuilder: (context) {
                        return List.generate(
                          notesProvider.categoriesList?.length ?? 0,
                              (index) => PopupMenuItem(
                            value: index + 1,
                            child: Text(notesProvider.categoriesList?[index] ?? ''),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(notesProvider.selectedCategories ?? 'Select the Categories'),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_drop_down_outlined)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: notesProvider.tagsSelected.map((tagName) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '# ${tagName}',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 4,),
                          GestureDetector(
                            onTap: () {
                              notesProvider.removeSelectedTag(tagName); // Define this method to remove the tag
                            },
                            child: Icon(
                              Icons.cancel,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          // IconButton(
                          //     iconSize: 15,
                          //     onPressed: (){},
                          //     icon: Icon(Icons.cancel),
                          // )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        filled: false,
                        hintStyle: TextStyle(
                          fontSize: 25,
                          color: Colors.black.withOpacity(0.5),
                        )
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 20,
                decoration: InputDecoration(
                  hintText: 'Notes here',
                  border: InputBorder.none,
                    enabledBorder: InputBorder.none, // Removes the border when the field is enabled (not focused)
                    disabledBorder: InputBorder.none, // Removes the border when the field is disabled
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  filled: false,
                  fillColor: Colors.white,
                    hintStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(0.5),
                    )
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: (){
                    fireStoreService.updateNotes(
                      _titleController.text,
                      _descriptionController.text,
                      user.uid,
                      notesProvider.selectedCategories ?? '',
                      notesProvider.tagsSelected,
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Update'),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save_sharp),
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        onPressed: () {
          String tagsString = _tagsController.text.trim();
          List<String> tags = tagsString.split(',');
          fireStoreService.addNotes(
            _titleController.text,
            _descriptionController.text,
            user.uid,
            notesProvider.selectedCategories ?? '',
            notesProvider.tagsSelected,
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
