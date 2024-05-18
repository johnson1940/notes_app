import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final double? width;
  final double? height;
  final Color color;
  final Color? textColor;
  final String text;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    super.key,
    this.width,
    this.height,
    this.textColor,
    required this.color,
    required this.text,
    required this.onPressed,
  });


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: SizedBox(
        width: width ?? size.width * 1,
        height: height ?? 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(color),
          ),
          child: Text(text,
          style: TextStyle(
            color: textColor,
          ),),
        ),
      ),
    );
  }
}
