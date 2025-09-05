import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppServices/auth_service.dart';
import 'package:doctorapp/AppServices/navigation_service.dart';
import 'package:doctorapp/Module/AuthModule/View/login.dart';
import 'package:doctorapp/Module/AuthModule/View/sign_up_screen.dart';
import 'package:doctorapp/Module/main_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutLoginPrompt extends StatelessWidget {
  final Function onProceed;

  const CheckoutLoginPrompt({Key? key, required this.onProceed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 10),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.account_circle_outlined,
            size: 70,
            color: Color(0xFF800020),
          ),
          const SizedBox(height: 15),
          const Text(
            'Please Login to Continue',
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'You need to be logged in to complete your checkout process',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Use NavigationService for proper navigation - pass fromCheckout: true
                  NavigationService.navigateTo(Login(fromCheckout: true));
                  // No need to wait for .then() as the OTP screen will handle redirection
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 15),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Use NavigationService for proper navigation
                  NavigationService.navigateTo(SignUpScreen())?.then((_) {
                    // After registration, check if logged in and proceed
                    _checkLoginAndProceed(context);
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Register', 
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  void _checkLoginAndProceed(BuildContext context) async {
    final _authService = Get.find<AuthService>();
    bool isLoggedIn = await _authService.checkLoginStatus();
    if (isLoggedIn) {
      // Close any open dialogs if necessary
      if (Navigator.canPop(context)) {
        Navigator.pop(context); 
      }
      // Call the onProceed callback to continue with checkout
      onProceed();
    }
    // If not logged in, user stays on the login/registration page
  }
}
