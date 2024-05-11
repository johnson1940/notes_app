import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/screens/home_page.dart';
import 'package:notes_app/screens/login_screen.dart';
import 'package:notes_app/screens/notes_adding_screen.dart';
import 'package:notes_app/screens/sign_up_screen.dart';
import 'package:notes_app/user_auth/fire_base_auth_service.dart';


Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    final FirebaseAuthService _auth = FirebaseAuthService();
    String? uid = await _auth.getCurrentFirebaseUserUID();
    String uidAsString = uid ?? "";
    runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
      routes: {
        '/signup': (context) => SignUpScreen(),
        '/home' : (context) => HomePage(),
        '/login' : (context) => LoginScreen(),
        '/notesScreen' : (context) => NotesAddingScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
