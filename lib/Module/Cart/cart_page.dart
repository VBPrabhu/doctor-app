import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppServices/auth_service.dart';
import 'package:doctorapp/AppServices/razorpay_service.dart';
import 'package:doctorapp/Module/Checkout/checkout_login_prompt.dart';
import 'package:doctorapp/Module/Checkout/checkout_page.dart';
import 'package:doctorapp/Module/Orders/order_success_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<Map<String, dynamic>> items;
  double subtotal = 0;
  double shippingFee = 0;
  double discount = 0;
  double total = 0;
  String promoCode = '';
  
  @override
  void initState() {
    super.initState();
    // Create a deep copy of the cart items
    items = List.from(widget.cartItems);
    _calculateTotals();
  }

  void _calculateTotals() {
    subtotal = 0;
    
    for (var item in items) {
      final product = item['product'];
      final quantity = item['quantity'];
      subtotal += product['price'] * quantity;
    }
    
    // Set shipping fee based on subtotal
    if (subtotal > 0) {
      shippingFee = subtotal > 100 ? 0 : 30;
    } else {
      shippingFee = 0;
    }
    
    // Calculate total
    total = subtotal + shippingFee - discount;
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(index);
    } else {
      setState(() {
        items[index]['quantity'] = newQuantity;
        _calculateTotals();
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
      _calculateTotals();
      
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart'),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  void _applyPromoCode() {
    // In a real app, this would validate the promo code with a backend service
    if (promoCode.toLowerCase() == 'hanan20') {
      setState(() {
        discount = subtotal * 0.2;  // 20% discount
        _calculateTotals();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promo code applied: 20% discount!'),
            backgroundColor: Colors.green,
          ),
        );
      });
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid promo code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          'Shopping Cart',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: items.isEmpty 
          ? _buildEmptyCart(context) 
          : _buildCartWithItems(context),
      bottomNavigationBar: items.isEmpty
          ? null 
          : _buildBottomBar(context),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          const Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Looks like you haven\'t added anything to your cart yet.',
            style: TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue Shopping',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartWithItems(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cart items list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final product = item['product'];
                final quantity = item['quantity'];
                
                return _buildCartItem(index, product, quantity);
              },
            ),
            
            const SizedBox(height: 20),
            
            // Promo code section
            _buildPromoCodeSection(),
            
            const SizedBox(height: 20),
            
            // Order summary
            _buildOrderSummary(),
            
            // Add some extra space at the bottom
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(int index, Map<String, dynamic> product, int quantity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              product['image'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product name
                    Expanded(
                      child: Text(
                        product['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Remove button
                    InkWell(
                      onTap: () => _removeItem(index),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Product description
                Text(
                  product['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Price and quantity controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Text(
                      '₹${product['price']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    
                    // Quantity control
                    Row(
                      children: [
                        _quantityButton(
                          Icons.remove, 
                          () => _updateQuantity(index, quantity - 1),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _quantityButton(
                          Icons.add, 
                          () => _updateQuantity(index, quantity + 1),
                        ),
                      ],
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

  Widget _quantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Apply Promo Code',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      promoCode = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: promoCode.isEmpty ? null : _applyPromoCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Use code "HANAN20" for 20% off!',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
          _summaryRow('Shipping Fee', shippingFee > 0 ? '₹${shippingFee.toStringAsFixed(2)}' : 'Free'),
          if (discount > 0)
            _summaryRow('Discount', '-₹${discount.toStringAsFixed(2)}', isDiscount: true),
          const Divider(height: 24),
          _summaryRow(
            'Total',
            '₹${total.toStringAsFixed(2)}',
            isBold: true,
          ),
          if (shippingFee == 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Free shipping applied!',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green.shade700 : (isBold ? Colors.black : Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Price
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Checkout button
          Expanded(
            child: ElevatedButton(
              onPressed: items.isEmpty ? null : () => _proceedToCheckout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // New method to handle checkout flow with authentication
  void _proceedToCheckout(BuildContext context) async {
    // Check if user is logged in
    final AuthService _authService = Get.find<AuthService>();
    bool isLoggedIn = await _authService.checkLoginStatus();
    
    if (isLoggedIn) {
      // User is logged in, proceed directly to checkout
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            cartItems: items,
            subtotal: subtotal,
            shippingFee: shippingFee,
            discount: discount,
            total: total,
          ),
        ),
      );
    } else {
      // User is not logged in, show login prompt
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CheckoutLoginPrompt(
            onProceed: () {
              // This will be called after successful login/registration
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutPage(
                    cartItems: items,
                    subtotal: subtotal,
                    shippingFee: shippingFee,
                    discount: discount,
                    total: total,
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }
  
  // Method to handle direct payment with Razorpay
  void _payWithRazorpay(BuildContext context) async {
    // Check if user is logged in first (payment still requires authentication)
    final AuthService _authService = Get.find<AuthService>();
    bool isLoggedIn = await _authService.checkLoginStatus();
    
    if (isLoggedIn) {
      // Launch Razorpay directly
      // The URL provided in your request
      final String razorpayUrl = 'https://pages.razorpay.com/pl_R8qIne2NAIxga0/view';
      
      RazorpayService.launchRazorpayCheckout(
        context: context,
        amount: total,
        razorpayUrl: razorpayUrl,
        onPaymentSuccess: (String? paymentId, String? orderId) {
          // Payment successful, navigate to order success page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSuccessPage(
                orderId: orderId ?? 'HCS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                totalAmount: total,
              ),
            ),
          );
        },
        onPaymentFailure: () {
          // Handle payment failure
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } else {
      // User is not logged in, show login prompt first
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CheckoutLoginPrompt(
            onProceed: () {
              // After login, launch Razorpay
              final String razorpayUrl = 'https://pages.razorpay.com/pl_R8qIne2NAIxga0/view';
              
              RazorpayService.launchRazorpayCheckout(
                context: context,
                amount: total,
                razorpayUrl: razorpayUrl,
                onPaymentSuccess: (String? paymentId, String? orderId) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderSuccessPage(
                        orderId: orderId ?? 'HCS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                        totalAmount: total,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }
  }
}
