import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model_class/notes_model.dart';

class NoteProvider extends ChangeNotifier {
  final List<String> _titles = [];

  void setListOfCategories(List<String> cate){
    _titles.addAll(cate);
    notifyListeners();
  }

  List<String> get categories => _titles;

  void addCategory(String category) {
    _titles.add(category);
    notifyListeners();
  }

  List<DocumentSnapshot> noteList = [];

  List<Note> _notes = [];

  List<Note> get notes => _notes;

  void setNotes(List<Note> notes) {
    _notes = notes;
    notifyListeners();
  }

  bool? _isForUpdate;

  set isForNoteUpdate(bool isForUpdate){
    _isForUpdate = isForUpdate;
    notifyListeners();
  }

  bool? get isForUpdate => _isForUpdate;

  bool _isNotedDeleted = false;

  set setIsNotesDeleted(bool isNotedDeleted) {
    _isNotedDeleted = isNotedDeleted;
    notifyListeners();
  }

  bool get isNotedDeleted => _isNotedDeleted;

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

  List<Note> filterNotes(List<Note> notes, String selectedCategory, String searchText) {
    if (selectedCategory.isNotEmpty &&
        selectedCategory != 'All') {
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

  void addSelectedTags(List<dynamic> tags) {
    for (var tag in tags) {
      String tagName = tag.toString(); // Convert dynamic to string
      if (!_tagsSelected.contains(tagName)) {
        _tagsSelected.add(tagName);
      }
    }
    notifyListeners();
  }

  void clearSelectedTags() {
    _tagsSelected.clear();
  }

  void addTags(List<dynamic> tags) {
    for (var tag in tags) {
      if (!_tags.contains(tag)) {
        _tags.add(tag.toString());
      }
    }
  }

  void removeSelectedTag(String tag) {
    tagsSelected.remove(tag);
    notifyListeners();
  }


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


  bool _obscureText = true;

  bool get obscureText => _obscureText;

  void toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  bool _isForSearch = false;

  bool get isForSearch => _isForSearch;

  set setIsSearch(bool isSearch) {
    _isForSearch = isSearch;
    notifyListeners();
  }
}
