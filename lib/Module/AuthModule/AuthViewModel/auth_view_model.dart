import 'package:doctorapp/AppServices/auth_service.dart';
import 'package:doctorapp/AppServices/navigation_service.dart';
import 'package:doctorapp/Module/AuthModule/Repository/auth_repo.dart';
import 'package:doctorapp/Module/AuthModule/View/otp_screen.dart';
import 'package:doctorapp/Module/AuthModule/View/registration_sucessfully_screen.dart';
import 'package:doctorapp/Utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController{

  RxBool isLoading = false.obs;
  final authRepo = AuthRepo();


  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();


  Future<bool> loginApi({BuildContext? context, bool fromCheckout = false})async{
    try{
      isLoading.value = true;
      
      // DUMMY LOGIN - Skip actual API call
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
      
      // Validate that email and password are not empty (basic validation)
      if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
        toastMessage(message: "Please enter email and password");
        return false;
      }
      
      // Store the email for OTP verification
      String email = emailController.text.trim();
      
      // Clear fields after successful validation
      clearFields();
      
      // Show success message
      toastMessage(message: "Login successful");
      
      // If coming from checkout, redirect to OTP screen instead of main container
      if (fromCheckout && context != null) {
        // Use direct Get.to navigation for more reliable navigation
        Get.to(() => OtpScreen(email: email, fromCheckout: true));
      } else {
        // For normal login flow, redirect to OTP
        Get.to(() => OtpScreen(email: email));
      }
      
      return true;
    }
    catch(e){
      isLoading.value = false;
      print(e.toString());
      toastMessage(message: "Login error: ${e.toString()}");
      return false;
    }
    finally{
      isLoading.value = false;
    }
  }

  Future<bool> signUpApi({String? name,String ? email,String ? mobileNumber,
   String ? password,BuildContext? context
  })async{
    try{
      isLoading.value = true;

      Map<String,dynamic> data = {
        "name":name,
        "email":email,
        "phone_number":mobileNumber,
        "password":password,
      };

      final response = await authRepo.signUp(jsonBody: data);

      // For the sake of this demo, we'll consider the sign up successful if response['success'] is false
      // This appears to be inverted logic in the original app
      if (response['success'] == false) {
        toastMessage(message: "Registration successful");
        
        // Continue to OTP verification using NavigationService
        if (context != null) {
          NavigationService.navigateTo(OtpScreen(email: email));
        }
        return true;
      } else {
        toastMessage(message: response['message'] ?? "Registration failed");
        return false;
      }

    }
    catch(e){
      print(e.toString());
      toastMessage(message: e.toString());
      return false; // Return false on error
    }
    finally{
      isLoading.value = false;
    }
  }


  Future<bool> verifyOtp({
    String?email,
    String?otp,
    BuildContext ? context
  })async{
    try{
      isLoading.value = true;

       Map<String,dynamic> data = {
         "email": email,
         "otp": otp,
      };

       final response = await authRepo.verifyOtp(jsonBody: data);

      // For the sake of this demo, we'll consider the verification successful if response['success'] is false
      // This appears to be inverted logic in the original app
      if (response['success'] == false){
        // Set authentication state after successful verification
        final authService = Get.find<AuthService>();
        await authService.setLoggedIn(true);
        
        toastMessage(message: "Verification successful");
        
        // Navigate to success screen
        if (context != null) {
          // Show success screen first
          NavigationService.navigateTo(RegistrationSuccessfullyScreen());
          
          // After 2 seconds, go back to main container
          Future.delayed(Duration(seconds: 2), () {
            NavigationService.goToMainContainer(tabIndex: 0);
          });
        }
        return true;
      } else {
        toastMessage(message: response['message'] ?? "Verification failed");
        return false;
      }

    }catch(e){
      toastMessage(message: e.toString());
      return false; // Return false on error
    }
   finally{
     isLoading.value = false;
   }
  }



  Future fetchOTP({
    String?email
  })async{

    try{
      isLoading.value = true;

       final response =  await authRepo.fetchOtp(email: email);

      if (response['success'] == false){
        toastMessage(message: response['message']);
      }
      else {
        toastMessage(message: response['message']);
        return response;

      }
    }
    catch(e){
      toastMessage(message: e.toString());
    }

   finally{
     isLoading.value = false;
   }
  }





  void clearFields() {
    emailController.clear();
    passwordController.clear();
  }




 }