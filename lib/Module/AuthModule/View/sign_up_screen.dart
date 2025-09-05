import 'package:doctorapp/AppCommon/CommonWidget/commo_text_field.dart';
import 'package:doctorapp/AppCommon/CommonWidget/common_button.dart';
import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:doctorapp/Module/AuthModule/AuthViewModel/auth_view_model.dart';
import 'package:doctorapp/Module/AuthModule/View/registration_sucessfully_screen.dart';
import 'package:doctorapp/Utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class SignUpScreen extends StatelessWidget {
   SignUpScreen({super.key});


  final formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();

  final authController = Get.put(AuthController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Transform.translate(
          offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          
              20.toHeight(),
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    SvgPicture.asset(AppImages.appLogo,
                      height: context.screenWidth * .40,
                      width: context.screenWidth * .40,
                    ),
                    Text("Dr. Hanan",style: AppTextStyle.s18.copyWith(fontWeight: FontWeight.bold,
                        fontSize: 22.5
                    ),),
          
                    Text("Speciality Clinic",style: AppTextStyle.s14.copyWith(fontWeight: FontWeight.w200,
                    ),),
          
                  ],
                ),
              ),
          
              50.toHeight(),
          
          
              Expanded(
                child: Container(
                   width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius : BorderRadius.only(topRight : Radius.circular(140)),
                        color: AppColors.grey
                              ),
                              child: Form(
                 key: formKey,
                 child: SingleChildScrollView(
                   child: Column(
          
                     mainAxisAlignment: MainAxisAlignment.center,
          
          
                     children: [
          
                       20.toHeight(),
                       
                       Text("Sign up",style:AppTextStyle.s22,),
          
                       30.toHeight(),
                       SizedBox(
                           width: context.screenWidth/1.4,
                           child: CommonTextField(
                             hintText: "USER NAME",
                             controller: nameController,
                             validator: (value)=>Validation.emptyNullValidator(value,errorMessage: "Name is required"),
                             prefix: Padding(
                               padding: const EdgeInsets.all(12),
                               child: SvgPicture.asset(AppImages.userIcon),
                             ),
          
                           )),
          
                       17.toHeight(),
          
                       SizedBox(
                           width: context.screenWidth/1.4,
                           child: CommonTextField(hintText: "EMAIL",
                             validator: (value)=>Validation.validEmail(value),
                            controller: emailController,
                           )),
          
                       17.toHeight(),
          
                       SizedBox(
                           width: context.screenWidth/1.4,
                           child: CommonTextField(
                             hintText: "PASSWORD",
                             controller: passwordController,
                             validator: (value)=>Validation.validPassword(value),
                           )),
          
                       17.toHeight(),
          
                       SizedBox(
                           width: context.screenWidth/1.4,
                           child: CommonTextField(
                             hintText: "MOBILE NO",
                             validator: (value)=>Validation.emptyNullValidator(value,errorMessage: "Enter your mobile number"),
                             controller: mobileNumberController,
                           )),
          
                       17.toHeight(),
          
                       Obx(()=> authController.isLoading.value == true?
                           CircularProgressIndicator(
                             strokeWidth: 1,
                             color:Colors.black,
                           ):
                       CommonButton(
                           label: "Sign up",
                           onTap: (){
                               //Navigator.push(context!,MaterialPageRoute(builder:(context)=>RegistrationSuccessfullyScreen()));

                             if(formKey.currentState!.validate()){
                               authController.signUpApi(
                                 name: nameController.text.trimLeft().trimRight(),
                                 context: context,
                                 mobileNumber: mobileNumberController.text.trimLeft().trimRight(),
                                 email: emailController.text.trimLeft().trimRight(),
                                 password: passwordController.text.trim()
                               );
                             }

          
                           },
                         ),
                       ),
                       17.toHeight(),
          
          
                     ],
                   ),
                 ),
                              ),
          
                            ),
              )
          
          
          
          
          
          
          
            ],
          ),
        ),
      ),
    );
  }


  Widget loginButton(BuildContext context)=>SizedBox(
    width: context.screenWidth/2.5,
    child: ElevatedButton(
      onPressed: () {
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Rounded edges
        ),
        backgroundColor: Colors.white, // Button background
        foregroundColor: Colors.black, // Text color
        elevation: 4, // No default elevation since we use custom shadow
      ),
      child: Text("Login", style: TextStyle(fontSize: 18)),
    ),
  );
}


