import 'package:firebase_auth/firebase_auth.dart';

import '../utilities /flutter_toast.dart';


class FirebaseAuthService {

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print('Something wrong');
    }
    return null;

  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential =await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print('Something wrong');
      // if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      //   print('Invalid email');
      //   //showToast(message: 'Invalid email or password.');
      // } else {
      //   print('Error');
      //   //showToast(message: 'An error occurred: ${e.code}');
      // }
    }
    return null;

  }
}