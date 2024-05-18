import 'package:firebase_auth/firebase_auth.dart';
import '../common/conts_text.dart';
import '../utilities /flutter_toast.dart';


class FirebaseAuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == emailAlreadyInUse) {
        showToast(message: emailAlreadyInUseErrorText);
      } else {
        showToast(message: '$someErrorHappened ${e.code}');
      }
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential =await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == userNotFound || e.code == wrongPassword) {
        showToast(message: invalidEmailAndPassword);
      } else {
        showToast(message: '$someErrorHappened ${e.code}');
      }
    }
    return null;

  }

  Future<String?> getCurrentFirebaseUserUID() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return null;
    }
  }
}
