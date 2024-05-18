import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../common/conts_text.dart';
import '../model_class/notes_model.dart';

class NoteProvider extends ChangeNotifier {
  final List<String> _titles = [];

  /// getting the categories from the api
  void setListOfCategories(List<String> cate){
    _titles.addAll(cate);
    notifyListeners();
  }
  List<DocumentSnapshot> noteList = [];

  List<Note> _notes = [];

  List<Note> get notes => _notes;

  /// setting the notes response
  void setNotes(List<Note> notes) {
    _notes = notes;
    notifyListeners();
  }

  bool? _isForUpdate;

  /// setting boolean for the update
  set isForNoteUpdate(bool isForUpdate){
    _isForUpdate = isForUpdate;
    notifyListeners();
  }

  bool? get isForUpdate => _isForUpdate;

  bool _isNotedDeleted = false;

  /// setting boolean for the delete option
  set setIsNotesDeleted(bool isNotedDeleted) {
    _isNotedDeleted = isNotedDeleted;
    notifyListeners();
  }

  bool get isNotedDeleted => _isNotedDeleted;

  /// fetching notes according the userID
  Future<void> fetchNotes(String? currentUserUid) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('notes')
          .where('userId', isEqualTo: currentUserUid)
          .get();
      noteList = querySnapshot.docs;
      List<String> categories = [];
      List<Note> notes = querySnapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
      setNotes(notes);
      for (var note in notes) {
        String category = note.categories ?? '';
        List<dynamic> tags = note.tags;
        if (!categories.contains(category)) {
          categories.add(category);
        }
        addTags(tags);
      }
      setListOfCategories(categories);
    } catch (error) {
      print('Error fetching notes: $error');
    }
  }

  /// filtering notes according to categories
  List<Note> filterNotes(List<Note> notes, String selectedCategory, String searchText) {
    if (selectedCategory.isNotEmpty &&
        selectedCategory != all) {
      notes = notes.where((note) => note.categories == selectedCategory).toList();
    }

    if (searchText.isNotEmpty) {
      final searchTag = searchText.toLowerCase();
      notes = notes.where((note) =>
      note.tags.any((tag) => tag.toLowerCase().contains(searchTag)))
          .toList();
    }
    return notes;
  }

  /// setting categories
  String _addCategories = 'Uncategorized';

  set setNewCategories(String categories){
    _addCategories = categories;
    notifyListeners();
  }

  String? get selectedCategories => _addCategories;

  List<String>? get categoriesList => [
        'Entertainment',
        'Personal',
        'Home',
        'work',
        'Health & Fitness',
        'Travel',
        'Technology',
        'Books & Literature',
        'Others'
  ];

  List<String> _tags = [];

  List<String> get tags => _tags;

  List<String> _tagsSelected = [];

  List<String> get tagsSelected => _tagsSelected;

  /// adding the selected tags to the list
  void addSelectedTags(List<dynamic> tags) {
    for (var tag in tags) {
      String tagName = tag.toString(); // Convert dynamic to string
      if (!_tagsSelected.contains(tagName)) {
        _tagsSelected.add(tagName);
      }
    }
    notifyListeners();
  }

  /// clearing the selected tags
  void clearSelectedTags() {
    _tagsSelected.clear();
  }

  ///adding tags
  void addTags(List<dynamic> tags) {
    for (var tag in tags) {
      if (!_tags.contains(tag)) {
        _tags.add(tag.toString());
      }
    }
  }

  /// removing tags when clear option pressed
  void removeSelectedTag(String tag) {
    tagsSelected.remove(tag);
    notifyListeners();
  }


  /// filtering notes according to the tags
  void filterNotesByTag(String tag) {
    if (tag.isEmpty) {
      _tagsSelected.clear();
    } else {
      _tagsSelected = noteList
          .where((note) => note['tags'] != null && note['tags'].contains(tag))
          .map<List<String>>((note) => List<String>.from(note['tags'])) // Convert dynamic list to List<String>
          .expand((tags) => tags)
          .toSet()
          .toList();
    }
    notifyListeners();
  }


  /// This is for the password obscure Text
  bool _obscureText = true;

  bool get obscureText => _obscureText;

  void toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  /// The boolean for the filter option
  bool _isForSearch = false;

  bool get isForSearch => _isForSearch;

  set setIsSearch(bool isSearch) {
    _isForSearch = isSearch;
    notifyListeners();
  }
}
