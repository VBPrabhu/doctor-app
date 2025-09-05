import 'package:doctorapp/AppCommon/CommonWidget/common_appbar_with_calender.dart';
import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:flutter/material.dart';

class MoreServiceScreen extends StatelessWidget {
  const MoreServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      appBar: CustomAppBarWithCalender(),
      body: Column(
        children: [
          Container(
            height: context.screenHeight * .30,
            decoration: BoxDecoration(
              image: DecorationImage(image:AssetImage(AppImages.demoHairImage),
               fit: BoxFit.fill
              )
            ),
          ),
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primaryColor
            ),
          ),

          Expanded(

            child: ListView.separated(
                itemCount: 5,
                padding: EdgeInsets.symmetric( horizontal: 16,vertical: 16),
                shrinkWrap: true,
                itemBuilder:(context,index){
                  return contentView(context);

            }, separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 12,
                  );
            },),
          )




        ],
      ),

    );
  }

    Widget contentView(BuildContext context)=>Container(
      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: 12.toBorderRadius(),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.2),
          blurRadius: 39,
          offset: Offset(0,6
          ),
          spreadRadius: 0
        )
      ]
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              height: context.screenHeight * .13,
              width:  context.screenHeight * .13,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(AppImages.demo))
              ),
            ),

            SizedBox(width: context.screenWidth * .05,),

            Expanded(
              child: Column(
                children: [
                  Text("Boost Natural Immunity to Reduce Hair Loss",
                         maxLines: 2,
                    style: AppTextStyle.s18.copyWith( fontWeight:FontWeight.w900,
                       fontSize: 16
                     ),
                  ),

                  Text("Don't let hair loss stop you – consult a dermatologist now to Regrow Your Healthy Hair.",
                    style: AppTextStyle.hedLine.copyWith(
                        fontSize: 12,
                        color: Color(0xff69696A)),
                  )
                ],
              ),
            )

          ],
        ),
        10.toHeight(),
        Row(
          children: [
            Text("⭐️ 4.5 (135 reviews)",
            style: AppTextStyle.hedLine.copyWith(
              color: Color(0xff6B779A)
            ),
            ),

            10.toWidth(),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: 30.toBorderRadius(),
                  color: AppColors.primaryColor
                ),
                child: Text("Book an Appointment",style: AppTextStyle.hedLine.copyWith(
                  color: Colors.white
                ),),
              ),
            )
          ],
        )
      ],
    ),
  );
}
