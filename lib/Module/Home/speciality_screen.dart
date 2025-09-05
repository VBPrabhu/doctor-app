


import 'package:doctorapp/AppCommon/CommonWidget/common_appbar_with_calender.dart';
import 'package:doctorapp/AppCommon/CommonWidget/common_grid_componant.dart';
import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:flutter/material.dart';

class SpecialityScreen extends StatelessWidget {
  const SpecialityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      appBar:CustomAppBarWithCalender(
        title: "Our Specialities",
      ),
       body: SingleChildScrollView(
         child: Column(
           children: [
             GridView.builder(
                 itemCount: 8,
                 shrinkWrap: true,
                 physics: NeverScrollableScrollPhysics(),
                 padding: EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 2,
                   crossAxisSpacing: 16.0,
                   mainAxisSpacing: 30,
                   childAspectRatio: .6
                 ),

                 itemBuilder: (context,index){
               return CommonGridComponent();
             })
           ],
         ),
       ),
    );
  }
}
