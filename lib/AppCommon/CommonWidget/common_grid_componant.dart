


 import 'package:doctorapp/AppCommon/CommonWidget/custom_buy_now_button.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:flutter/material.dart';

class CommonGridComponent extends StatelessWidget {
   const CommonGridComponent({super.key});

   @override
   Widget build(BuildContext context) {
     return Container(
       width: context.screenWidth/2.2,
       // padding: const EdgeInsets.symmetric(vertical: 12),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(22),
         boxShadow: [
           BoxShadow(
             color: Colors.black12,
             blurRadius: 10,
             spreadRadius: 2,
             offset: Offset(0, 5),
           ),
         ],
       ),
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           Image.asset(
             AppImages.demoHairImage, // Replace with your image path
             fit: BoxFit.fill,
           ),
           const SizedBox(height: 10),
           const Text(
             'Hair Treatment',
             style: TextStyle(
               fontSize: 15,
               fontWeight: FontWeight.bold,
               color: Colors.black,
             ),
           ),
           const SizedBox(height: 4),
           Text(
             '6 Session',
             style: TextStyle(
               fontSize: 14,
               fontWeight: FontWeight.bold,
               color: Color(0xff6B779A),
             ),
           ),
           const SizedBox(height: 6),

           Align(
             alignment: Alignment.center,
             child: Text("⭐️ 4.5 (135 reviews)",
               style: AppTextStyle.s14.copyWith(
                   color: Color(0xff6B779A),
                   fontSize: 10
               ),
             ),
           ),
           const SizedBox(height: 4),

           CustomBuyNowButton(
             label: "Read More",
             height:30,
             width: context.screenWidth * .25,
           )
         ],
       ),
     );
   }
 }
