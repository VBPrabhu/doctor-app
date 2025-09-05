import 'package:doctorapp/AppCommon/CommonWidget/common_large_button.dart';
import 'package:doctorapp/AppCommon/CommonWidget/quentity_selector_view.dart';
import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:flutter/material.dart';

class AddToBasketScreen extends StatelessWidget {
  const AddToBasketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: context.screenWidth,
              height: context.screenHeight * .30,
              clipBehavior: Clip.none,
              decoration: BoxDecoration(
                  image: DecorationImage(image:AssetImage(AppImages.sunscreen),
                      fit: BoxFit.fill
                  )
              ),
            ),

            16.toHeight(),

            Text("Naturel Red Apple",
              style: AppTextStyle.s18.copyWith(
                  fontWeight: FontWeight.w500
            ),).toHorizontalPadding(horizontalPadding: 16),

            25.toHeight(),

            Text("Natural Flavoured Sunscreen",
              style: AppTextStyle.s14.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkGrey
            ),).toHorizontalPadding(horizontalPadding: 16),


            16.toHeight(),
            QuantitySelector(),
            16.toHeight(),

            Divider().toHorizontalPadding(
              horizontalPadding: 16
            ),

            4.toHeight(),

            Text("Product Detail",
            style: AppTextStyle.s14.copyWith(
              fontWeight: FontWeight.w600
            )
            ).toHorizontalPadding(horizontalPadding: 16),

            10.toHeight(),

            Text("Apples are nutritious. Apples may be good for weight loss. apples may be good for your heart. As part of a healtful and varied diet.",style: AppTextStyle.s14.copyWith(fontSize: 12,
             color: AppColors.darkGrey
            ),).toHorizontalPadding(horizontalPadding: 16),


            20.toHeight(),

            Row(
              children: [

                Text("Review",
                    style: AppTextStyle.s14.copyWith(
                        fontWeight: FontWeight.w600
                    )
                ),

                Spacer(),
                ...List.generate(5,(index)=>Icon(Icons.star,
                  size: 15,
                  color: AppColors.primaryColor,
                ))
              ],
            ).toHorizontalPadding(horizontalPadding: 16),


            Spacer(),

            CommonLargeButton(
              title: "Add To Basket",
            ).toHorizontalPadding(horizontalPadding: 16),


            20.toHeight(),

          ],
        ),
      ),
    );
  }
}
