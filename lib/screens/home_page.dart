import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  bool _isSearching = false;

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
      child: Scaffold(
        appBar: _isSearching
            ? AppBar(

           toolbarHeight: 70,
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
                        contentPadding: EdgeInsets.all(10),
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty ? IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: (){
                            _searchController.clear();
                          },
                        ) : SizedBox(),
                        hintText: 'Search by tag',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        notesProvider.filterNotesByTag(value);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                if(_searchController.text.isEmpty)
                GestureDetector(
                  onTap: (){
                    _isSearching = false;
                  },
                  child: Text(
                    'Cancel',
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
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Text('Notes'),
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
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 8,right: 8),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Wrap(
                    spacing: 8, // Adjust spacing between containers
                    runSpacing: 8, // Adjust spacing between rows of containers
                    children: [
                  // Add the "All" category container
                  GestureDetector(
                    onTap: (){
                     notesProvider.setNewCategories = 'All';
                    },
                    child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: notesProvider.selectedCategories == 'All'
                    ? Colors.blue // Change color when selected
                            : Color.fromRGBO(246, 245, 245, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'All',
                      style: TextStyle(color: notesProvider.selectedCategories == 'All' ?
                      Colors.white :Colors.black.withOpacity(0.6)),
                    ),
                                  ),
                  ),
                                // Map through the categories list
                                ...notesProvider.categoriesList!.map((category) {
                  return GestureDetector(
                    onTap: (){
                      notesProvider.setNewCategories = category;
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: category == notesProvider.selectedCategories
                            ? Colors.blue // Change color when selected
                            : Color.fromRGBO(246, 245, 245, 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(color: category == notesProvider.selectedCategories ?
                        Colors.white : Colors.black.withOpacity(0.6)),
                        ),
                       ),
                      );
                                }).toList(),
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
                            Timestamp timestamp = filteredNotes[index].timeStamp;
                            DateTime dateTime = timestamp.toDate();
                            String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
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
                                color: Color.fromRGBO(254, 227, 148,1).withOpacity(0.8),
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          filteredNotes[index].title,
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w400
                                        ),
                                      ),
                                      Text(
                                        filteredNotes[index].description,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 4,
                                      ),
                                      Spacer(),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: filteredNotes[index].tags.map((tag) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '# $tag',
                                                style: TextStyle(color: Colors.blue),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        DateFormat('yyyy-MM-dd').format(filteredNotes[index].timeStamp.toDate()),
                                        style: TextStyle(color: Colors.grey),
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
          shape: const CircleBorder(),
          backgroundColor: Color.fromRGBO(10,150,248,1),
          foregroundColor: Colors.white,
          onPressed: () {
            notesProvider.isForNoteUpdate = false;
            Navigator.pushNamed(context, '/notesScreen');
          },
          // isExtended: true,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

