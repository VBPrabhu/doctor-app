import 'package:doctorapp/AppServices/auth_service.dart';
import 'package:doctorapp/AppServices/cart_data_service.dart';
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


