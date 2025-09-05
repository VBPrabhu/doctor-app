



import 'package:flutter/material.dart';

import '../app_colors.dart';


class CommonTextField extends StatelessWidget {

  final String ? hintText;
  final  TextEditingController? controller;
  final  FormFieldValidator<String>? validator;
  final  bool?  obscureText;
  final  Widget ? prefix;
  final  Color ? color;
  final Widget ? suffixIcon;
  const CommonTextField({super.key,this.hintText,this.controller,this.prefix,this.color,this.suffixIcon,
    this.obscureText,
    this.validator
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      controller: controller,
      validator: validator,
      obscureText: obscureText ?? false,
      obscuringCharacter: "*",
      decoration:  InputDecoration(
          prefixIcon: prefix,
          filled: true,
          hintText: hintText,
          suffixIcon: suffixIcon,
          hintStyle: TextStyle(color: AppColors.hintTextGreyColor,
              fontSize: 14
          ),
          contentPadding:  const EdgeInsets.symmetric(vertical: 5,horizontal:20),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.transparent
            ),
            borderRadius: BorderRadius.circular(14),
          ),

          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.transparent
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          focusedErrorBorder:  OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.transparent
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder : OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.transparent
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          fillColor: color ?? Colors.white
      ),
    );
  }
}