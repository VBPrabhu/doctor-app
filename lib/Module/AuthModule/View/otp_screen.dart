import 'package:doctorapp/AppCommon/CommonWidget/common_button.dart';
import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:doctorapp/AppServices/auth_service.dart';
import 'package:doctorapp/AppServices/cart_data_service.dart';
import 'package:doctorapp/AppServices/navigation_service.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:doctorapp/Module/AuthModule/AuthViewModel/auth_view_model.dart';
import 'package:doctorapp/Module/Checkout/checkout_page.dart';
import 'package:doctorapp/Utils/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {

   String ? email;
   bool fromCheckout;

   OtpScreen({super.key, this.email, this.fromCheckout = false});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  late List<FocusNode> focusNodes;

  late List<TextEditingController> controllers;

  String text = "";


  late final TextEditingController pinController;
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;

  final authController = Get.put(AuthController());
  final CartDataService _cartDataService = Get.find<CartDataService>();
  final AuthService _authService = Get.find<AuthService>();



  @override
  void initState() {
    super.initState();
    
    // Initialize controllers and focus nodes
    focusNodes = List.generate(6, (_) => FocusNode());
    controllers = List.generate(6, (_) => TextEditingController());
    formKey = GlobalKey<FormState>();
    pinController = TextEditingController();
    focusNode = FocusNode();
    
    // Use Future.microtask to fetch OTP after build phase is complete
    Future.microtask(() {
      authController.fetchOTP(email: widget.email);
    });
  }


  @override
  void dispose() {

    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

     Color focusedBorderColor = Color(0xffD1D1D1);
     Color fillColor = Colors.white,
     borderColor = Color(0xffD1D1D1);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),

    );


    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
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
              child: Obx(()=>
                 authController.isLoading.value == true?
                     Center(
                       child:CircularProgressIndicator(
                         color: Colors.black,
                       ),
                     ) :
                    Transform.translate(
                       offset: Offset(0.0, -.4 * MediaQuery.of(context).viewInsets.bottom),
                       child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius : BorderRadius.only(topRight : Radius.circular(140)),
                        color: AppColors.grey
                    ),
                    child:
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         50.toHeight(),
                         Text("Verify OTP",style: AppTextStyle.s18.copyWith(
                             fontWeight: FontWeight.bold,
                             fontSize: 22
                         ),),
                         5.toHeight(),

                         Text("Enter the 6-digit code sent to",style:
                         AppTextStyle.s14.copyWith(
                             color: Colors.black.withOpacity(.5))),

                         Text("+1 123 456 7890",style:

                         AppTextStyle.s14.copyWith(color: Colors.black.withOpacity(.5))),

                         20.toHeight(),


                    Form(
                       key: formKey,
                       child: Pinput(
                        length: 6,
                        controller: pinController,
                        focusNode: focusNode,
                        enabled: true,
                        defaultPinTheme: defaultPinTheme,
                        separatorBuilder: (index) => const SizedBox(width: 8),
                        validator: (value) {
                          if(value!.isEmpty){
                            return "Enter OTP";
                          }
                          return null;

                        },
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        onCompleted: (pin) {
                          debugPrint('onCompleted: $pin');
                        },
                        onChanged: (value) {
                          debugPrint('onChanged: $value');
                        },
                        cursor: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 9),
                              width: 22,
                              height: 1,
                              color: focusedBorderColor,
                            ),
                          ],
                        ),
                        // focusedPinTheme: defaultPinTheme.copyWith(
                        //   decoration: defaultPinTheme.decoration!.copyWith(
                        //     borderRadius: BorderRadius.circular(10),
                        //     border: Border.all(color: focusedBorderColor),
                        //   ),
                        // ),
                        submittedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            color: fillColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: focusedBorderColor),
                          ),
                        ),
                        errorPinTheme: defaultPinTheme.copyBorderWith(
                          border: Border.all(color: Colors.redAccent),
                        ),
                        ),
                    ),
                         // Row(
                         //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         //     children: List.generate(6, (index)=>otpTextField(index: index))).toHorizontalPadding(horizontalPadding: 12),
                         //
                         20.toHeight(),


                         Align(
                           alignment: Alignment.center,
                           child: CommonButton(
                             label: "Submit",
                             color: AppColors.primaryColor,
                             onTap: (){
                               if(formKey.currentState!.validate()){
                                  // Check if we're coming from checkout flow
                                   if (widget.fromCheckout) {
                                     // For dummy verification, simulate success
                                     toastMessage(message: "OTP verified successfully");
                                     
                                     // Set the user as logged in
                                     _authService.setLoggedIn(true);
                                     
                                     // Get cart data from service
                                     List<Map<String, dynamic>> cartItems = _cartDataService.cartItems;
                                     double subtotal = _cartDataService.subtotal;
                                     double shippingFee = _cartDataService.shippingFee;
                                     double discount = _cartDataService.discount;
                                     double total = _cartDataService.total;
                                     
                                     // Print debug info
                                     print('Cart data retrieved: ${cartItems.length} items, total: $total');
                                     
                                     // Add a small delay before navigation to ensure UI is ready
                                     Future.delayed(Duration(milliseconds: 500), () {
                                       // Use NavigationService for more reliable navigation
                                       Get.offAll(() => NavigationService.getCheckoutPage());
                                       print('Navigation completed using NavigationService');
                                     });
                                   } else {
                                     // Normal OTP verification flow
                                     authController.verifyOtp(
                                       context: context,
                                       email: widget.email,
                                       otp: pinController.text
                                     );
                                   }
                                }
                             },
                             labelColor: Colors.white,
                           ),
                         ),


                         10.toHeight(),

                         Align(
                           alignment: Alignment.center,
                           child: Text.rich(
                             TextSpan(
                               text: 'Didn\'t receive the code? ', // Default text
                               style: TextStyle(fontSize: 12, color: AppColors.newGrey),
                               children: [
                                 TextSpan(
                                   text: 'Resend code',
                                   style: TextStyle(
                                     color: Colors.black,
                                   ),
                                 ),

                               ],
                             ),
                           ),
                         ),


                         20.toHeight()
                       ],
                     ).toHorizontalPadding()

                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget otpTextField({required int index,required }){
    return SizedBox(
      width: context.screenWidth * .13,
      height: 50,
      child: TextFormField(
        controller: controllers[index],
        cursorColor: Colors.black,
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
         filled: true,
         fillColor: Colors.white,
          counterText: '', // hides the counter
          enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
         borderSide: BorderSide(
           color: Color(0xffD1D1D1)
           )
   ),
          focusedBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
           color: Color(0xffD1D1D1)
          )
            // borderSide: BorderSide(color: Colors.black, width: 2.0),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          }
        },
      ),
    );
  }
}
