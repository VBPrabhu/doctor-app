



 import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:doctorapp/Module/Home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBar extends StatefulWidget {
   const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
    int selectedIndex = 0;

   final List<Widget> _pages = const [
     HomeScreen(),
     Center(child: Text('Appointments Page')),
     Center(child: Text('History Page')),
     Center(child: Text('Articles Page')),
     Center(child: Text('Profile Page')),
   ];

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: AppColors.scaffoldBgColor,
       body: _pages[selectedIndex],

       bottomNavigationBar: Container(

         decoration:  BoxDecoration(
             border: Border(
         top: BorderSide(
         color: Colors.grey, // Border color
         width: 1.0,         // Border width
     ),
         )),
         child: Theme(

           data: Theme.of(context).copyWith(
             splashColor: Colors.transparent,
             highlightColor: Colors.transparent,
             // splashFactory: NoSplash.splashFactory,
           ),
           child: BottomNavigationBar(
            backgroundColor: Colors.white,
             currentIndex: selectedIndex,
             selectedItemColor: Colors.black,

             selectedLabelStyle: AppTextStyle.s14.copyWith(
               fontSize: 12),
             unselectedItemColor: Colors.grey,

             onTap: (index) {
               setState(() {
                 selectedIndex = index;
               });
             },
             type: BottomNavigationBarType.fixed,
             items:  [
               BottomNavigationBarItem(
                 icon: SvgPicture.asset(AppImages.home,
                 height: 25, width: 25,
                 ),
                 label: 'Home',
               ),
               BottomNavigationBarItem(
                 icon: SvgPicture.asset(AppImages.appointment,
                   height: 25, width: 25,
                 ),
                 label: 'Appointment',
               ),
               BottomNavigationBarItem(
                 icon: SvgPicture.asset(AppImages.history,
                   height: 25, width: 25,
                 ),
                 label: 'History',
               ),
               BottomNavigationBarItem(
                 icon: SvgPicture.asset(AppImages.articles,
                   height: 25, width: 25,),
                 label: 'Articles',
               ),
               BottomNavigationBarItem(
                 icon: SvgPicture.asset(
                   AppImages.profile,
                   height: 25, width: 25,
                 ),
                 label: 'Profile',
               ),
             ],
           ),
         ),
       ),
     );
   }
}
