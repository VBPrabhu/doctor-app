import 'dart:convert';
import 'dart:io';
import 'package:doctorapp/AppServices/payment_api_service.dart';
import 'package:flutter/material.dart';
import 'package:doctorapp/AppServices/razorpay_service.dart';
import 'dart:developer' as developer;

/// Helper class for debugging Razorpay payment issues
class PaymentDebugHelper {
  // Singleton instance
  static final PaymentDebugHelper _instance = PaymentDebugHelper._internal();
  factory PaymentDebugHelper() => _instance;
  PaymentDebugHelper._internal();

  // Services
  final PaymentApiService _paymentApiService = PaymentApiService();
  
  // Debug flags and settings
  bool _verbose = true;

  /// Test backend connectivity and validate API endpoints
  /// This will check if your backend server is reachable and responsive
  Future<Map<String, dynamic>> testBackendConnectivity() async {
    _log('Starting backend connectivity test');
    try {
      final results = await _paymentApiService.testBackendConnectivity();
      _log('Backend connectivity test completed');
      return results;
    } catch (e) {
      _log('Error testing backend connectivity: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Test the complete payment flow with a small test amount
  /// This will create an order, but not launch the payment UI
  Future<Map<String, dynamic>> testPaymentOrderCreation({
    double amount = 1.0,
    String currency = 'INR',
  }) async {
    _log('Testing payment order creation with amount: $amount $currency');
    
    try {
      // Test order creation
      final orderData = await _paymentApiService.createOrder(
        amount: amount,
        currency: currency,
        receiptId: 'test_receipt_${DateTime.now().millisecondsSinceEpoch}',
        notes: {'debug': 'true', 'test': 'payment-flow-debug'},
      );
      
      _log('Order created successfully: ${jsonEncode(orderData)}');
      
      // Verify if this is a real order or a mock order
      final isMockOrder = orderData['orderId'].toString().contains('mock');
      _log('Is mock order: $isMockOrder');

      // Verify with backend if order exists on Razorpay server
      if (!isMockOrder) {
        _log('Verifying order on Razorpay server...');
        final verifyResult = await _paymentApiService.verifyOrderOnRazorpay(
          orderData['orderId']
        );
        _log('Order verification result: ${jsonEncode(verifyResult)}');
      }
      
      return {
        'success': true,
        'orderData': orderData,
        'isMockData': isMockOrder,
      };
    } catch (e) {
      _log('Error in payment order creation: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Get detailed information about the device and environment
  Future<Map<String, dynamic>> getEnvironmentInfo() async {
    _log('Getting environment information');
    
    Map<String, dynamic> info = {};
    
    // Basic platform info
    info['platform'] = Platform.operatingSystem;
    info['version'] = Platform.operatingSystemVersion;
    info['isAndroid'] = Platform.isAndroid;
    info['isIOS'] = Platform.isIOS;
    
    // Network info
    try {
      final interfaces = await NetworkInterface.list();
      info['networkInterfaces'] = interfaces.map((interface) {
        return {
          'name': interface.name,
          'addresses': interface.addresses.map((addr) => {
            'address': addr.address,
            'type': addr.type.name,
          }).toList(),
        };
      }).toList();
    } catch (e) {
      info['networkError'] = e.toString();
    }
    
    // API configuration
    info['apiBaseUrl'] = _paymentApiService.getBaseUrl();
    
    return info;
  }

  /// Display payment debug results in a dialog
  void showDebugResults(BuildContext context, Map<String, dynamic> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Debug Results'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Success: ${results['success']}'),
              const SizedBox(height: 10),
              if (results.containsKey('error'))
                Text('Error: ${results['error']}', style: TextStyle(color: Colors.red)),
              if (results.containsKey('orderData'))
                ..._buildMapDisplay('Order Data', results['orderData']),
              if (results.containsKey('tests'))
                ..._buildTestResults(results['tests']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  // Helper to build list items from map data
  List<Widget> _buildMapDisplay(String title, Map<String, dynamic> data) {
    List<Widget> widgets = [
      Text('$title:', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
    ];
    
    data.forEach((key, value) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text('$key: ${value.toString()}'),
        ),
      );
    });
    
    widgets.add(const SizedBox(height: 10));
    return widgets;
  }
  
  // Helper to build test results
  List<Widget> _buildTestResults(List<dynamic> tests) {
    List<Widget> widgets = [
      Text('Test Results:', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
    ];
    
    for (var test in tests) {
      final success = test['success'] ?? false;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error, 
                color: success ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${test['name']} ${test['error'] != null ? ": ${test['error']}" : ""}',
                  style: TextStyle(
                    color: success ? Colors.black87 : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      
      if (test['details'] != null) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              test['details'].toString(),
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
        );
      }
    }
    
    return widgets;
  }

  // Logging helper
  void _log(String message) {
    if (_verbose) {
      developer.log('🔍 PAYMENT DEBUG: $message', name: 'PaymentDebug');
    }
  }
}
