import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../common/conts_text.dart';
import '../user_auth/fire_base_auth_service.dart';
import '../utilities /flutter_toast.dart';
import '../utilities /reusable_elevated_button.dart';
import '../utilities /reusable_textfield.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isSigningUp = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
                'assets/images/notes_app1.png'
            ),
            SizedBox(height: 80),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child:  FormContainerWidget(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter email',
                )
            ),
            SizedBox(height: 20),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: FormContainerWidget(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter password',
                )
            ),
            SizedBox(height: 40),
            CustomElevatedButton(
                color: Color.fromRGBO(10,150,248,1),
                text: "Signup",
                textColor: Colors.white,
                onPressed: (){
                   FocusScope.of(context).unfocus();
                  _signUp();
                }
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(alreadyHaveAnAccount),
                SizedBox(width: 2,),
                GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Login',
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

  void _signUp() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    User? user = await _auth.signUpWithEmailAndPassword(email, password);
    if (user != null) {
     showToast(message: "User is successfully created");
      Navigator.pushNamed(context, "/home");
    } else {
      showToast(message: "Some error happend");
    }
  }
}

