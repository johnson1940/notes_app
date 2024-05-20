import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/common/colors.dart';
import 'package:notes_app/common/conts_text.dart';
import 'package:notes_app/common/image_string.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import '../connecitivity_service/connectivity_service.dart';
import '../firebase_cloud_storage/cloud_service.dart';
import '../utilities /flutter_toast.dart';
import '../utilities /reusable_textfield.dart';
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


  @override
  void initState() {
    _initialize();
    _connectivityService.startMonitoring(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notesProvider = Provider.of<NoteProvider>(context, listen: false);
      notesProvider.fetchNotes(auth.currentUser?.uid);
      notesProvider.addSelectedTags(widget.tags ?? []);
    });
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _connectivityService.stopMonitoring();
    super.dispose();
  }

  void _initialize() {
    _titleController.text = widget.noteText ?? _titleController.text;
    _descriptionController.text = widget.description ?? _descriptionController.text;
    documentId = widget.documentId;
  }


  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NoteProvider>(context, listen: true);
    notesProvider.fetchNotes(auth.currentUser?.uid);
    DateTime dateTime =  Timestamp.now().toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        onBack: () {
          Navigator.pop(context);
        },
        onTagSelected: (String) {},
        isForUpdate: notesProvider.isForUpdate ?? false,
        documentId: widget.documentId,
        notesProvider:notesProvider,
        controller: _tagsController,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DateAndCategoryRow(formattedDate: formattedDate),
              const SizedBox(height: 10,),
              /// wrap widget to show the tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: notesProvider.tagsSelected.map((tagName) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: appBlue,
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
              /// title form field
              FormContainerWidget(
                controller: _titleController,
                isNoNeedFillColor: true,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.black.withOpacity(0.5),
                  ),
                hintText: title,
              ),
              /// description form field
              FormContainerWidget(
                controller: _descriptionController,
                isNoNeedFillColor: true,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black.withOpacity(0.5),
                ),
                hintText: description,
                maxLines: 100,
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
        backgroundColor: appBlue,
        onPressed: () {
          if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
            showToast( message: emptyNotesErrorMessage);
            return;
          }
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
          Posthog().capture(
            eventName: notesAddingEvent,
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

/// To show the date and the category drop down
class DateAndCategoryRow extends StatelessWidget {
  final String formattedDate;

  const DateAndCategoryRow({
    super.key,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, notesProvider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formattedDate),
            IntrinsicWidth(
              child: PopupMenuButton(
                color: Colors.white,
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
                        notesProvider.selectedCategories == all
                            ? unCategorized
                            : (notesProvider.selectedCategories ?? unCategorized),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down_outlined),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// the app bar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function()? onBack;
  final Function(String)? onTagSelected;
  final bool isForUpdate;
  final String? documentId;
  final NoteProvider notesProvider;
  final TextEditingController controller;

   CustomAppBar({
    super.key,
    required this.onBack,
    this.onTagSelected,
    required this.isForUpdate,
    required this.documentId,
    required this.notesProvider,
    required this.controller,
  });

  final FireStoreService fireStoreService = FireStoreService();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () {
          notesProvider.clearSelectedTags();
          onBack?.call();
        },
      ),
      backgroundColor: Colors.white,
      actions: [
        PopupMenuButton<String>(
          offset: const Offset(0, 45),
          onSelected: onTagSelected,
          itemBuilder: (BuildContext context) => _buildPopupMenuItems(context, controller),
        ),
      ],
      title: const Text(''),
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(BuildContext context, TextEditingController controller) {
    List<PopupMenuEntry<String>> items = [
      PopupMenuItem<String>(
        value: 'tags',
        child: GestureDetector(
          onTap: () => _showAddTagDialog(context,controller),
          child: Row(
            children: [
              Image.asset(
                tagsImage,
                width: 18,
                height: 18,
              ),
              const SizedBox(width: 5),
              const Text('Add Tags'),
            ],
          ),
        ),
      ),
    ];

    if (isForUpdate) {
      items.add(
        PopupMenuItem<String>(
          value: 'delete',
          child: GestureDetector(
            onTap: () => _showDeleteNoteDialog(context),
            child: const Row(
              children: [
                Icon(Icons.delete, color: Colors.black),
                SizedBox(width: 5),
                Text('Delete'),
              ],
            ),
          ),
        ),
      );
    }

    return items;
  }

  void _showAddTagDialog(BuildContext context, TextEditingController controller) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(addTags),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
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
              controller.clear();
            },
            child: Text(cancel,style: TextStyle(color: appBlue)),
          ),
          ElevatedButton(
            child: Text(add,style: TextStyle(color: appBlue),),
            onPressed: () {
              Navigator.pop(context);
              notesProvider.addTags([controller.text]);
              notesProvider.addSelectedTags([controller.text]);
              controller.clear();
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteNoteDialog(BuildContext context) {
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
              child: Text(cancel,style: TextStyle(color: appBlue)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                fireStoreService.deleteNote(documentId ?? '');
                Posthog().capture(
                  eventName: deleteEvent,
                );
                Navigator.pop(context);
              },
              child: Text(yes,style: TextStyle(color: appBlue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
