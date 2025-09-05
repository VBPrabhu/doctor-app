import 'package:flutter/material.dart';
import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:doctorapp/AppServices/auth_service.dart';
import 'package:doctorapp/AppServices/cart_data_service.dart';
import 'package:doctorapp/AppServices/navigation_service.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:doctorapp/Module/Checkout/checkout_login_prompt.dart';
import 'package:doctorapp/Module/Checkout/checkout_page.dart';
import 'package:doctorapp/Module/main_container.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Get the auth service
  late final AuthService _authService;
  late final CartDataService _cartDataService;
  
  @override
  void initState() {
    super.initState();
    // Initialize auth service
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService());
    }
    _authService = Get.find<AuthService>();
    _cartDataService = Get.find<CartDataService>();
  }
  List<Map<String, dynamic>> products = [
    {
      'name': 'Red Rose Cream',
      'quantity': 1,
      'price': 249.99,
      'image': AppImages.faceLotion,
    },
    {
      'name': 'Beauty Cream',
      'quantity': 1,
      'price': 399.99,
      'image': AppImages.faceLotion,
    },
    {
      'name': 'Organic Cream',
      'quantity': 1,
      'price': 599.00,
      'image': AppImages.faceLotion,
    },
    {
      'name': 'Sunscreen',
      'quantity': 1,
      'price': 799.99,
      'image': AppImages.faceLotion,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    double subtotal = 0;
    for (var product in products) {
      subtotal += product['price'] * product['quantity'];
    }
    double tax = subtotal * 0.18; // 18% tax
    double netTotal = subtotal + tax;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Row(
          children: [
            // App logo image
            Image.asset(
              AppImages.appLogoPng,
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'My Cart',
                style: TextStyle(
                  color: Color(0xFF800020), // Deep burgundy color
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildCartItem(product, index);
                    },
                  ),
          ),
          if (products.isNotEmpty) _buildTotalSection(subtotal, tax, netTotal),
        ],
      ),
    );
  }
  
  // Handle checkout process with login verification
  void _handleCheckout() async {
    // Save cart data for use throughout the authentication flow
    _saveCartData();
    
    // Check if user is logged in
    bool isLoggedIn = await _authService.checkLoginStatus();
    
    if (isLoggedIn) {
      // User is logged in, proceed to checkout
      _proceedToCheckout();
    } else {
      // User is not logged in, show login prompt
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CheckoutLoginPrompt(
            onProceed: () {
              // This will be called after successful login/registration
              _proceedToCheckout();
            },
          );
        },
      );
    }
  }
  
  // Save cart data to CartDataService
  void _saveCartData() {
    // Calculate totals
    double subtotal = 0;
    for (var product in products) {
      subtotal += product['price'] * product['quantity'];
    }
    double shippingFee = 0.0; // Free shipping in this example
    double discount = 0.0; // No discount in this example
    double tax = subtotal * 0.18; // 18% tax
    double total = subtotal + tax;
    
    // Store cart data in service
    _cartDataService.setCartData(
      cartItems: List.from(products),
      subtotal: subtotal,
      shippingFee: shippingFee,
      discount: discount,
      total: total
    );
    
    print('Cart data saved: ${products.length} items, total: $total');
  }
  
  // Proceed to checkout after successful login
  void _proceedToCheckout() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proceeding to checkout...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
    
    // Get cart data from service
    List<Map<String, dynamic>> cartItems = _cartDataService.cartItems;
    double subtotal = _cartDataService.subtotal;
    double shippingFee = _cartDataService.shippingFee;
    double discount = _cartDataService.discount;
    double total = _cartDataService.total;
    
    // Navigate to checkout page with cart data
    Get.to(() => CheckoutPage(
      cartItems: cartItems,
      subtotal: subtotal,
      shippingFee: shippingFee,
      discount: discount,
      total: total,
    ));
  }

  Widget _buildCartItem(Map<String, dynamic> product, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              product['image'],
              width: context.screenWidth * .20,
              height: context.screenWidth * .20,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name and delete button
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product['name'],
                        style: AppTextStyle.s18.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          products.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.clear,
                          color: Color(0xffB3B3B3),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Product quantity and price info
                Text(
                  '${product['quantity']} pcs, Price',
                  style: AppTextStyle.s14.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 10),
                // Quantity controls and total price
                Row(
                  children: [
                    // Quantity controls
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Minus button
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (product['quantity'] > 1) {
                                  product['quantity']--;
                                }
                              });
                            },
                            child: Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.2),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.black,
                                size: 16,
                              ),
                            ),
                          ),
                          // Quantity display
                          SizedBox(
                            width: 36,
                            child: Center(
                              child: Text(
                                product['quantity'].toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          // Plus button
                          InkWell(
                            onTap: () {
                              setState(() {
                                product['quantity']++;
                              });
                            },
                            child: Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Item total price
                    Text(
                      '₹${(product['price'] * product['quantity']).toStringAsFixed(2)}',
                      style: AppTextStyle.s18.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.fontColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(double subtotal, double tax, double netTotal) {
    return Column(
      children: [
        // Total summary card
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtotal row
              Row(
                children: [
                  Text(
                    'Sub Total',
                    style: AppTextStyle.s14.copyWith(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: Colors.grey.shade200, height: 1),
              ),
              // Tax row
              Row(
                children: [
                  Text(
                    'Tax (18%)',
                    style: AppTextStyle.s14.copyWith(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹${tax.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: Colors.grey.shade200, height: 1),
              ),
              // Net total in highlighted container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'Net Total',
                      style: AppTextStyle.s18.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₹${netTotal.toStringAsFixed(2)}',
                      style: AppTextStyle.s18.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.fontColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Checkout button
        Container(
          width: double.infinity,
          height: 50,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: ElevatedButton(
            onPressed: () => _handleCheckout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'PROCEED TO CHECKOUT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
