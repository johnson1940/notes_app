import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/utilities%20/reusable_elevated_button.dart';
import '../common/conts_text.dart';
import '../common/image_string.dart';
import '../connectivity_service.dart';
import '../user_auth/fire_base_auth_service.dart';
import '../utilities /flutter_toast.dart';
import '../utilities /reusable_textfield.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isSigningUp = false;

  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _connectivityService.startMonitoring(context);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _connectivityService.stopMonitoring();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
                width: 120,
                height: 120,
                notesIconImage,
            ),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child:  FormContainerWidget(
                controller: _emailController,
                labelText: email,
                hintText: enterEmail,
              )
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FormContainerWidget(
                controller: _passwordController,
                labelText: password,
                hintText: enterPassword,
                isPasswordField: true,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 40),
            CustomElevatedButton(
                color: const Color.fromRGBO(10,150,248,1),
                text: login,
                textColor: Colors.white,
                onPressed: (){
                  _connectivityService.startMonitoring(context);
                   FocusScope.of(context).unfocus();
                  _signIn();
                }
            ),
            const SizedBox(height: 40),
            Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(donTHaveAccount),
                const SizedBox(width: 2,),
                GestureDetector(
                  onTap: (){
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    signUp,
                    style: TextStyle(
                    decoration: TextDecoration.underline,
                     ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    User? user = await _auth.signInWithEmailAndPassword(email, password);
    if (user != null) {
      showToast(message: userAddedSuccessFul);
      Navigator.pushNamed(context, "/home");
    } else {
      showToast(message: someErrorHappened);
    }
  }
}
