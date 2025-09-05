

import 'package:doctorapp/AppCommon/CommonWidget/common_bottom_nav_bar.dart';
import 'package:doctorapp/AppCommon/CommonWidget/common_button.dart';
import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:doctorapp/Module/Home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegistrationSuccessfullyScreen extends StatelessWidget {
  const RegistrationSuccessfullyScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Column(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          SvgPicture.asset(AppImages.appLogo,
           height : context.screenWidth * .60,
           width  : context.screenWidth * .60,
          ),
          20.toHeight(),
          Align(
            alignment: Alignment.center,
            child: Text("Successfully\nRegistered",
            style: AppTextStyle.s18.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.5,
              fontSize: 26
            ),
            ),
          ),
          50.toHeight(),
          CommonButton(
            label: "Explore",
            color: Colors.white,
            labelColor: Colors.black,
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder:(context)=>BottomNavBar()));
            },
          )
        ],
      ),
    );
  }
}
