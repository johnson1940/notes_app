import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewModel/notes_app_viewModel.dart';


class FormContainerWidget extends StatefulWidget {

  final TextEditingController? controller;
  final Key? fieldKey;
  final bool? isPasswordField;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final int? maxLines;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? inputType;
  final bool? isNoNeedFillColor;
  final TextStyle? style;

  const FormContainerWidget({
    super.key,
    this.controller,
    this.isPasswordField,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.maxLines,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.inputType,
    this.isNoNeedFillColor,
    this.style,
  });


  @override
  _FormContainerWidgetState createState() =>  _FormContainerWidgetState();
}

class _FormContainerWidgetState extends State<FormContainerWidget> {

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, obscureTextProvider, child) {
        return  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.labelText ?? ''),
            const SizedBox(
              height: 5,
            ),
            Container(
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                maxLines: widget.maxLines,
                style: widget.style ?? const TextStyle(color: Colors.black),
                controller: widget.controller,
                keyboardType: widget.inputType,
                key: widget.fieldKey,
                obscureText:  widget.isPasswordField == true
                    ? obscureTextProvider.obscureText
                    : false,
                onSaved: widget.onSaved,
                validator: widget.validator,
                onFieldSubmitted: widget.onFieldSubmitted,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: (widget.isNoNeedFillColor ??  false) ? false : true,
                  fillColor: const Color.fromRGBO(246, 245, 245, 1),
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(color: Colors.black45),
                  suffixIcon: widget.isPasswordField == true
                      ? GestureDetector(
                    onTap: () {
                      obscureTextProvider.toggleObscureText();
                    },
                      child: Icon(
                        obscureTextProvider.obscureText
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: obscureTextProvider.obscureText == false
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  )
                      : const Text(""),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}