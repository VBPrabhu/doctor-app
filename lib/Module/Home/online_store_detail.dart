import 'package:doctorapp/AppCommon/CommonWidget/commo_text_field.dart';
import 'package:doctorapp/AppCommon/CommonWidget/common_best_seller_gridview_componant.dart';
import 'package:doctorapp/AppCommon/CommonWidget/common_shadow_textfield.dart';
import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:flutter/material.dart';


class OnlineStoreDetail extends StatelessWidget {
  const OnlineStoreDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBgColor,

        body: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: context.screenWidth,
                  height: context.screenHeight * .30,
                  decoration: BoxDecoration(
                    image: DecorationImage(image:AssetImage(AppImages.banner),
                     fit: BoxFit.fill
                    )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextFormField(
                    cursorColor: AppColors.primaryColor,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Search any thing to Rent...",
                      hintStyle: const TextStyle(color: Color(0xffB5B3B3),fontSize: 14
                      ),

                      suffixIcon: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color:  AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(3)
                          ), // Background color of the icon circle
                          child: Icon(Icons.search, color: Colors.white,
                              size: 22
                          ),
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10,horizontal: 16),
                    ),
                  ),
                )
              ],
            ),

            50.toHeight(),

            TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              tabAlignment: TabAlignment.fill,
              labelPadding: EdgeInsets.zero,

              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(width: 2.0, color: AppColors.primaryColor),
                // insets: EdgeInsets.symmetric(horizontal: 30.0),
              ),
              tabs: const [
                Tab(text: 'Best Seller'),
                Tab(text: 'Skin Products'),
              ],
            ),

            Expanded(
              child: GridView.builder(
                  itemCount: 6,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 14,vertical: 14),
                  physics: AlwaysScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 30,
                      childAspectRatio: .65
                  ),

                  itemBuilder: (context,index){
                return CommonBestSellerGridviewComponent();
              }),
            )
          ],
        ),
      ),
    );
  }
}
