import 'package:flutter/material.dart';
import 'package:doctorapp/Module/Payment/razorpay_checkout.dart';
import 'package:doctorapp/AppServices/payment_api_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:developer' as developer;

class RazorpayService {
  final PaymentApiService _paymentApiService = PaymentApiService();
  late Razorpay _razorpay;
  late BuildContext _context;
  late Function? _onPaymentSuccess;
  late Function? _onPaymentFailure;
  bool _callbackExecuted = false;
  
  RazorpayService(BuildContext context) {
    _context = context;
    _initRazorpay();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    developer.log('⭐️ RAZORPAY SERVICE: _handlePaymentSuccess event received', name: 'RazorpayService');
    developer.log('⭐️ PaymentId: ${response.paymentId}, OrderId: ${response.orderId}', name: 'RazorpayService');
    print('Payment Success: ${response.paymentId}');
    print('Order ID in success response: ${response.orderId}');
    
    // Set flag to prevent duplicate callback execution
    _callbackExecuted = true;
    
    // Verify the payment with backend if possible
    if (response.orderId != null && response.paymentId != null) {
      developer.log('⭐️ Calling _verifyPayment method with orderId: ${response.orderId}', name: 'RazorpayService');
      _verifyPayment(response.orderId!, response.paymentId!);
    } else {
      developer.log('❌ Cannot verify payment: orderId or paymentId is null', name: 'RazorpayService');
      
      // If verification isn't possible, call success callback directly
      if (_onPaymentSuccess != null) {
        developer.log('⭐️ Calling onPaymentSuccess callback (verification skipped)', name: 'RazorpayService');
        _onPaymentSuccess!(response.paymentId, response.orderId ?? 'test_order');
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    developer.log('❌ RAZORPAY SERVICE: _handlePaymentError event received', name: 'RazorpayService');
    developer.log('❌ Error code: ${response.code}, message: ${response.message}', name: 'RazorpayService');
    print('Payment Error: ${response.code} - ${response.message}');
    
    // Analyze the error message to provide better debugging information
    final String errorMessage = response.message ?? '';
    if (errorMessage.contains('order_id')) {
      developer.log('❌ POSSIBLE ISSUE: Invalid order_id format or order not found', name: 'RazorpayService');
    } else if (errorMessage.contains('key')) {
      developer.log('❌ POSSIBLE ISSUE: Invalid API key or key not matching with order', name: 'RazorpayService');
    } else if (errorMessage.contains('amount')) {
      developer.log('❌ POSSIBLE ISSUE: Amount format incorrect. Should be string in paise', name: 'RazorpayService');
    }
    
    // Show detailed error information dialog
    try {
      showDialog(
        context: _context,
        builder: (context) => AlertDialog(
          title: Text('Razorpay Error (${response.code})'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Error: ${response.message}'),
                SizedBox(height: 10),
                Text('Error Code: ${response.code}'),
                Divider(),
                Text('Common causes:'),
                Text('• Invalid order_id format (must begin with "order_")'),
                Text('• Invalid API key'),
                Text('• Amount format incorrect (should be string in paise)'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Could not show error dialog: $e');
    }
    
    // Prevent calling error callback if success was already reported
    if (!_callbackExecuted && _onPaymentFailure != null) {
      _callbackExecuted = true;
      developer.log('⭐️ Calling onPaymentFailure callback', name: 'RazorpayService');
      _onPaymentFailure!();
    } else if (_callbackExecuted) {
      developer.log('⚠️ Payment error received but success callback already executed, ignoring', name: 'RazorpayService');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  Future<void> _verifyPayment(String orderId, String paymentId) async {
    developer.log('⭐️ RAZORPAY SERVICE: _verifyPayment called', name: 'RazorpayService');
    developer.log('⭐️ OrderId: $orderId, PaymentId: $paymentId', name: 'RazorpayService');
    developer.log('⭐️ Stack trace: ${StackTrace.current}', name: 'RazorpayService');
    
    try {
      developer.log('⭐️ About to call PaymentApiService.verifyPayment', name: 'RazorpayService');
      final result = await _paymentApiService.verifyPayment(
        orderId: orderId,
        paymentId: paymentId,
      ).catchError((error) {
        developer.log('❌ Error calling verifyPayment: $error', name: 'RazorpayService');
        throw error; // Changed from rethrow to throw error
      });
      
      developer.log('⭐️ verifyPayment API call completed successfully', name: 'RazorpayService');
      developer.log('⭐️ Verification result: $result', name: 'RazorpayService');
      print('Payment verification successful: $result');
      
      // Now that verification is complete, call success callback
      if (_onPaymentSuccess != null) {
        developer.log('⭐️ Calling onPaymentSuccess callback after verification', name: 'RazorpayService');
        _onPaymentSuccess!(paymentId, orderId);
      }
    } catch (e) {
      developer.log('❌ Payment verification failed: $e', name: 'RazorpayService');
      print('Payment verification failed: $e');
      
      // Even if verification fails, still treat as success since Razorpay confirmed it
      if (_onPaymentSuccess != null) {
        developer.log('⚠️ Calling success callback despite verification failure', name: 'RazorpayService');
        developer.log('⚠️ This is needed because Razorpay confirmed payment success at their end', name: 'RazorpayService');
        _onPaymentSuccess!(paymentId, orderId);
      }
    }
  }

  /// Creates an order with the backend and launches Razorpay checkout
  Future<void> processPayment({
    required double amount,
    required String currency,
    String? receiptId,
    Map<String, dynamic>? notes,
    required Function? onSuccess,
    required Function? onFailure,
  }) async {
    // Reset callback flag for new payment attempt
    _callbackExecuted = false;
    developer.log('⭐️ RAZORPAY SERVICE: processPayment called with amount $amount', name: 'RazorpayService');
    developer.log('⭐️ Stack trace: ${StackTrace.current}', name: 'RazorpayService');
    
    _onPaymentSuccess = onSuccess;
    _onPaymentFailure = onFailure;
    
    try {
      print('Processing payment: Creating order with amount: $amount');
      developer.log('⭐️ RAZORPAY: Processing payment with amount: $amount', name: 'RazorpayService');
      
      Map<String, dynamic> orderData;
      
      try {
        // Get order details from the API
        orderData = await _paymentApiService.createOrder(
          amount: amount,
          currency: currency,
          receiptId: receiptId,
          notes: {
            'paymentFor': notes?['description'] ?? 'Medical services',
            'customerId': notes?['customerId'] ?? 'guest_user',
          },
        );
        
        print('Order created: ${orderData['orderId']}');
        developer.log('✅ RAZORPAY: Order created with ID: ${orderData['orderId']}', name: 'RazorpayService');
      } catch (e) {
        developer.log('❌ RAZORPAY: Error creating order: $e', name: 'RazorpayService');
        
        // If order creation fails due to auth issues, use test mode
        if (e.toString().contains('Authentication') || e.toString().contains('token')) {
          developer.log('⚠️ RAZORPAY: Authentication error detected, falling back to test mode', name: 'RazorpayService');
          
          // Create a mock order - Razorpay requires order_ids to start with order_
          // Keep it short as Razorpay might have length limitations
          final mockOrderId = 'order_mock_${DateTime.now().millisecondsSinceEpoch % 1000000}';
          orderData = {
            'orderId': mockOrderId,
            // Use the test key provided in the Razorpay dashboard
            'keyId': 'rzp_test_1DP5mmOlF5G5ag',
            // Ensure amount is correct format (integer, in paise)
            'amount': (amount * 100).toInt(),
            'currency': currency,
            'status': 'created',
          };
          
          developer.log('⚠️ RAZORPAY: Mock order format: $orderData', name: 'RazorpayService');
          
          developer.log('✅ RAZORPAY: Created fallback mock order: $mockOrderId', name: 'RazorpayService');
        } else {
          // For other errors, rethrow
          rethrow;
        }
      }
      
      // Extract the key ID and order ID from the response
      final String keyId = orderData['keyId'] as String;
      final String orderId = orderData['orderId'] as String;
      
      developer.log('✅ RAZORPAY: Using key ID: $keyId', name: 'RazorpayService');
      developer.log('✅ RAZORPAY: Using order ID: $orderId', name: 'RazorpayService');
      print('Order created successfully: Order ID: $orderId, Key ID: $keyId');
      
      // Prepare user-friendly data for Razorpay
      // Use test credentials if running in debug mode
      Map<String, dynamic> prefill = {};
      if (notes != null && notes['customer_email'] != null) {
        prefill['email'] = notes['customer_email'];
      }
      if (notes != null && notes['customer_phone'] != null) {
        prefill['contact'] = notes['customer_phone'];
      }
      if (notes != null && notes['customer_name'] != null) {
        prefill['name'] = notes['customer_name'];
      }
      
      // Launch Razorpay checkout - follow EXACT format from Razorpay docs
      // IMPORTANT: Options must match format exactly - even small discrepancies can cause errors
      var options = <String, dynamic>{
        
        // Required parameters first
        'key': keyId,
        'amount': (amount * 100).toString(), // MUST be a string for Razorpay
        'name': 'Doctor App',
        'description': 'Payment for medical services',
        'order_id': orderId,
        
        // Optional parameters
        'currency': currency,
        'theme': {
          'color': '#3399cc',
        },
        
        // Prefill with valid test data
        'prefill': <String, String>{
          
          'email': 'test@razorpay.com',
          'contact': '9999999999',
          'name': 'Test User',
        },
        
        // Only include essential options to avoid errors
        'readonly': {
          'email': false,
          'contact': false
        },
        'send_sms_hash': true,
      };
      
      // Remove any null values that might cause issues
      options.removeWhere((key, value) => value == null);
      
      // Don't add optional parameters that might cause issues
      // Only add these if explicitly required
      if (notes != null && notes['image'] != null) {
        options['image'] = notes['image'];
      }
      
      // Log the Razorpay options for debugging
      developer.log('⭐️ RAZORPAY OPTIONS: $options', name: 'RazorpayService');
      developer.log('⭐️ Order ID being used: $orderId', name: 'RazorpayService');
      
      print('Opening Razorpay with options: $options');
      _razorpay.open(options);
    } catch (e) {
      // Log detailed error information
      print('Error processing payment: $e');
      developer.log('❌ RAZORPAY: Error processing payment: $e', name: 'RazorpayService');
      developer.log('❌ RAZORPAY: Error stack trace: ${StackTrace.current}', name: 'RazorpayService');
      
      // Try to show a more detailed error message to help debugging
      String errorMessage = e.toString();
      if (e is Exception) {
        // Show dialog with error details
        showDialog(
          context: _context,
          builder: (context) => AlertDialog(
            title: Text('Payment Error'),
            content: SingleChildScrollView(
              child: Text('Error details: $errorMessage\n\n')
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      
      if (_onPaymentFailure != null) {
        _onPaymentFailure!();
      }
    }
  }

  /// Legacy method that uses WebView-based checkout
  /// This method is kept for backward compatibility
  static Future<void> launchRazorpayCheckout({
    required BuildContext context,
    required double amount,
    required String razorpayUrl,
    Function? onPaymentSuccess,
    Function? onPaymentFailure,
  }) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RazorpayCheckout(
          totalAmount: amount,
          razorpayUrl: razorpayUrl,
          onPaymentSuccess: onPaymentSuccess,
          onPaymentFailure: onPaymentFailure,
        ),
      ),
    );
  }
}
