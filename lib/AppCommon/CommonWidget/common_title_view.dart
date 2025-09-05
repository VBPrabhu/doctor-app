

import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:flutter/material.dart';

class CommonTitleView extends StatelessWidget {
  const CommonTitleView({super.key,this.title,this.trailing});

  final String  ? title;
  final String  ? trailing;


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Text(title ?? "",style: AppTextStyle.s18.copyWith(
         fontWeight: FontWeight.w600,
        ),),

        Text(trailing ?? "",style: AppTextStyle.s14.copyWith(
         fontWeight: FontWeight.w600,
          color: AppColors.blueColor,
        ),),


      ],
    );
  }
}
