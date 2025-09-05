import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonButton extends StatelessWidget {

    CommonButton({super.key,this.label,this.onTap,this.color,this.labelColor,this.width});

    String ? label;
    Function () ? onTap;
    Color ? color;
    Color ? labelColor;
    double ? width;

  @override
  Widget build(BuildContext context) {
    return  MaterialButton(
      color: color??AppColors.primaryColor,
         elevation: 0,
      minWidth: width ?? context.screenWidth * .40,
      highlightColor: Colors.transparent,
      // focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30)
      ),
      onPressed: onTap,
      child: Text(
        label ?? "",
        style: AppTextStyle.s14.copyWith(color : labelColor ?? Colors.white),
      ),
    );
  }
}
