import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/common/conts_text.dart';
import 'package:notes_app/screens/home_page.dart';
import 'package:notes_app/screens/login_screen.dart';
import 'package:notes_app/screens/notes_adding_screen.dart';
import 'package:notes_app/screens/sign_up_screen.dart';
import 'package:notes_app/viewModel/notes_app_viewModel.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: MaterialApp(
        title: notes,
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const LoginScreen(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/signup':
              return MaterialPageRoute(builder: (context) => const SignUpScreen());
            case '/home':
              return MaterialPageRoute(builder: (context) => HomePage());
            case '/login':
              return MaterialPageRoute(builder: (context) => const LoginScreen());
            case '/notesScreen':
              final args = settings.arguments as NotesArguments?;
              return MaterialPageRoute(
                builder: (context) => NotesAddingScreen(
                  args?.noteText,
                  args?.description,
                  args?.tags,
                  args?.documentId,
                ),
              );
              default:
              return _errorRoute();
          }
        },
        initialRoute: '/login',
        debugShowCheckedModeBanner: false,
      ),
    );

  }
}

Route _errorRoute() {
  return MaterialPageRoute(builder: (context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(error),
      ),
      body: const Center(
        child: Text(pageNotFound),
      ),
    );
  });
}

class NotesArguments {
  final String? noteText;
  final String? description;
  final List<String>? tags;
  final String? documentId;

  NotesArguments(this.noteText, this.description, this.tags, this.documentId);
}

