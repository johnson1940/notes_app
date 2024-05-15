import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../firebase_cloud_storage/cloud_service.dart';
import '../viewModel/notes_app_viewModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FireStoreService fireStoreService = FireStoreService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NoteProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: _isSearching
            ? AppBar(
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by tag',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      notesProvider.filterNotesByTag(value);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                  icon: Icon(Icons.cancel),
                ),
              ],
            ),
          ),
          backgroundColor: Color.fromRGBO(252, 208, 75, 1),
        )
            : AppBar(
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Text('All Notes'),
              Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
                icon: Icon(Icons.search),
              ),
              SizedBox(width: 20),
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
                  if (value == 'Sign out') {
                    FirebaseAuth.instance.signOut();
                    notesProvider.setNewCategories = 'Select the categories';
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
          backgroundColor: Color.fromRGBO(252, 208, 75, 1),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15),
          child: Column(
            children: [
              Container(
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(246, 245, 245, 1),
                ),
                child: PopupMenuButton(
                  color: Color.fromRGBO(246, 245, 245, 1),
                  offset: Offset(0, 40),
                  onSelected: (value) {
                    if (value == 0) {
                      // Handle the "All" category selection
                      notesProvider.setNewCategories = 'All'; // Reset the category filter
                    } else {
                      notesProvider.setNewCategories = notesProvider.categoriesList?[value - 1] ?? '';
                    }
                    // Handle selection with the single value
                    print('Selected: $value');
                  },
                  itemBuilder: (context) {
                    // Generate a list of PopupMenuItem widgets using List.generate
                    List<PopupMenuItem> items = [
                      PopupMenuItem(
                        value: 0, // Value for "All" category
                        child: Text('All'), // Text for "All" category
                      ),
                    ];
                    items.addAll(List.generate(
                      notesProvider.categoriesList?.length ?? 0,
                          (index) => PopupMenuItem(
                        value: index + 1, // Adjust the value if needed
                        child: Text(notesProvider.categoriesList?[index] ?? ''), // Adjust the label as needed
                      ),
                    ));
                    return items;
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
                 height: 20,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: fireStoreService.getNotesStreams(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    notesProvider.fetchNotes(auth.currentUser?.uid);
                    List<DocumentSnapshot> noteList = notesProvider.noteList;

                    // Filter notes based on selected category
                    if (notesProvider.selectedCategories != null &&
                        (notesProvider.selectedCategories?.isNotEmpty ?? false) && notesProvider.selectedCategories != 'Select the categories'
                      && (notesProvider.selectedCategories != 'All')) {
                      noteList = noteList.where((note) => note['categories'] == notesProvider.selectedCategories).toList();
                    }
                    else {
                      noteList = notesProvider.noteList;
                    }
                    if (_searchController.text.isNotEmpty) {
                      final searchTag = _searchController.text.toLowerCase();
                      noteList = noteList.where((note) =>
                      note['tags'] != null &&
                          note['tags']
                              .any((tag) => tag.toString().toLowerCase().contains(searchTag)))
                          .toList();
                    }

                    if (noteList.isNotEmpty) {
                      return Expanded(
                        child: GridView.builder(
                          itemCount: noteList.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            childAspectRatio: 1.0,
                          ),
                          itemBuilder: (context, index) {
                            DocumentSnapshot document = noteList[index];
                            String noteText = document['title'];
                            String description = document['description'];
                            List<dynamic> tags = document['tags'];
                            return Card(
                              child: ListTile(
                                title: Text(noteText),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      description,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 4,
                                    ),
                                    SizedBox(height: 4), // Add some vertical spacing between subtitle and additional text
                                    Wrap(
                                      spacing: 8, // Adjust spacing between containers
                                      runSpacing: 4, // Adjust spacing between rows of containers
                                      children: tags.map((tag) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '# $tag',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          padding: EdgeInsets.only(left: 15, right: 15),
                        ),
                      );
                    } else {
                      return Center(child: Text('No Notes Found for the selected category'));
                    }
                  } else {
                    return CircularProgressIndicator(); // Placeholder for when data is loading
                  }
                },
              )

            ],
          ),
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
