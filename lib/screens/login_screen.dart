import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notes_app/utilities%20/reusable_elevated_button.dart';

import '../common/conts_text.dart';
import '../utilities /reusable_textfield.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                'assets/images/Notes Icon.jpeg'
            ),
            SizedBox(height: 80),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child:  FormContainerWidget(
                labelText: 'Email',
                hintText: 'Enter email',
              )
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: FormContainerWidget(
                labelText: 'Password',
                hintText: 'Enter password',
              )
            ),
            SizedBox(height: 40),
            CustomElevatedButton(
                color: Color.fromRGBO(252, 208, 75, 1),
                text: "Login",
                onPressed: (){

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
}
