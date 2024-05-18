import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';


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
    this.inputType
  });


  @override
  _FormContainerWidgetState createState() =>  _FormContainerWidgetState();
}

class _FormContainerWidgetState extends State<FormContainerWidget> {

  bool _obscureText = true;


  @override
  Widget build(BuildContext context) {
    return Column(
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
            style: const TextStyle(color: Colors.black),
            controller: widget.controller,
            keyboardType: widget.inputType,
            key: widget.fieldKey,
            obscureText: widget.isPasswordField == true? _obscureText : false,
            onSaved: widget.onSaved,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted,
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              fillColor: const Color.fromRGBO(246, 245, 245, 1),
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Colors.black45),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child:
                widget.isPasswordField == true?
                Icon(_obscureText ? Icons.visibility_off :
                Icons.visibility, color: _obscureText == false
                    ? Colors.blue : Colors.grey,) : const Text(""),
              ),
            ),
          ),
        ),
      ],
    );
  }
}