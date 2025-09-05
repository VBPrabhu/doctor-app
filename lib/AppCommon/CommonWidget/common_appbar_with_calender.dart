



import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomAppBarWithCalender extends StatelessWidget implements PreferredSizeWidget {
   CustomAppBarWithCalender({super.key,this.title});

  String ? title;


  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: Icon(Icons.arrow_back_ios),
      title: Text(title??"",
      style: AppTextStyle.s14.copyWith(
        fontSize: 18,
        color: Colors.black
      ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: SvgPicture.asset(AppImages.calender,
            width: 20,
            height: 20,
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}