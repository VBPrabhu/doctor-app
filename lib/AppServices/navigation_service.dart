import 'package:doctorapp/AppServices/cart_data_service.dart';
import 'package:doctorapp/Module/main_container.dart';
import 'package:doctorapp/Module/Checkout/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Navigation service to handle proper navigation across the app
/// while preserving bottom tab bar visibility
class NavigationService {
  /// Navigate back to main container with specified tab index
  static void goToMainContainer({int tabIndex = 0}) {
    // Check if we're already at root level
    if (Get.currentRoute == '/') {
      // Update the tab index directly
      MainContainerController.to.changeTabIndex(tabIndex);
    } else {
      // Navigate to root with the MainContainer and specified tab
      Get.offAll(() => MainContainer(initialTabIndex: tabIndex),
          transition: Transition.fadeIn);
    }
  }
  
  /// Navigate to a new screen while preserving the ability to return to MainContainer
  static Future<T?>? navigateTo<T>(Widget page) {
    return Get.to(() => page, transition: Transition.rightToLeft);
  }
  
  /// Get a new instance of the checkout page to navigate to after OTP verification
  /// using the cart data stored in CartDataService
  static Widget getCheckoutPage() {
    // Get the cart data service
    final cartDataService = Get.find<CartDataService>();
    
    // Get the latest cart data
    return CheckoutPage(
      cartItems: cartDataService.cartItems,
      subtotal: cartDataService.subtotal,
      shippingFee: cartDataService.shippingFee,
      discount: cartDataService.discount,
      total: cartDataService.total,
    );
  }
}
