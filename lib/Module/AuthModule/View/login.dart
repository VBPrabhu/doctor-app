import 'package:doctorapp/AppCommon/CommonWidget/commo_text_field.dart';
import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:doctorapp/AppServices/auth_service.dart';
import 'package:doctorapp/AppServices/navigation_service.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:doctorapp/Module/AuthModule/AuthViewModel/auth_view_model.dart';
import 'package:doctorapp/Module/AuthModule/View/sign_up_screen.dart';
import 'package:doctorapp/Module/main_container.dart';
import 'package:doctorapp/Utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Login extends StatelessWidget {
   final bool fromCheckout;
   
   Login({super.key, this.fromCheckout = false});


  final authController = Get.put(AuthController());

   final formKey = GlobalKey<FormState>();

   TextEditingController nameController = TextEditingController();
   TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFFBD33), // Yellow background from the design
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              // Top section with logo and doctor image - now much larger
              Expanded(
                flex: 6,
                child: Row(
                  children: [
                    // Left side with logo and text
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppImages.appLogo,
                              height: 80,
                              width: 80,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Dr. Hanan", 
                              style: AppTextStyle.s18.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.black
                              ),
                            ),
                            Text(
                              "Speciality Clinic", 
                              style: AppTextStyle.s14.copyWith(
                                fontWeight: FontWeight.w300,
                                color: Colors.black
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Right side with doctor image - exact match approach
                    Expanded(
                      flex: 1,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Doctor image filling the container - larger size
                          Positioned.fill(
                            child: Transform.scale(
                              scale: 1.7, // Further reduced to show more of the doctor's body
                              alignment: Alignment.topCenter,
                              child: Image.asset(
                                'assets/Images/doctor.png',
                                fit: BoxFit.cover,
                                alignment: Alignment.center, // Centering the image to show more body
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading doctor image: $error');
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Demo tag in the top right
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)),
                              ),
                            ),
                          ),
                          // Doctor name and title overlay - more prominent
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.0),
                                    Colors.black.withOpacity(0.8),
                                  ],
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Dr. AMIN HANAN',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white, 
                                      fontSize: 20, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  const Text(
                                    'Chief Dermatologist',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white, 
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Login section with grey curved background
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(60)),
                    color: Color(0xFFEEEEEE), // Light grey background from design
                  ),
                  child: Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Sign in text
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Text(
                              "Sign in",
                              style: AppTextStyle.s22.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          
                          // Username/Email field
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  spreadRadius: 1
                                )
                              ]
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Icon(Icons.person_outline, color: Colors.grey),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: authController.emailController,
                                    validator: (value) => Validation.emptyNullValidator(
                                      value, 
                                      errorMessage: "Email is required!"
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: "USER NAME",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(color: Colors.grey),
                                      contentPadding: EdgeInsets.symmetric(vertical: 15)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Password field
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  spreadRadius: 1
                                )
                              ]
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Icon(Icons.lock_outline, color: Colors.grey),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: authController.passwordController,
                                    obscureText: true,
                                    validator: (value) => Validation.emptyNullValidator(
                                      value, 
                                      errorMessage: "Password is required!"
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: "PASSWORD",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(color: Colors.grey),
                                      contentPadding: EdgeInsets.symmetric(vertical: 15)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 30),
                          
                          // Login button
                          Obx(() => authController.isLoading.value == true ?
                            const CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Color(0xFFFFBD33),
                            ) :
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if(formKey.currentState!.validate()){
                                    // Pass fromCheckout parameter and context to loginApi
                                    bool success = await authController.loginApi(
                                      context: context,
                                      fromCheckout: fromCheckout
                                    );
                                    
                                    // If success and not from checkout, handle normal flow
                                    if (success && !fromCheckout && Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                    // For fromCheckout=true, no need to pop as OTP screen handles navigation
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFBD33),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Sign up and forgot password row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  NavigationService.navigateTo(SignUpScreen());
                                },
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                "Forgot Password",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
