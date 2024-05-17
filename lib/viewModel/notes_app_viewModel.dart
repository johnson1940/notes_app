import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteProvider extends ChangeNotifier {
  List<String> _titles = [];

  void setListOfCategories(List<String> cate){
    _titles.addAll(cate);
    notifyListeners(); // Assuming notifyListeners is defined somewhere else
  }

  List<String> get categories => _titles;

  void addCategory(String category) {
    _titles.add(category);
    print('Categories : ${_titles}');
    notifyListeners(); // Assuming notifyListeners is defined somewhere else
  }

  List<DocumentSnapshot> noteList = [];

  Future<void> fetchNotes(String? currentUserUid) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('notes')
          .where('userId', isEqualTo: currentUserUid)
          .get();
      noteList = querySnapshot.docs;

      _titles = [];
      List<String> categories = [];
      for (var document in noteList) {
        String category = document['categories'];
        List<dynamic> tags = document['tags'];
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

  String _addCategories = 'Select the categories';

  set setNewCategories(String categories){
    _addCategories = categories;
    print('printstate : ${_addCategories}');
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

  // void addTag(String tagName) {
  //   _tags.add(tagName);
  //   print('tags : ${tags}');
  // }

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
    //print('the saved tags : ${_tags}');
  }

  void removeSelectedTag(String tag) {
    tagsSelected.remove(tag);
    notifyListeners();
  }


  void filterNotesByTag(String tag) {
    if (tag.isEmpty) {
      // If tag is empty, reset noteList to show all notes
      _tagsSelected.clear();
    } else {
      // Filter notes based on the entered tag
      _tagsSelected = noteList
          .where((note) => note['tags'] != null && note['tags'].contains(tag))
          .map<List<String>>((note) => List<String>.from(note['tags'])) // Convert dynamic list to List<String>
          .expand((tags) => tags)
          .toSet()
          .toList();
    }
    notifyListeners();
  }

}
