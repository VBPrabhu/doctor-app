import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'auth_service.dart';
import 'payment_api_service.dart';

/// A simple utility class to test direct API connectivity to the payment backend
/// without going through the full Razorpay payment flow
class PaymentApiTest {
  final AuthService _authService = Get.find<AuthService>();
  final PaymentApiService _paymentApiService = Get.find<PaymentApiService>();

  /// Tests the direct connection to the payment backend create-order endpoint
  /// Returns a detailed map with test results, error info, and connectivity details
  Future<Map<String, dynamic>> testCreateOrderConnection() async {
    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'testId': 'test_${DateTime.now().millisecondsSinceEpoch}',
      'success': false,
      'errors': [],
      'details': {},
    };

    try {
      // First check general connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      results['connectivity'] = {
        'status': connectivityResult != ConnectivityResult.none ? 'connected' : 'disconnected',
        'type': connectivityResult.toString(),
      };

      if (connectivityResult == ConnectivityResult.none) {
        results['errors'].add('No network connectivity available');
        return results;
      }

      // Try to ping Google DNS to verify actual internet connectivity
      bool hasInternet = false;
      try {
        final List<InternetAddress> result = await InternetAddress.lookup('8.8.8.8');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          hasInternet = true;
        }
      } catch (e) {
        results['errors'].add('Failed DNS lookup: ${e.toString()}');
      }

      results['connectivity']['internet'] = hasInternet;
      
      if (!hasInternet) {
        results['errors'].add('No internet connectivity (DNS lookup failed)');
        return results;
      }

      // Check if we're logged in
      if (!_authService.isLoggedIn) {
        results['auth'] = {
          'status': 'not_logged_in',
        };
        
        try {
          // Try to login
          final bool loginSuccess = await _authService.login('test@lemicare.com', 'password123');
          results['auth']['login_attempt'] = loginSuccess;
          
          if (!loginSuccess) {
            results['errors'].add('Authentication failed with test credentials');
            return results;
          }
        } catch (e) {
          results['auth']['login_error'] = e.toString();
          results['errors'].add('Login error: ${e.toString()}');
          return results;
        }
      } else {
        results['auth'] = {
          'status': 'logged_in',
          'token_length': _authService.token.length,
        };
      }

      // Create test request body
      final Map<String, dynamic> requestBody = {
        'amount': 100.0,
        'currency': 'INR',
        'sourceInvoiceId': 'test_${DateTime.now().millisecondsSinceEpoch}',
        'sourceService': 'MOBILE_APP'
      };

      results['request'] = {
        'url': '${_paymentApiService.getBaseUrl()}/api/internal/payments/create-order',
        'body': requestBody,
      };

      // Prepare auth headers
      final String authToken = _authService.token;
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      // Make the direct API call
      final dio = Dio();
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (log) => developer.log('🔵 TEST DIO: $log', name: 'PaymentAPITest')
      ));

      developer.log('🔵 TEST: Making direct API call to create-order endpoint', name: 'PaymentAPITest');
      
      final dioResponse = await dio.post(
        '${_paymentApiService.getBaseUrl()}/api/internal/payments/create-order',
        data: requestBody,
        options: Options(
          headers: headers,
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ).timeout(const Duration(seconds: 15));

      // Process response
      final statusCode = dioResponse.statusCode ?? 0;
      results['response'] = {
        'status_code': statusCode,
        'data': dioResponse.data,
      };

      if (statusCode == 200 || statusCode == 201) {
        results['success'] = true;
        results['details']['message'] = 'API connection successful';
      } else {
        results['errors'].add('Unexpected status code: $statusCode');
      }

    } catch (e) {
      developer.log('❌ TEST ERROR: ${e.toString()}', name: 'PaymentAPITest');
      
      // Add detailed error info
      if (e is DioException) {
        results['errors'].add('DioError: ${e.message}');
        results['details']['error_type'] = e.type.toString();
        
        if (e.response != null) {
          results['details']['status_code'] = e.response?.statusCode;
          results['details']['response_data'] = e.response?.data;
        }
      } else {
        results['errors'].add(e.toString());
      }
    }

    return results;
  }

  /// Tests the direct connection to the payment backend verify-payment endpoint
  /// Uses mock data for payment ID and signature that would normally come from Razorpay
  Future<Map<String, dynamic>> testVerifyPaymentConnection() async {
    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'testId': 'test_${DateTime.now().millisecondsSinceEpoch}',
      'success': false,
      'errors': [],
      'details': {},
    };

    try {
      // Check connectivity (reuse the same code as above)
      final connectivityResult = await Connectivity().checkConnectivity();
      results['connectivity'] = {
        'status': connectivityResult != ConnectivityResult.none ? 'connected' : 'disconnected',
        'type': connectivityResult.toString(),
      };

      if (connectivityResult == ConnectivityResult.none) {
        results['errors'].add('No network connectivity available');
        return results;
      }

      // Try to ping Google DNS to verify actual internet connectivity
      bool hasInternet = false;
      try {
        final List<InternetAddress> result = await InternetAddress.lookup('8.8.8.8');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          hasInternet = true;
        }
      } catch (e) {
        results['errors'].add('Failed DNS lookup: ${e.toString()}');
      }

      results['connectivity']['internet'] = hasInternet;
      
      if (!hasInternet) {
        results['errors'].add('No internet connectivity (DNS lookup failed)');
        return results;
      }

      // Check if we're logged in
      if (!_authService.isLoggedIn) {
        results['auth'] = {
          'status': 'not_logged_in',
        };
        
        try {
          // Try to login
          final bool loginSuccess = await _authService.login('test@lemicare.com', 'password123');
          results['auth']['login_attempt'] = loginSuccess;
          
          if (!loginSuccess) {
            results['errors'].add('Authentication failed with test credentials');
            return results;
          }
        } catch (e) {
          results['auth']['login_error'] = e.toString();
          results['errors'].add('Login error: ${e.toString()}');
          return results;
        }
      } else {
        results['auth'] = {
          'status': 'logged_in',
          'token_length': _authService.token.length,
        };
      }

      // Create mock verification request body
      final String mockOrderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      final String mockPaymentId = 'pay_${DateTime.now().millisecondsSinceEpoch}';
      final String mockSignature = 'test_signature_${DateTime.now().millisecondsSinceEpoch}';
      
      final Map<String, dynamic> requestBody = {
        'razorpayOrderId': mockOrderId,
        'razorpayPaymentId': mockPaymentId,
        'razorpaySignature': mockSignature
      };

      results['request'] = {
        'url': '${_paymentApiService.getBaseUrl()}/api/internal/payments/verify-payment',
        'body': requestBody,
      };

      // Prepare auth headers
      final String authToken = _authService.token;
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      // Make the direct API call
      final dio = Dio();
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (log) => developer.log('🔵 TEST DIO: $log', name: 'PaymentAPITest')
      ));

      developer.log('🔵 TEST: Making direct API call to verify-payment endpoint', name: 'PaymentAPITest');
      
      final dioResponse = await dio.post(
        '${_paymentApiService.getBaseUrl()}/api/internal/payments/verify-payment',
        data: requestBody,
        options: Options(
          headers: headers,
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ).timeout(const Duration(seconds: 15));

      // Process response
      final statusCode = dioResponse.statusCode ?? 0;
      results['response'] = {
        'status_code': statusCode,
        'data': dioResponse.data,
      };

      // Note: We expect a 400 or similar error here because we're using fake payment data
      // But the important thing is that we can reach the endpoint
      if (statusCode >= 200 && statusCode < 500) {
        results['success'] = true;
        results['details']['message'] = 'API connection successful';
        
        if (statusCode >= 400) {
          results['details']['note'] = 'Got expected validation error with mock payment data';
        }
      } else {
        results['errors'].add('Unexpected status code: $statusCode');
      }

    } catch (e) {
      developer.log('❌ TEST ERROR: ${e.toString()}', name: 'PaymentAPITest');
      
      // Add detailed error info
      if (e is DioException) {
        results['errors'].add('DioError: ${e.message}');
        results['details']['error_type'] = e.type.toString();
        
        // If we get a 400 response, it might actually be good news - it means we reached the API
        // but our test data was rejected (as expected)
        if (e.response != null) {
          final statusCode = e.response?.statusCode ?? 0;
          results['details']['status_code'] = statusCode;
          results['details']['response_data'] = e.response?.data;
          
          if (statusCode == 400 || statusCode == 422) {
            results['success'] = true;
            results['details']['message'] = 'API connection successful with expected validation error';
          }
        }
      } else {
        results['errors'].add(e.toString());
      }
    }

    return results;
  }
}
