import 'package:doctorapp/AppCommon/CommonWidget/custom_buy_now_button.dart';
import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:flutter/material.dart';

class CommonBestSellerGridviewComponent extends StatelessWidget {
  const CommonBestSellerGridviewComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: context.screenWidth /2.8,
      padding: const EdgeInsets.only(top: 12),
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
        children: [
          Image.asset(
            AppImages.onlineStoreImage, // Replace with your image path
            fit: BoxFit.fill,
            width: 110,
            height: 110,
          ),
          const SizedBox(height: 10),
          const Text(
            'Hair Shampoo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$600',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.fontColor,
            ),
          ),
          const SizedBox(height: 4),
          CustomBuyNowButton(
            label: "Buy Now",
            height:30,
            width: context.screenWidth * .25,
          )
        ],
      ),
    );
  }
}
