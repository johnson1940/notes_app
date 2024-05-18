import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/common/conts_text.dart';
import 'package:notes_app/common/image_string.dart';
import 'package:provider/provider.dart';
import '../connectivity_service.dart';
import '../firebase_cloud_storage/cloud_service.dart';
import '../viewModel/notes_app_viewModel.dart';

class NotesAddingScreen extends StatefulWidget {
  final String? noteText;
  final String? description;
  final List<dynamic>? tags;
  final String? documentId;

   const NotesAddingScreen(
        this.noteText,
        this.description,
        this.tags,
        this.documentId,
        {super.key}
       );

  @override
  State<NotesAddingScreen> createState() => _NotesAddingScreenState();
}

class _NotesAddingScreenState extends State<NotesAddingScreen> {

  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FireStoreService fireStoreService = FireStoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  late  String? documentId = '';
  final ConnectivityService _connectivityService = ConnectivityService();

  bool isSigningUp = false;

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
    documentId = widget.documentId;
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
    final notesProvider = Provider.of<NoteProvider>(context, listen: true);
    notesProvider.fetchNotes(auth.currentUser?.uid);
    DateTime dateTime =  Timestamp.now().toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            notesProvider.clearSelectedTags();
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 45),
            onSelected: (String result) {
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
               PopupMenuItem<String>(
                value: tags,
                child: GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(addTags),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                                 controller: _tagsController,
                                 decoration: const InputDecoration(
                                  hintText: enterTagName,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Wrap(
                                      children: [
                                        for (var tag in notesProvider.tags)...[
                                          GestureDetector(
                                            onTap: () {
                                              notesProvider.setIsNotesDeleted = false;
                                              notesProvider.addSelectedTags([tag]);
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              margin: const EdgeInsets.all(4),
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
                                    child: const Text(cancel),
                                  ),
                                  ElevatedButton(
                                    child: const Text(add),
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
                  child: Row(
                    children: [
                      Image.asset(
                        tagsImage,
                        width: 18,
                        height: 18,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Text(addTags),
                    ],
                  ),
                ),
              ),
              if(notesProvider.isForUpdate ?? false)...[
              PopupMenuItem<String>(
                value: delete,
                child: GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(confirm),
                          content: const Text(deleteThisNote),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: const Text(cancel),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                fireStoreService.deleteNote(documentId ?? '');
                                Navigator.pop(context);
                              },
                              child: const Text(yes),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.delete,color: Colors.black,),
                      SizedBox(width: 5,),
                      Text(delete),
                    ],
                  ),
                ),
              ),
             ],
            ],
          ),
        ],
        title: const Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(formattedDate),
                  ),
                  IntrinsicWidth(
                    child: PopupMenuButton(
                      color: const Color.fromRGBO(246, 245, 245, 1),
                      offset: const Offset(0, 40),
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
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                                notesProvider.selectedCategories == 'All' ?
                                'Uncategorized' :
                                (notesProvider.selectedCategories ??  'Uncategorized')),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down_outlined)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: notesProvider.tagsSelected.map((tagName) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '# $tagName',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 4,),
                          GestureDetector(
                            onTap: () {
                              notesProvider.removeSelectedTag(tagName); // Define this method to remove the tag
                            },
                            child: const Icon(
                              Icons.cancel,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
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
                      style:  TextStyle(
                        fontSize: 25,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      decoration: InputDecoration(
                        hintText: title,
                        border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 20,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black.withOpacity(0.5),
                ),
                 decoration: InputDecoration(
                     hintText: notesHere,
                     border: InputBorder.none,
                     contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                     filled: false,
                     fillColor: Colors.white,
                     hintStyle: TextStyle(
                       fontSize: 18,
                      color: Colors.black.withOpacity(0.5),
                    )
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        shape: const CircleBorder(),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        onPressed: () {
          _connectivityService.startMonitoring(context);
          (notesProvider.isForUpdate ?? false) ?
          fireStoreService.updateNotes(
            documentId ?? '',
            _titleController.text,
            _descriptionController.text,
            user.uid,
            notesProvider.selectedCategories ?? '',
            notesProvider.tagsSelected,
          ) :
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
        child: const Icon(Icons.check),
      ),
    );
  }
}
