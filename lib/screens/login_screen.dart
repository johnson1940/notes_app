import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notes_app/utilities%20/reusable_elevated_button.dart';

import '../common/conts_text.dart';
import '../user_auth/fire_base_auth_service.dart';
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

  @override
  void dispose() {
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
                text: "Login",
                textColor: Colors.white,
                onPressed: (){
                  _signIn();
                }
            ),
            SizedBox(height: 40),
            Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(donTHaveAccount),
                SizedBox(width: 2,),
                GestureDetector(
                  onTap: (){
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text(
                    'Signup',
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
      print('Successfully Signed In');
      // showToast(message: "User is successfully created");
      Navigator.pushNamed(context, "/home");
    } else {
      print('Error');
      // showToast(message: "Some error happend");
    }
  }
}
