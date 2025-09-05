import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/Module/Orders/order_success_page.dart';
import 'package:doctorapp/AppServices/razorpay_service.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;

  const CheckoutPage({
    Key? key,
    required this.cartItems,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
  }) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Address details
  String fullName = '';
  String phone = '';
  String addressLine1 = '';
  String addressLine2 = '';
  String city = '';
  String state = '';
  String pincode = '';
  
  // Payment details
  String selectedPaymentMethod = 'razorpay';
  bool isPlacingOrder = false;
  String upiId = '';
  String cardNumber = '';
  String cardHolderName = '';
  String cardExpiry = '';
  String cardCvv = '';
  String bankName = '';
  
  bool saveAddress = false;
  bool showPrimaryAddressFields = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          'Checkout',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSummaryCard(),
                const SizedBox(height: 20),
                _buildDeliveryAddressSection(),
                const SizedBox(height: 20),
                _buildPaymentMethodSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildOrderSummaryCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Edit Cart',
                  style: TextStyle(
                    color: AppColors.fontColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Show mini list of items
          ...widget.cartItems.map((item) {
            final product = item['product'];
            final quantity = item['quantity'];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    '$quantity × ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      product['name'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${(product['price'] * quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          const Divider(height: 24),
          _summaryRow('Subtotal', '₹${widget.subtotal.toStringAsFixed(2)}'),
          _summaryRow('Shipping Fee', widget.shippingFee > 0 ? '₹${widget.shippingFee.toStringAsFixed(2)}' : 'Free'),
          if (widget.discount > 0)
            _summaryRow('Discount', '-₹${widget.discount.toStringAsFixed(2)}', isDiscount: true),
          const Divider(height: 24),
          _summaryRow(
            'Total',
            '₹${widget.total.toStringAsFixed(2)}',
            isBold: true,
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

  Widget _buildDeliveryAddressSection() {
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
            'Delivery Address',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          
          // Use saved address toggle
          Row(
            children: [
              Checkbox(
                activeColor: AppColors.primaryColor,
                value: !showPrimaryAddressFields,
                onChanged: (value) {
                  setState(() {
                    showPrimaryAddressFields = !value!;
                  });
                },
              ),
              const Text('Use saved address'),
            ],
          ),
          
          if (!showPrimaryAddressFields)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Venkat Raman',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('123 Main Street, Apartment 4B'),
                  Text('Mumbai, Maharashtra - 400001'),
                  Text('Phone: +91 98765 43210'),
                ],
              ),
            ),
          
          if (showPrimaryAddressFields) ...[
            const SizedBox(height: 16),
            TextFormField(
              decoration: _inputDecoration('Full Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              onChanged: (value) => fullName = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: _inputDecoration('Phone Number'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
              onChanged: (value) => phone = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: _inputDecoration('Address Line 1'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
              onChanged: (value) => addressLine1 = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: _inputDecoration('Address Line 2 (Optional)'),
              onChanged: (value) => addressLine2 = value,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: _inputDecoration('City'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    onChanged: (value) => city = value,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: _inputDecoration('State'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    onChanged: (value) => state = value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: _inputDecoration('PIN Code'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter PIN code';
                }
                return null;
              },
              onChanged: (value) => pincode = value,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  activeColor: AppColors.primaryColor,
                  value: saveAddress,
                  onChanged: (value) {
                    setState(() {
                      saveAddress = value!;
                    });
                  },
                ),
                const Text('Save this address for future orders'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
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
            'Payment Method',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          
          // Payment method selection
          // Razorpay payment option (highlighted as preferred option)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedPaymentMethod == 'razorpay'
                    ? AppColors.primaryColor
                    : const Color(0xFF528FF0).withOpacity(0.5),
                width: selectedPaymentMethod == 'razorpay' ? 2 : 1.5,
              ),
              color: selectedPaymentMethod == 'razorpay'
                  ? const Color(0xFFEEF4FF)
                  : Colors.white,
            ),
            child: _buildPaymentOption(
              'Razorpay',
              'Pay securely using Razorpay payment gateway (Recommended)',
              'razorpay',
              Icons.payment_rounded,
            ),
          ),
          const SizedBox(height: 8),
          
          _buildPaymentOption(
            'UPI',
            'Pay using UPI apps like Google Pay, PhonePe, Paytm etc.',
            'upi',
            Icons.account_balance_wallet,
          ),
          const SizedBox(height: 8),
          
          if (selectedPaymentMethod == 'upi')
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: _inputDecoration('Enter UPI ID (e.g. name@upi)'),
                    validator: (value) {
                      if (selectedPaymentMethod == 'upi' && (value == null || value.isEmpty)) {
                        return 'Please enter UPI ID';
                      }
                      return null;
                    },
                    onChanged: (value) => upiId = value,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildUpiOption('assets/Images/gpay.png', 'Google Pay'),
                      _buildUpiOption('assets/Images/phonepe.png', 'PhonePe'),
                      _buildUpiOption('assets/Images/paytm.png', 'Paytm'),
                    ],
                  ),
                ],
              ),
            ),
            
          _buildPaymentOption(
            'Credit/Debit Card',
            'Pay using Visa, Mastercard, RuPay etc.',
            'card',
            Icons.credit_card,
          ),
          const SizedBox(height: 8),
          
          if (selectedPaymentMethod == 'card')
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: _inputDecoration('Card Number'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (selectedPaymentMethod == 'card' && (value == null || value.isEmpty)) {
                        return 'Please enter card number';
                      }
                      return null;
                    },
                    onChanged: (value) => cardNumber = value,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: _inputDecoration('Cardholder Name'),
                    validator: (value) {
                      if (selectedPaymentMethod == 'card' && (value == null || value.isEmpty)) {
                        return 'Please enter cardholder name';
                      }
                      return null;
                    },
                    onChanged: (value) => cardHolderName = value,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: _inputDecoration('Expiry (MM/YY)'),
                          validator: (value) {
                            if (selectedPaymentMethod == 'card' && (value == null || value.isEmpty)) {
                              return 'Required';
                            }
                            return null;
                          },
                          onChanged: (value) => cardExpiry = value,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: _inputDecoration('CVV'),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          validator: (value) {
                            if (selectedPaymentMethod == 'card' && (value == null || value.isEmpty)) {
                              return 'Required';
                            }
                            return null;
                          },
                          onChanged: (value) => cardCvv = value,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
          _buildPaymentOption(
            'Net Banking',
            'Pay directly from your bank account',
            'netbanking',
            Icons.account_balance,
          ),
          const SizedBox(height: 8),
          
          if (selectedPaymentMethod == 'netbanking')
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Select Bank'),
                    items: [
                      'State Bank of India',
                      'HDFC Bank',
                      'ICICI Bank',
                      'Axis Bank',
                      'Bank of Baroda',
                      'Punjab National Bank',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    validator: (value) {
                      if (selectedPaymentMethod == 'netbanking' && (value == null || value.isEmpty)) {
                        return 'Please select a bank';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        bankName = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You will be redirected to your bank\'s website to complete the payment.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
          _buildPaymentOption(
            'Cash on Delivery',
            'Pay when you receive your order',
            'cod',
            Icons.local_shipping,
          ),
          
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  color: Colors.grey.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'All payment options are secure and encrypted.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, String value, IconData icon) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedPaymentMethod == value
                ? AppColors.primaryColor
                : Colors.grey.shade300,
            width: selectedPaymentMethod == value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selectedPaymentMethod == value
                  ? AppColors.primaryColor
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selectedPaymentMethod == value
                          ? AppColors.primaryColor
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: selectedPaymentMethod,
              onChanged: (newValue) {
                setState(() {
                  selectedPaymentMethod = newValue!;
                });
              },
              activeColor: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiOption(String imagePath, String name) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            'assets/Images/app_logo.png',  // Placeholder as we don't have exact image assets
            width: 40,
            height: 40,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildBottomBar() {
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
                  '₹${widget.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Place order button
          Expanded(
            child: ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Place Order',
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

  // Show loading dialog with custom message
  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _placeOrder() async {
    developer.log('🛒 CHECKOUT: _placeOrder method called', name: 'CheckoutPage');
    developer.log('🛒 Selected payment method: $selectedPaymentMethod', name: 'CheckoutPage');
    developer.log('🛒 Order total amount: ${widget.total}', name: 'CheckoutPage');
    developer.log('🛒 Stack trace: ${StackTrace.current}', name: 'CheckoutPage');
    
    setState(() {
      isPlacingOrder = true;
    });
    
    print('Placing order with selected payment method: $selectedPaymentMethod');
    
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Process based on payment method
      if (selectedPaymentMethod == 'razorpay') {
        developer.log('🛒 CHECKOUT: Creating Razorpay service instance', name: 'CheckoutPage');
        
        // Create Razorpay service instance
        final razorpayService = RazorpayService(context);
        
        print('Checkout: Creating order and launching Razorpay checkout with amount ${widget.total}');
        developer.log('🛒 About to call razorpayService.processPayment with amount ${widget.total}', name: 'CheckoutPage');
        
        // Show loading indicator
        _showLoadingDialog(context, 'Processing payment...');
        
        // Generate a receipt ID using timestamp
        final receiptId = 'rcpt_${DateTime.now().millisecondsSinceEpoch}';
        
        // Create notes with order details
        final notes = {
          'address': '$addressLine1, $addressLine2, $city, $state, $pincode',
          'phone': phone,
          'name': fullName,
        };
        
        // Process payment using the enhanced flow
        // Make sure we're using named parameters for the callback functions to match expected format
        razorpayService.processPayment(
          amount: widget.total,
          currency: 'INR',
          receiptId: receiptId,
          notes: notes,
          onSuccess: (String? paymentId, String? orderId) {
            developer.log('🛒 CHECKOUT: Payment success callback received', name: 'CheckoutPage');
            developer.log('🛒 Payment ID: $paymentId, Order ID: $orderId', name: 'CheckoutPage');
            print('Checkout: Payment success callback received with payment ID: $paymentId, order ID: $orderId');
            
            // Show a success message with the order and payment IDs
            // Hide loading indicator
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Check if the context is still valid and dialog is showing
              if (context.mounted) {
                // Try to dismiss the dialog if it's showing
                try {
                  Navigator.of(context, rootNavigator: true).pop();
                  print('Successfully dismissed payment loading dialog');
                } catch (e) {
                  print('Error dismissing dialog: $e');
                }
              }
              
              // Clean up Razorpay instance
              razorpayService.dispose();
              
              // Navigate to order success page after a short delay
              // This ensures dialog is fully dismissed before navigation
              Future.delayed(const Duration(milliseconds: 300), () {
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => OrderSuccessPage(
                        orderId: orderId ?? 'TEMP-ORDER',
                        totalAmount: widget.total,
                      ),
                    ),
                  );
                }
              });
            });
          },
          onFailure: () {
            developer.log('🛒 CHECKOUT: Payment failure callback received', name: 'CheckoutPage');
            // Hide loading dialog if showing
            Navigator.of(context, rootNavigator: true).pop();
            
            // Print logs for debugging
            print('Checkout: Payment failure callback received');
            
            // Clean up Razorpay instance
            razorpayService.dispose();
            
            // Show a failure message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment was cancelled or failed. Please try again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          },
        );
      } else {
        // For other payment methods, simulate payment process
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Processing Payment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Please wait while we process your payment...'),
                ],
              ),
            );
          },
        );

        // Simulate payment processing
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop(); // Close the progress dialog
          
          // Navigate to order success page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSuccessPage(
                orderId: 'HCS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                totalAmount: widget.total,
              ),
            ),
          );
        });
      }
    } else {
      // Show error message for form validation failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
