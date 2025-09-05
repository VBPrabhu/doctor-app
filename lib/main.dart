import 'package:doctorapp/AppCommon/CommonWidget/common_bottom_nav_bar.dart';
import 'package:doctorapp/AppServices/auth_service.dart';
import 'package:doctorapp/AppServices/cart_data_service.dart';
import 'package:doctorapp/Module/AuthModule/View/login.dart';
import 'package:doctorapp/Module/AuthModule/View/otp_screen.dart';
import 'package:doctorapp/Module/Cart/cart_screen.dart';
import 'package:doctorapp/Module/Home/add_to_basket_screen.dart';
import 'package:doctorapp/Module/Home/more_service_screen.dart';
import 'package:doctorapp/Module/Home/online_store_detail.dart';
import 'package:doctorapp/Module/Home/home_screen.dart';
import 'package:doctorapp/Module/Home/speciality_screen.dart';
import 'package:doctorapp/Module/main_container.dart';
import 'package:doctorapp/Module/appointment/appointment.dart';
import 'package:doctorapp/Module/SplashScreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


void main() {
  // Initialize services
  _initServices();
  runApp(const MyApp());
}

// Initialize application services
void _initServices() {
  // Initialize Get services
  Get.put(AuthService(), permanent: true);
  Get.put(CartDataService(), permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Dr. Hanan Clinic',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}


