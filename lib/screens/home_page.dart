import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../common/conts_text.dart';
import '../firebase_cloud_storage/cloud_service.dart';
import '../model_class/notes_model.dart';
import '../viewModel/notes_app_viewModel.dart';
import 'notes_adding_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FireStoreService fireStoreService = FireStoreService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    context.read<NoteProvider>().setNewCategories = 'All';
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NoteProvider>(context);
    return SafeArea(
      child: Consumer<NoteProvider>(
        builder: (BuildContext context, NoteProvider provider, Widget? child) {
          return Scaffold(
            appBar: provider.isForSearch
                ? AppBar(
              toolbarHeight: 80,
              automaticallyImplyLeading: false,
              title: Padding(
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
                          controller: _searchController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty ? IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: (){
                                _searchController.clear();
                              },
                            ) : const SizedBox(),
                            hintText: searchByTags,
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            notesProvider.filterNotesByTag(value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    if(_searchController.text.isEmpty)
                      GestureDetector(
                        onTap: (){
                          provider.setIsSearch = false;
                        },
                        child: const Text(
                          cancel,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
                : AppBar(
              toolbarHeight: 80,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  const Text(notes),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      provider.setIsSearch = true;
                    },
                    icon: const Icon(Icons.search),
                  ),
                  const SizedBox(width: 20),
                  PopupMenuButton(
                    key: const Key('MyPopupMenu'),
                    child: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: signOut,
                        child: Text(signOut),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == signOut) {
                        FirebaseAuth.instance.signOut();
                        notesProvider.setNewCategories = 'All';
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                  ),
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.only(left: 8,right: 8),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          GestureDetector(
                            onTap: () {
                              notesProvider.setNewCategories = 'All';
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: notesProvider.selectedCategories == 'All'
                                    ? Colors.blue // Change color when selected
                                    : const Color.fromRGBO(246, 245, 245, 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'All',
                                style: TextStyle(
                                    color: notesProvider.selectedCategories == 'All'
                                        ? Colors.white
                                        : Colors.black.withOpacity(0.6)),
                              ),
                            ),
                          ),
                          ...notesProvider.categoriesList!.map((category) {
                            return GestureDetector(
                              onTap: () {
                                notesProvider.setNewCategories = category;
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: category ==
                                      notesProvider.selectedCategories
                                      ? Colors.blue // Change color when selected
                                      : const Color.fromRGBO(246, 245, 245, 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                      color: category ==
                                          notesProvider.selectedCategories
                                          ? Colors.white
                                          : Colors.black.withOpacity(0.6)),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: fireStoreService.getNotesStreams(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        notesProvider.fetchNotes(auth.currentUser?.uid);
                        List<Note> notes = notesProvider.notes;
                        String selectedCategory = notesProvider.selectedCategories ?? 'All';
                        String searchText = _searchController.text;
                        List<Note> filteredNotes = notesProvider.filterNotes(notes, selectedCategory, searchText);
                        if (filteredNotes.isNotEmpty) {
                          return Expanded(
                            child: GridView.builder(
                              itemCount: filteredNotes.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 1.0,
                                crossAxisSpacing: 1.0,
                                childAspectRatio: 0.8,
                              ),
                              itemBuilder: (context, index) {
                                String noteText = filteredNotes[index].title;
                                String description = filteredNotes[index].description;
                                String id = filteredNotes[index].id;
                                List<dynamic> tags = filteredNotes[index].tags;
                                return GestureDetector(
                                  onTap: (){
                                    notesProvider.isForNoteUpdate = true;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NotesAddingScreen(
                                          noteText,
                                          description,
                                          tags,
                                          id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    semanticContainer: true,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    color: const Color.fromRGBO(254, 227, 148,1).withOpacity(0.8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            filteredNotes[index].title,
                                            style: const TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.w400
                                            ),
                                          ),
                                          Text(
                                            filteredNotes[index].description,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 4,
                                          ),
                                          const Spacer(),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: filteredNotes[index].tags.map((tag) {
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
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            DateFormat('yyyy-MM-dd').format(
                                                filteredNotes[index].timeStamp.toDate()
                                            ),
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return const Center(
                            child: Text(
                              '$noNotesFound ☹️',
                            ),
                          );
                        }
                      } else {
                        return const Center(
                            child: CircularProgressIndicator()
                        ); // Placeholder for when data is loading
                      }
                    },
                  )
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: const Color.fromRGBO(10,150,248,1),
              foregroundColor: Colors.white,
              onPressed: () {
                notesProvider.isForNoteUpdate = false;
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

