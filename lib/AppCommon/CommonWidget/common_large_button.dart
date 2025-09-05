


import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:flutter/material.dart';

class CommonLargeButton extends StatelessWidget {

   CommonLargeButton({super.key,this.title});

  String ? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: context.screenHeight * .018),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.primaryColor
      ),
      child: Text(title ?? "",style: AppTextStyle.s14.copyWith(
        color: Colors.white
      ),),
    );
  }
}
