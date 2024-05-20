import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';

import '../common/colors.dart';
import '../common/conts_text.dart';
import '../common/image_string.dart';
import '../firebase_cloud_storage/cloud_service.dart';
import '../model_class/notes_model.dart';
import '../viewModel/notes_app_viewModel.dart';
import 'notes_adding_screen.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FireStoreService fireStoreService = FireStoreService();

  void _signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: CustomAppBar(
              isForSearch: provider.isForSearch,
              searchController: _searchController,
              onSignOut: () {
                _signOut();
                Posthog().capture(
                  eventName: signOutEvent,
                  );
                },
             ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CategoryFilter(
                    categories: [all, ...provider.categoriesList!],
                    selectedCategory: provider.selectedCategories ?? all,
                    onCategorySelected: (category) {
                      provider.setNewCategories = category;
                    },
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<QuerySnapshot>(
                    stream: fireStoreService.getNotesStreams(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        provider.fetchNotes(auth.currentUser?.uid);
                        List<Note> notes = provider.notes;
                        String selectedCategory = provider.selectedCategories ?? all;
                        String searchText = _searchController.text;
                        List<Note> filteredNotes = provider.filterNotes(notes, selectedCategory, searchText);
                        if (filteredNotes.isNotEmpty) {
                          return Expanded(
                            child: NoteGrid(
                              notes: filteredNotes,
                              onNoteTap: (note) {
                                provider.isForNoteUpdate = true;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotesAddingScreen(
                                      note.title,
                                      note.description,
                                      note.tags,
                                      note.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return Expanded(
                            child: Center(
                              child: Image.asset(emptyImage), // Replace with your empty image asset
                            ),
                          );
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        ); // Placeholder for when data is loading
                      }
                    },
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: Colors.blue, // Replace with your app blue color
              foregroundColor: Colors.white,
              onPressed: () {
                provider.isForNoteUpdate = false;
                Navigator.pushNamed(context, '/notesScreen');
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isForSearch;
  final TextEditingController searchController;
  final VoidCallback onSignOut;

  CustomAppBar({
    required this.isForSearch,
    required this.searchController,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NoteProvider>(context, listen: false);

    return AppBar(
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      title: isForSearch
          ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        searchController.clear();
                      },
                    )
                        : const SizedBox(),
                    hintText: 'Search by tags',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    provider.filterNotesByTag(value);
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (searchController.text.isEmpty)
              GestureDetector(
                onTap: () {
                  provider.setIsSearch = false;
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      )
          : Row(
        children: [
          const Text('Notes'),
          const Spacer(),
          IconButton(
            onPressed: () {
              provider.setIsSearch = true;
            },
            icon: const Icon(Icons.search),
          ),
          const SizedBox(width: 20),
          PopupMenuButton<String>(
            key: const Key('MyPopupMenu'),
            child: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'Sign Out',
                child: Text('Sign Out'),
              ),
            ],
            onSelected: (value) {
              if (value == 'Sign Out') {
                onSignOut();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}


class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  CategoryFilter({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            return GestureDetector(
              onTap: () => onCategorySelected(category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: category == selectedCategory
                      ? Colors.blue // Change color when selected
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: category == selectedCategory
                        ? Colors.white
                        : Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


class NoteGrid extends StatelessWidget {
  final List<Note> notes;
  final Function(Note) onNoteTap;

  const NoteGrid({super.key, required this.notes, required this.onNoteTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: notes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 1.0,
        crossAxisSpacing: 1.0,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final note = notes[index];
        return GestureDetector(
          onTap: () => onNoteTap(note),
          child: Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            color: notesBackGroundColor, // Replace with your background color
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    note.description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  ),
                  const Spacer(),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: note.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '# $tag',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    DateFormat('yyyy-MM-dd').format(note.timeStamp.toDate()),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
