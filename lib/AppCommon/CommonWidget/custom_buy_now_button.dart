





import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBuyNowButton extends StatelessWidget {
  const CustomBuyNowButton({super.key,this.label,this.onTap,this.height,this.color,this.labelColor,this.width});

 final  String ? label;
 final  Function () ? onTap;
 final  Color ? color;
 final Color ? labelColor;
  final double ? width;
  final double ? height;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: AppColors.primaryColor,
      elevation: 0,
      minWidth: width ?? context.screenWidth * .40,
      height: height,
      highlightColor: Colors.transparent,
      // focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30)
      ),
      onPressed: (){},
      child: Text( label??"",style: AppTextStyle.s14.copyWith(
          color : labelColor ?? Colors.white,
          fontSize: 12
      ),),
    );
  }
}
