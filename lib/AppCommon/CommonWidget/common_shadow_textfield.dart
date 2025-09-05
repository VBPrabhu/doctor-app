import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../app_colors.dart';

class CommonShadowTextField extends StatelessWidget {
  const CommonShadowTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return    Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white, // Background color for the text field
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [

            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4), // Shadow position
            ),   BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(4, 0), // Shadow position
            ),
          ],
        ),
        child: TextFormField(
          cursorColor: AppColors.primaryColor,
          decoration: InputDecoration(
            isDense: true,
            hintText: "Search any thing to Rent...",
            hintStyle: const TextStyle(color: Color(0xffB5B3B3),fontSize: 14
            ),

            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:  AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(3)
                ), // Background color of the icon circle
                child: Icon(Icons.search, color: Colors.white,
                    size: 22
                ),
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10,horizontal: 16),
          ),
        ));

  }
}
