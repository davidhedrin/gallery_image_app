import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? typeText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.typeText = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: Dimentions.height25),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: typeText,
        style: TextStyle(fontSize: Dimentions.font20),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: Dimentions.width15, right: Dimentions.width15, top: Dimentions.height15, bottom: Dimentions.height15),
          enabledBorder:  OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: Dimentions.font20)
        ),
      ),
    );
  }
}

class MyTextFieldReg extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? typeInput;
  final int? maxLength;
  final String? hintText;
  final Widget? suffixIcon, prefixIcon;
  final bool? obscureText;

  const MyTextFieldReg({
    Key? key,
    required this.controller,
    this.onChanged,
    this.validator,
    this.typeInput,
    this.maxLength,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.obscureText = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: typeInput,
      maxLength: maxLength,
      obscureText: obscureText!,
      style: TextStyle(
        fontSize: Dimentions.font20,
        fontWeight: FontWeight.bold,
      ),
      validator: validator,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: Dimentions.width15, right: Dimentions.width15, top: Dimentions.height15, bottom: Dimentions.height15),
        enabledBorder:  OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        fillColor: Colors.grey.shade200,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: Dimentions.font20),
        suffix: suffixIcon,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
