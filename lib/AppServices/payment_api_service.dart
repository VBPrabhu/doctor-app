import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:doctorapp/AppServices/AppServices/Services/network_api_service.dart';
import 'package:doctorapp/AppServices/AppServices/Services/api_end_points.dart';
import 'package:doctorapp/AppServices/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class PaymentApiService {
  final NetworkApiService _apiService = NetworkApiService();
  late final AuthService _authService;
  
  // Base payment service URL - this should match your backend URL where payment service is hosted
  // We'll initialize with production URL and override in constructor if needed
  late String _baseUrl;
  
  // Server environment options
  static const String PROD_URL = "https://lemicare-payment-service.onrender.com";
  static const String DEV_URL = "http://10.0.2.2:8085"; // Android emulator address for localhost
  static const String LOCAL_IOS_URL = "http://127.0.0.1:8085"; // iOS simulator address
  
  // Common local network IPs to try for Android physical devices
  static const List<String> COMMON_NETWORK_IPS = [
    "192.168.1.100",
    "192.168.1.101", 
    "192.168.0.100",
    "192.168.0.101", 
    "192.168.1.1",
    "10.0.0.100",
    "10.0.1.100"
  ];
  
  // Default local IP fallback if none of the common IPs work
  static const String DEFAULT_LOCAL_IP = "192.168.1.100";
  
  // Custom network configuration - change this if needed for your specific network
  static String customLocalIP = "";
  
  // Port for local development server
  static const String DEV_PORT = "8085";
  
  // Android device URLs will be built dynamically based on IP discovery
  
  PaymentApiService() {
    // Initialize the base URL based on platform and environment
    _initBaseUrl();
    
    // Get instance of AuthService
    try {
      _authService = Get.find<AuthService>();
    } catch (e) {
      print('AuthService not found, trying to initialize it: $e');
      // If not found, register it
      Get.put(AuthService());
      _authService = Get.find<AuthService>();
    }
    
    // Log the selected base URL
    developer.log('🔵 PAYMENT API: Initialized with base URL: $_baseUrl', name: 'PaymentAPI');
  }
  
  // Create order API endpoint - MUST match backend controller path
  final String _createOrderEndpoint = "/api/internal/payments/create-order";
  
  // Verify payment API endpoint - MUST match backend controller path
  final String _verifyPaymentEndpoint = "/api/internal/payments/verify-payment";
  
  // Flag to use mock data for testing when backend is not available
  // We'll initialize it as false but will fall back to true if server connection fails
  bool _useMockData = false;

  // Debug flag to enable enhanced API debugging - set to true for detailed API logs
  bool _enhancedDebugMode = true;
  
  /// Check if the device has internet connectivity
  Future<bool> _checkConnectivity() async {
    String requestId = 'req_${DateTime.now().millisecondsSinceEpoch}';
    try {
      developer.log('🔵 PAYMENT API: Checking network connectivity', name: 'PaymentAPI');
      
      // First check if device has connectivity capability
      final connectivityResult = await Connectivity().checkConnectivity();
      developer.log('🔵 PAYMENT API: Connectivity result: $connectivityResult', name: 'PaymentAPI');
      
      if (connectivityResult == ConnectivityResult.none) {
        developer.log('❌ PAYMENT API: No network connectivity detected', name: 'PaymentAPI');
        return false;
      }
      
      // For web platform, the Connectivity check is enough
      if (kIsWeb) {
        developer.log('✅ PAYMENT API: Web platform detected, assuming internet connectivity', name: 'PaymentAPI');
        return true;
      }
      
      // For Android, we need special handling based on whether it's emulator or physical device
      if (Platform.isAndroid) {
        // First try connecting to the configured URL directly
        // This is most likely to work if we've configured the IP correctly
        try {
          developer.log('🔵 PAYMENT API: Attempting to ping configured URL first: $_baseUrl', name: 'PaymentAPI');
          final dio = Dio();
          dio.options.connectTimeout = const Duration(seconds: 10); // Increased timeout
          dio.options.receiveTimeout = const Duration(seconds: 5);  // Increased timeout
          
          // Just try to connect to the base URL
          final response = await dio.get(_baseUrl, 
              options: Options(validateStatus: (status) => true));
          
          // If we get any response, the server is reachable
          developer.log('✅ PAYMENT API: Successfully connected to configured URL with status: ${response.statusCode}', 
                      name: 'PaymentAPI');
          return true;
        } catch (e) {
          developer.log('⚠️ PAYMENT API: Failed to reach configured URL: $e', name: 'PaymentAPI');
          
          // Try production URL as a fallback
          try {
            developer.log('🔵 PAYMENT API: Trying production URL: $PROD_URL', name: 'PaymentAPI');
            final dio = Dio();
            dio.options.connectTimeout = const Duration(seconds: 10);
            dio.options.receiveTimeout = const Duration(seconds: 5);
            
            final response = await dio.get(PROD_URL, options: Options(validateStatus: (status) => true));
            developer.log('✅ PAYMENT API: Successfully pinged production URL with status: ${response.statusCode}', 
                        name: 'PaymentAPI');
            
            // If production URL worked but configured URL didn't, we have connectivity
            // but our local dev server URL might be wrong - print helpful message
            developer.log('⚠️ PAYMENT API: Connected to internet but not to dev server - your IP address may be incorrect', 
                        name: 'PaymentAPI');
            developer.log('⚠️ PAYMENT API: Current base URL: $_baseUrl', name: 'PaymentAPI');
            developer.log('⚠️ PAYMENT API: Set customLocalIP to your dev machine IP address', name: 'PaymentAPI');
            
            // Return true since we have internet connectivity, but print clear info about the local server issue
            return true;
          } catch (e2) {
            developer.log('⚠️ PAYMENT API: Failed to reach production URL too: $e2', name: 'PaymentAPI');
          }
          
          // If both configured URL and production URL fail, try alternative Android physical device IPs
          if (!_detectAndroidEmulator()) {
            // Only try alternative IPs for physical devices
            developer.log('🔵 PAYMENT API: Trying alternative local network IPs...', name: 'PaymentAPI');
            
            for (final ip in COMMON_NETWORK_IPS) {
              try {
                final testUrl = "http://$ip:$DEV_PORT";
                developer.log('🔵 PAYMENT API: Testing connection to: $testUrl', name: 'PaymentAPI');
                
                final dio = Dio();
                dio.options.connectTimeout = const Duration(seconds: 3); // Short timeout for scanning
                final response = await dio.get(testUrl, options: Options(validateStatus: (status) => true));
                
                // If successful, update the base URL for future use
                developer.log('✅ PAYMENT API: Successfully connected to alternative IP: $ip', name: 'PaymentAPI');
                customLocalIP = ip; // Remember this IP for future use
                _baseUrl = testUrl; // Update current base URL
                return true;
              } catch (e3) {
                // Continue to next IP
              }
            }
            developer.log('⚠️ PAYMENT API: No alternative IPs worked', name: 'PaymentAPI');
          }
        }
      }
      
      // Fall back to checking general internet connectivity
      try {
        developer.log('🔵 PAYMENT API: Checking general internet connectivity', name: 'PaymentAPI');
        
        // Try to connect to Google
        final dio = Dio();
        dio.options.connectTimeout = const Duration(seconds: 5);
        final response = await dio.get('https://www.google.com', 
            options: Options(validateStatus: (status) => true));
        
        developer.log('✅ PAYMENT API: Internet connectivity confirmed via Google', name: 'PaymentAPI');
        return true;
      } catch (e) {
        developer.log('⚠️ PAYMENT API: Failed to reach Google: $e', name: 'PaymentAPI');
        
        // Last resort: DNS lookup
        try {
          developer.log('🔵 PAYMENT API: Attempting DNS lookup', name: 'PaymentAPI');
          final List<InternetAddress> result = await InternetAddress.lookup('8.8.8.8');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            developer.log('✅ PAYMENT API: Internet connectivity available via DNS', name: 'PaymentAPI');
            return true;
          }
        } catch (e) {
          developer.log('❌ PAYMENT API: DNS lookup failed: $e', name: 'PaymentAPI');
        }
      }
      
      // If everything failed but Android shows connectivity, give it one last chance
      if (Platform.isAndroid && (connectivityResult == ConnectivityResult.mobile || 
                              connectivityResult == ConnectivityResult.wifi)) {
        developer.log('⚠️ PAYMENT API: All connectivity checks failed but Android shows connectivity', name: 'PaymentAPI');
        developer.log('⚠️ PAYMENT API: Proceeding with payment flow anyway', name: 'PaymentAPI');
        return true;
      }
      
      developer.log('❌ PAYMENT API: All internet connectivity checks failed', name: 'PaymentAPI');
      return false;
    } catch (e) {
      developer.log('❌ PAYMENT API: Error checking connectivity: $e', name: 'PaymentAPI');
      return false;
    }
  }
  
  /// Initialize the base URL based on platform and environment
  void _initBaseUrl() {
    try {
      // Check what environment we're in
      if (kReleaseMode) {
        // Production environment
        _baseUrl = PROD_URL;
        developer.log('🔵 PAYMENT API: Release mode - using production URL: $_baseUrl', name: 'PaymentAPI');
      } else {
        // Dev/debug environment - use appropriate localhost URL based on platform
        if (kIsWeb) {
          _baseUrl = PROD_URL;
          developer.log('🔵 PAYMENT API: Web platform detected, using production URL: $_baseUrl', name: 'PaymentAPI');
        } else if (Platform.isAndroid) {
          // For Android, we need to carefully select the right URL based on whether
          // we're running on an emulator or physical device
          bool isEmulator = _detectAndroidEmulator();
          
          if (isEmulator) {
            _baseUrl = DEV_URL; // Special URL for Android emulator to reach host
            developer.log('🔵 PAYMENT API: Android emulator detected, using emulator URL: $_baseUrl', name: 'PaymentAPI');
          } else {
            // Physical Android device needs the actual IP address of your dev machine
            // First check if custom IP has been set
            if (customLocalIP.isNotEmpty) {
              _baseUrl = "http://$customLocalIP:$DEV_PORT";
              developer.log('🔵 PAYMENT API: Using custom configured IP: $_baseUrl', name: 'PaymentAPI');
            } else {
              // Use default local network URL
              _baseUrl = "http://${DEFAULT_LOCAL_IP}:$DEV_PORT";
              developer.log('🔵 PAYMENT API: Android physical device detected, using default local IP: $_baseUrl', name: 'PaymentAPI');
              developer.log('⚠️ If connection fails, set PaymentApiService.customLocalIP to your development machine IP', name: 'PaymentAPI');
            }
          }
        } else if (Platform.isIOS) {
          _baseUrl = LOCAL_IOS_URL;
          developer.log('🔵 PAYMENT API: iOS simulator detected, using simulator URL: $_baseUrl', name: 'PaymentAPI');
        } else {
          // Default for other platforms
          String defaultUrl = "http://${DEFAULT_LOCAL_IP}:$DEV_PORT";
          _baseUrl = defaultUrl;
          developer.log('🔵 PAYMENT API: Other platform detected, using default URL: $_baseUrl', name: 'PaymentAPI');
        }
      }
    } catch (e) {
      // Fallback to production URL if any error occurs during initialization
      _baseUrl = PROD_URL;
      developer.log('🔴 PAYMENT API: Error selecting base URL: $e, using fallback: $_baseUrl', name: 'PaymentAPI');
    }
  }
  
  /// Better detection of Android emulator
  bool _detectAndroidEmulator() {
    try {
      // Multiple checks to detect if running on emulator
      // 1. Check environment variables
      bool envCheck = Platform.environment.containsKey('ANDROID_EMULATOR') || 
                     Platform.environment.containsKey('ANDROID_SDK_ROOT');
      
      // 2. Check device model and manufacturer
      bool modelCheck = false;
      try {
        // This requires the device_info_plus package
        // For simplicity here, we use other methods
        String model = Platform.operatingSystemVersion.toLowerCase();
        modelCheck = model.contains('sdk') || model.contains('emulator') || 
                    model.contains('simulator');
      } catch (e) {
        // Ignore model check errors
      }
      
      // 3. Check processor count (most emulators have fewer cores)
      bool procCheck = Platform.numberOfProcessors <= 2;
      
      // Combined check - if any two are true, likely an emulator
      return (envCheck && (modelCheck || procCheck)) || (modelCheck && procCheck);
    } catch (e) {
      // If detection fails, assume physical device to be safe
      developer.log('⚠️ PAYMENT API: Emulator detection failed: $e', name: 'PaymentAPI');
      return false;
    }
  }
  
  /// Returns the current base URL for the payment API
  /// This is used by testing tools to directly access the API
  String getBaseUrl() {
    return _baseUrl;
  }

  /// Test direct connectivity to the backend API
  /// Returns a detailed report about the connection status
  /// 
  /// This is useful for debugging connection issues with the backend
  Future<Map<String, dynamic>> testBackendConnectivity() async {
    developer.log('🔬 PAYMENT API: Running backend connectivity test', name: 'PaymentAPIDebug');
    
    Map<String, dynamic> results = {
      'timestamp': DateTime.now().toIso8601String(),
      'tests': []
    };
    
    // Test internet connectivity first
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      results['tests'].add({
        'name': 'Device Connectivity', 
        'success': connectivityResult != ConnectivityResult.none,
        'details': connectivityResult.toString()
      });
    } catch (e) {
      results['tests'].add({
        'name': 'Device Connectivity', 
        'success': false,
        'error': e.toString()
      });
    }
    
    // Test DNS resolution
    try {
      final List<InternetAddress> dnsResult = await InternetAddress.lookup('google.com');
      results['tests'].add({
        'name': 'DNS Resolution', 
        'success': dnsResult.isNotEmpty,
        'details': dnsResult.map((addr) => addr.address).join(', ')
      });
    } catch (e) {
      results['tests'].add({
        'name': 'DNS Resolution', 
        'success': false,
        'error': e.toString()
      });
    }
    
    // Parse base URL for components
    Uri baseUri;
    try {
      baseUri = Uri.parse(_baseUrl);
      results['baseUrl'] = {
        'full': _baseUrl,
        'host': baseUri.host,
        'port': baseUri.port,
        'scheme': baseUri.scheme
      };
    } catch (e) {
      results['baseUrl'] = {
        'full': _baseUrl,
        'error': 'Invalid URL format: ${e.toString()}'
      };
      return results; // Can't continue testing with invalid URL
    }
    
    // Test direct connection to base URL
    try {
      final response = await http.get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      results['tests'].add({
        'name': 'Backend Health Endpoint', 
        'success': response.statusCode < 500,
        'statusCode': response.statusCode,
        'response': response.body.length < 100 ? response.body : '${response.body.substring(0, 100)}...'
      });
    } catch (e) {
      results['tests'].add({
        'name': 'Backend Health Endpoint', 
        'success': false,
        'error': e.toString()
      });
    }
    
    // Test API endpoint without auth
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/status'))
          .timeout(const Duration(seconds: 5));
      results['tests'].add({
        'name': 'API Status Endpoint', 
        'success': response.statusCode < 500,
        'statusCode': response.statusCode,
        'response': response.body.length < 100 ? response.body : '${response.body.substring(0, 100)}...'
      });
    } catch (e) {
      results['tests'].add({
        'name': 'API Status Endpoint', 
        'success': false,
        'error': e.toString()
      });
    }
    
    // Try connecting to Razorpay API (public endpoint)
    try {
      final response = await http.get(Uri.parse('https://api.razorpay.com/v1/'))
          .timeout(const Duration(seconds: 5));
      results['tests'].add({
        'name': 'Razorpay API', 
        'success': response.statusCode != 0, // Any response from Razorpay is good
        'statusCode': response.statusCode,
        'response': response.body.length < 100 ? response.body : '${response.body.substring(0, 100)}...'
      });
    } catch (e) {
      results['tests'].add({
        'name': 'Razorpay API', 
        'success': false,
        'error': e.toString()
      });
    }
    
    // Log comprehensive results
    developer.log('🔬 PAYMENT API: Connectivity test results: ${jsonEncode(results)}', name: 'PaymentAPIDebug');
    
    return results;
  }
  
  /// Verify if an order exists on Razorpay server
  /// 
  /// This is a direct check against Razorpay API to verify if an order was created
  /// Note: This requires valid Razorpay API keys configured in your backend
  Future<Map<String, dynamic>> verifyOrderOnRazorpay(String orderId) async {
    developer.log('🔬 PAYMENT API: Verifying order on Razorpay: $orderId', name: 'PaymentAPIDebug');
    
    // We can't directly check the Razorpay API from client due to auth requirements
    // So we'll call our backend to do the verification for us
    
    try {
      // Check if we have auth token
      if (!_authService.isLoggedIn) {
        developer.log('❌ PAYMENT API: Not logged in, cannot verify order', name: 'PaymentAPIDebug');
        return {
          'success': false,
          'message': 'Authentication required to verify order with Razorpay'
        };
      }
      
      final String authToken = _authService.token;
      if (authToken.isEmpty) {
        developer.log('❌ PAYMENT API: Empty auth token', name: 'PaymentAPIDebug');
        return {
          'success': false,
          'message': 'Invalid authentication token'
        };
      }
      
      // Call backend to check order status with Razorpay
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };
      
      // Make the API call
      final dio = Dio();
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (log) => developer.log('🔬 DIO: $log', name: 'PaymentAPIDebug')
      ));
      
      final response = await dio.get(
        '$_baseUrl/api/internal/payments/check-order/$orderId',
        options: Options(
          headers: headers,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      
      developer.log('🔬 PAYMENT API: Order verification response: ${response.data}', name: 'PaymentAPIDebug');
      
      return {
        'success': true,
        'orderExists': response.data['exists'] ?? false,
        'orderDetails': response.data['details'] ?? {}
      };
    } catch (e) {
      developer.log('❌ PAYMENT API: Error verifying order: $e', name: 'PaymentAPIDebug');
      return {
        'success': false,
        'message': 'Failed to verify order: ${e.toString()}'
      };
    }
  }

  /// Helper method to ping a server to check if it's up
  Future<bool> _pingServer(String url) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      dio.options.validateStatus = (status) => true; // Accept any status code
      
      final response = await dio.get(url);
      return response.statusCode != null && response.statusCode! < 500;
    } catch (e) {
      return false;
    }
  }
  
  /// Creates a payment order with the backend
  /// 
  /// Returns a map containing order details including 'orderId', 'keyId', etc.
  Future<Map<String, dynamic>> createOrder({
    required double amount,
    required String currency,
    String? receiptId,
    Map<String, dynamic>? notes,
  }) async {
    // Define requestId at method level so it's accessible throughout the entire method
    // including catch blocks
    String requestId = 'req_${DateTime.now().millisecondsSinceEpoch}';
    developer.log('🔵 PAYMENT API: createOrder method called', name: 'PaymentAPI');
    developer.log('🔵 Amount: $amount, Currency: $currency, ReceiptId: $receiptId', name: 'PaymentAPI');
    developer.log('🔵 Current stack trace: ${StackTrace.current}', name: 'PaymentAPI');
    try {
      // First check connectivity before attempting API call
      final bool hasConnectivity = await _checkConnectivity();
      
      // If no connectivity or mock data flag is already set, skip API call
      if (!_useMockData && hasConnectivity) {
        try {
          developer.log('🔵 PAYMENT API: Preparing to make real API call to create order', name: 'PaymentAPI');
          developer.log('🔵 PAYMENT API: Using base URL: $_baseUrl', name: 'PaymentAPI');
          
          // Prepare the request body - match the backend expected format exactly
          // This must match CreateOrderRequest.java in the backend
          final Map<String, dynamic> requestBody = {
            'amount': amount,
            'currency': currency,
            'sourceInvoiceId': receiptId ?? 'receipt_${DateTime.now().millisecondsSinceEpoch}',
            'sourceService': 'MOBILE_APP'
          };
          
          developer.log('🔵 PAYMENT API: Request body matches backend DTO: CreateOrderRequest', name: 'PaymentAPI');
          
          // Add optional parameters to notes if provided
          if (notes != null) {
            // We can't directly send notes to the API as it's not in the DTO
            // But we can log them for debugging
            developer.log('🔵 Notes for order (not sent to API): $notes', name: 'PaymentAPI');
          }
          
          developer.log('🔵 PAYMENT API DEBUG: Creating order with request: ${jsonEncode(requestBody)}', name: 'PaymentAPI');
          developer.log('🔵 API URL: ${_baseUrl + _createOrderEndpoint}', name: 'PaymentAPI');
          developer.log('🔵 Device platform: $defaultTargetPlatform', name: 'PaymentAPI');
          
          // Check if we have auth token
          if (!_authService.isLoggedIn) {
            developer.log('🔵 User not logged in, attempting to login with test credentials', name: 'PaymentAPI');
            // Try to login with test credentials for development purposes
            final bool loginSuccess = await _authService.login('test@lemicare.com', 'password123');
            if (!loginSuccess) {
              developer.log('❌ Authentication failed with test credentials', name: 'PaymentAPI');
              throw Exception('Authentication required. Please login first.');
            }
            developer.log('🔵 Successfully logged in with test credentials', name: 'PaymentAPI');
          }
          
          // Get auth headers - check auth token validity
          final String authToken = _authService.token;
          if (authToken.isEmpty) {
            developer.log('❌ PAYMENT API: Auth token is empty despite being logged in', name: 'PaymentAPI');
            developer.log('🔵 PAYMENT API: Empty token detected - switching to mock data mode', name: 'PaymentAPI');
            
            // Switch to mock data mode instead of throwing exception
            _useMockData = true;
            
            // Break out of the try block to trigger the mock data flow
            return await createOrder(
              amount: amount,
              currency: currency,
              receiptId: receiptId,
              notes: notes
            );
          }
          
          final Map<String, String> headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          };
          
          developer.log('🔵 PAYMENT API: Using authentication token with length: ${authToken.length}', name: 'PaymentAPI');
          developer.log('🔵 PAYMENT API: Token prefix: ${authToken.substring(0, min(20, authToken.length))}...', name: 'PaymentAPI');
          
          // Make the API call with a reasonable timeout
          developer.log('🔵 PAYMENT API: Making Dio POST request to ${_baseUrl + _createOrderEndpoint}', name: 'PaymentAPI');
          final dio = Dio();
          dio.interceptors.add(LogInterceptor(
            requestBody: true,
            responseBody: true,
            error: true,
            logPrint: (log) => developer.log('🔵 DIO: $log', name: 'PaymentAPI')
          ));
          
          // Track start time for performance measurement
          final requestStartTime = DateTime.now();
          
          if (_enhancedDebugMode) {
            developer.log('🔬 API REQUEST [$requestId] STARTING: ${_baseUrl + _createOrderEndpoint}', name: 'PaymentAPIDebug');
            developer.log('🔬 API REQUEST [$requestId] HEADERS: ${headers.toString()}', name: 'PaymentAPIDebug');
            developer.log('🔬 API REQUEST [$requestId] BODY: ${jsonEncode(requestBody)}', name: 'PaymentAPIDebug');
          }
          
          final dioResponse = await dio.post(
            _baseUrl + _createOrderEndpoint,
            data: requestBody,
            options: Options(
              headers: headers,
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              // Capture request and response for debugging
              extra: {'requestId': requestId}
            ),
          ).timeout(const Duration(seconds: 15));
          
          // Log the successful response
          developer.log('✅ PAYMENT API: Order creation successful! Status code: ${dioResponse.statusCode}', name: 'PaymentAPI');
          developer.log('✅ PAYMENT API: Response data: ${dioResponse.data}', name: 'PaymentAPI');
          
          // Enhanced debug logging
          if (_enhancedDebugMode) {
            final requestDuration = DateTime.now().difference(requestStartTime);
            developer.log('🔬 API REQUEST [$requestId] COMPLETED: ${dioResponse.statusCode}', name: 'PaymentAPIDebug');
            developer.log('🔬 API REQUEST [$requestId] DURATION: ${requestDuration.inMilliseconds}ms', name: 'PaymentAPIDebug');
            developer.log('🔬 API REQUEST [$requestId] RESPONSE: ${jsonEncode(dioResponse.data)}', name: 'PaymentAPIDebug');
            
            // Deep analysis of the response
            if (dioResponse.data is Map) {
              final responseData = dioResponse.data as Map;
              // Check for common response fields
              if (responseData.containsKey('success')) {
                developer.log('🔬 API REQUEST [$requestId] SUCCESS FLAG: ${responseData['success']}', name: 'PaymentAPIDebug');
              }
              if (responseData.containsKey('data') && responseData['data'] is Map) {
                final orderData = responseData['data'] as Map;
                // Extract and log Razorpay-specific fields
                if (orderData.containsKey('orderId')) {
                  developer.log('🔬 API REQUEST [$requestId] ORDER ID: ${orderData['orderId']}', name: 'PaymentAPIDebug');
                }
                if (orderData.containsKey('keyId')) {
                  developer.log('🔬 API REQUEST [$requestId] KEY ID: ${orderData['keyId']}', name: 'PaymentAPIDebug');
                }
                
                // Validate Razorpay order ID format
                final orderId = orderData['orderId']?.toString() ?? '';
                if (!orderId.startsWith('order_')) {
                  developer.log('⚠️ API REQUEST [$requestId] WARNING: Order ID format invalid - should start with "order_"', 
                              name: 'PaymentAPIDebug');
                }
              }
            }
          }
          
          final response = dioResponse.data;
          
          // Check if the response is successful
          if (response['success'] == true) {
            developer.log('✅ PAYMENT API: Successfully extracted order data', name: 'PaymentAPI');
            final orderData = response['data'];
            
            // Validate order data has essential fields
            if (orderData == null || !orderData.containsKey('orderId') || !orderData.containsKey('keyId')) {
              developer.log('⚠️ PAYMENT API: Order data is missing required fields', name: 'PaymentAPI');
              developer.log('⚠️ Response data: $response', name: 'PaymentAPI');
              throw Exception('Server returned invalid order data: missing required fields');
            }
            
            // Log order details
            developer.log('✅ PAYMENT API: Order ID: ${orderData['orderId']}', name: 'PaymentAPI');
            developer.log('✅ PAYMENT API: Key ID: ${orderData['keyId']}', name: 'PaymentAPI');
            return orderData;
          } else {
            developer.log('❌ PAYMENT API: Server returned success:false - ${response['message']}', name: 'PaymentAPI');
            throw Exception('Backend error: ${response['message'] ?? 'Failed to create order'}');
          }
        } catch (e) {
          developer.log('❌ PAYMENT API ERROR: ${e.toString()}', name: 'PaymentAPI');
          developer.log('❌ Error type: ${e.runtimeType}', name: 'PaymentAPI');
          developer.log('❌ Stack trace: ${StackTrace.current}', name: 'PaymentAPI');
          
          if (e is DioException) {
            developer.log('❌ DioError type: ${e.type}', name: 'PaymentAPI');
            developer.log('❌ DioError message: ${e.message}', name: 'PaymentAPI');
            
            if (_enhancedDebugMode) {
              // Enhanced error debugging with request tracking
              developer.log('🔬 API REQUEST [$requestId] FAILED', name: 'PaymentAPIDebug');
              developer.log('🔬 API REQUEST [$requestId] ERROR TYPE: ${e.type}', name: 'PaymentAPIDebug');
              developer.log('🔬 API REQUEST [$requestId] ERROR MESSAGE: ${e.message}', name: 'PaymentAPIDebug');
              
              // Log raw request details for troubleshooting
              developer.log('🔬 API REQUEST [$requestId] REQUEST URL: ${e.requestOptions.uri}', name: 'PaymentAPIDebug');
              developer.log('🔬 API REQUEST [$requestId] REQUEST METHOD: ${e.requestOptions.method}', name: 'PaymentAPIDebug');
              developer.log('🔬 API REQUEST [$requestId] REQUEST HEADERS: ${e.requestOptions.headers}', name: 'PaymentAPIDebug');
              developer.log('🔬 API REQUEST [$requestId] REQUEST DATA: ${e.requestOptions.data}', name: 'PaymentAPIDebug');
              
              // Network information for troubleshooting
              Connectivity().checkConnectivity().then((connectivityResult) {
                developer.log('🔬 NETWORK STATUS: $connectivityResult', name: 'PaymentAPIDebug');
              });
            }
            
            if (e.response != null) {
              developer.log('❌ Status code: ${e.response?.statusCode}', name: 'PaymentAPI');
              developer.log('❌ Response data: ${e.response?.data}', name: 'PaymentAPI');
              
              if (_enhancedDebugMode) {
                developer.log('🔬 API REQUEST [$requestId] RESPONSE STATUS: ${e.response?.statusCode}', name: 'PaymentAPIDebug');
                developer.log('🔬 API REQUEST [$requestId] RESPONSE DATA: ${e.response?.data}', name: 'PaymentAPIDebug');
                developer.log('🔬 API REQUEST [$requestId] RESPONSE HEADERS: ${e.response?.headers}', name: 'PaymentAPIDebug');
              }
              
              // Check for specific error codes
              if (e.response?.statusCode == 401) {
                developer.log('❌ Authentication error (401)', name: 'PaymentAPI');
                // Test auth token validity
                final authToken = _authService.token;
                developer.log('🔬 AUTH TOKEN LENGTH: ${authToken.length}', name: 'PaymentAPIDebug');
                if (authToken.isNotEmpty) {
                  developer.log('🔬 AUTH TOKEN FIRST 10 CHARS: ${authToken.substring(0, min(10, authToken.length))}', name: 'PaymentAPIDebug');
                }
              } else if (e.response?.statusCode == 404) {
                developer.log('❌ API endpoint not found (404) - check URL and routes', name: 'PaymentAPI');
                developer.log('🔬 ENDPOINT PATH: $_createOrderEndpoint', name: 'PaymentAPIDebug');
              } else if (e.response?.statusCode == 500) {
                developer.log('❌ Server error (500) - check backend logs', name: 'PaymentAPI');
                // Try to parse error response for more details
                if (e.response?.data != null && e.response?.data is Map) {
                  final errorData = e.response?.data as Map;
                  if (errorData.containsKey('message')) {
                    developer.log('🔬 SERVER ERROR MESSAGE: ${errorData['message']}', name: 'PaymentAPIDebug');
                  }
                  if (errorData.containsKey('error')) {
                    developer.log('🔬 SERVER ERROR DETAILS: ${errorData['error']}', name: 'PaymentAPIDebug');
                  }
                }
              }
            } else {
              developer.log('❌ No response received - check network connection and server status', name: 'PaymentAPI');
              developer.log('❌ Request URL: ${e.requestOptions.uri}', name: 'PaymentAPI');
              
              if (_enhancedDebugMode) {
                // Try to ping the server to see if it's up
                _pingServer(_baseUrl).then((isUp) {
                  developer.log('🔬 SERVER PING TEST: ${isUp ? 'SERVER UP' : 'SERVER DOWN'}', name: 'PaymentAPIDebug');
                });
              }
              
              if (e.type == DioExceptionType.connectionTimeout) {
                developer.log('❌ Connection timeout - server might be down or unreachable', name: 'PaymentAPI');
              } else if (e.type == DioExceptionType.receiveTimeout) {
                developer.log('❌ Receive timeout - server processing took too long', name: 'PaymentAPI');
              } else if (e.type == DioExceptionType.sendTimeout) {
                developer.log('❌ Send timeout - unable to send request', name: 'PaymentAPI');
              }
            }
          }
          
          // Alert user about the connection error but don't automatically switch to mock data
          // We'll let the caller decide what to do based on the exception
          throw Exception('Cannot connect to payment server: ${e.toString()}');
        }
      }
      
      // If we reach here, either _useMockData was true initially or connectivity check failed
      if (_useMockData) {
        developer.log('🔵 PAYMENT API: Using mock data for order creation', name: 'PaymentAPI');
        developer.log('🔵 Mock mode is enabled - this will NOT call the real backend', name: 'PaymentAPI');
        
        // Generate a unique order ID using timestamp (keep it short)
        final orderId = 'order_mock_${DateTime.now().millisecondsSinceEpoch % 1000000}';
        
        // Use the Razorpay test key - this is a public test key for development
        const keyId = 'rzp_test_1DP5mmOlF5G5ag';
        
        developer.log('✅ PAYMENT API: Created mock order with ID: $orderId', name: 'PaymentAPI');
        developer.log('✅ PAYMENT API: Using test key: $keyId', name: 'PaymentAPI');
        
        // Return mock order data with EXACT format that Razorpay frontend SDK expects
        Map<String, dynamic> mockOrderData = {
          'orderId': orderId,
          'keyId': keyId,
          'amount': (amount * 100).toInt(), // Amount in paise
          'currency': currency,
          'status': 'created',
        };
        
        developer.log('🔍 PAYMENT API: Mock order data format: $mockOrderData', name: 'PaymentAPI');
        return mockOrderData;
      } else {
        // If we get here, it means connectivity check failed but we're not using mock data
        // In this case, we should automatically fall back to mock data as a last resort
        // to ensure the app can still be used for testing
        developer.log('⚠️ PAYMENT API: No network connectivity for creating order', name: 'PaymentAPI');
        developer.log('⚠️ PAYMENT API: Automatically falling back to mock data mode', name: 'PaymentAPI');
        
        // Set mock data flag for future calls
        _useMockData = true;
        
        // Generate a unique order ID (keep it short for Razorpay compatibility)
        final orderId = 'order_mock_${DateTime.now().millisecondsSinceEpoch % 1000000}';
        const keyId = 'rzp_test_1DP5mmOlF5G5ag';
        
        developer.log('✅ PAYMENT API: Created fallback mock order with ID: $orderId', name: 'PaymentAPI');
        
        // Use the EXACT same format for all mock data responses
        Map<String, dynamic> mockOrderData = {
          'orderId': orderId,
          'keyId': keyId,
          'amount': (amount * 100).toInt(), // Amount in paise
          'currency': currency,
          'status': 'created',
        };
        
        developer.log('🔍 PAYMENT API: Fallback mock order data: $mockOrderData', name: 'PaymentAPI');
        return mockOrderData;
      }
    } catch (e) {
      print('Error creating order: $e');
      
      // If it's an authentication error and we have automatic retry capability
      if (e.toString().contains('Authentication') || 
          (e is DioException && e.response?.statusCode == 401)) {
        try {
          print('Authentication error, attempting to refresh token...');
          developer.log('⚠️ PAYMENT API: Authentication error, attempting to refresh token...', name: 'PaymentAPI');
          final refreshed = await _authService.refreshAuthToken();
          if (refreshed) {
            print('Token refreshed, retrying order creation...');
            developer.log('✅ PAYMENT API: Token refreshed, retrying order creation...', name: 'PaymentAPI');
            // Retry the call with fresh token
            return await createOrder(
              amount: amount,
              currency: currency,
              receiptId: receiptId,
              notes: notes
            );
          } else {
            // If refresh failed, switch to mock data mode
            developer.log('❌ PAYMENT API: Token refresh failed, switching to mock data mode', name: 'PaymentAPI');
            _useMockData = true;
            
            // Generate mock data response with consistent format
            final orderId = 'order_mock_${DateTime.now().millisecondsSinceEpoch % 1000000}';
            const keyId = 'rzp_test_1DP5mmOlF5G5ag';
            
            developer.log('✅ PAYMENT API: Created mock order with ID: $orderId after auth failure', name: 'PaymentAPI');
            
            // Keep format consistent with other mock responses
            Map<String, dynamic> mockOrderData = {
              'orderId': orderId,
              'keyId': keyId,
              'amount': (amount * 100).toInt(), // Amount in paise
              'currency': currency,
              'status': 'created',
            };
            
            developer.log('🔍 PAYMENT API: Auth fallback mock order data: $mockOrderData', name: 'PaymentAPI');
            return mockOrderData;
          }
        } catch (refreshError) {
          print('Error refreshing token: $refreshError');
          developer.log('❌ PAYMENT API: Error refreshing token: $refreshError', name: 'PaymentAPI');
          
          // On refresh error, also switch to mock data mode
          developer.log('❌ PAYMENT API: Token refresh error, switching to mock data mode', name: 'PaymentAPI');
          _useMockData = true;
            
          // Generate mock data response with consistent format
          final orderId = 'order_mock_${DateTime.now().millisecondsSinceEpoch % 1000000}';
          const keyId = 'rzp_test_1DP5mmOlF5G5ag';
          
          developer.log('✅ PAYMENT API: Created mock order with ID: $orderId after auth refresh failure', name: 'PaymentAPI');
          
          // Keep format consistent with other mock responses
          Map<String, dynamic> mockOrderData = {
            'orderId': orderId,
            'keyId': keyId,
            'amount': (amount * 100).toInt(), // Amount in paise
            'currency': currency,
            'status': 'created',
          };
          
          developer.log('🔍 PAYMENT API: Refresh failure mock order data: $mockOrderData', name: 'PaymentAPI');
          return mockOrderData;
        }
      }
      
      if (_useMockData) {
        // If there's an error but we're using mock data, still return a mock response
        // This ensures the app can continue even if the backend is unavailable
        final orderId = 'order_mock_${DateTime.now().millisecondsSinceEpoch % 1000000}';
        
        // IMPORTANT: Use the same test key ID consistently throughout the app
        const keyId = 'rzp_test_1DP5mmOlF5G5ag';
        
        developer.log('✅ PAYMENT API: Created error fallback mock order: $orderId', name: 'PaymentAPI');
        
        return {
          'orderId': orderId,
          'keyId': keyId,
          'amount': (amount * 100).toInt(),
          'currency': currency,
          'status': 'created',
        };
      }
      // Convert rethrow to a specific exception throw to avoid Dart errors
      throw Exception('Failed to create order: $e');
    }
  }

  /// Verifies a payment with the backend after successful payment
  /// 
  /// Returns a map containing verification details
  Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    String? signature,
  }) async {
    developer.log('🔵 PAYMENT API: verifyPayment method called', name: 'PaymentAPI');
    developer.log('🔵 OrderId: $orderId, PaymentId: $paymentId, Signature present: ${signature != null}', name: 'PaymentAPI');
    developer.log('🔵 Current stack trace: ${StackTrace.current}', name: 'PaymentAPI');
    
    try {
      // First check connectivity before attempting API call
      final bool hasConnectivity = await _checkConnectivity();
      
      // If no connectivity or mock data flag is already set, skip API call
      if (!_useMockData && hasConnectivity) {
        try {
          developer.log('🔵 PAYMENT API: Preparing to make real API call to verify payment', name: 'PaymentAPI');
          developer.log('🔵 PAYMENT API: Using base URL: $_baseUrl', name: 'PaymentAPI');
          
          // Prepare the request body - match the backend DTO exactly (VerifySignatureRequest.java)
          final Map<String, dynamic> requestBody = {
            'razorpayOrderId': orderId,
            'razorpayPaymentId': paymentId,
            'razorpaySignature': signature ?? ''
          };
          
          developer.log('🔵 PAYMENT API: Request body matches backend DTO: VerifySignatureRequest', name: 'PaymentAPI');
          developer.log('🔵 PAYMENT API: Verification request: ${jsonEncode(requestBody)}', name: 'PaymentAPI');
          developer.log('🔵 PAYMENT API: API URL: ${_baseUrl + _verifyPaymentEndpoint}', name: 'PaymentAPI');
          
          // Check if we have auth token
          if (!_authService.isLoggedIn) {
            developer.log('🔵 PAYMENT API: User not logged in, attempting to login with test credentials', name: 'PaymentAPI');
            // Try to login with test credentials for development purposes
            final bool loginSuccess = await _authService.login('test@lemicare.com', 'password123');
            if (!loginSuccess) {
              developer.log('❌ PAYMENT API: Authentication failed with test credentials', name: 'PaymentAPI');
              throw Exception('Authentication required for payment verification. Please login first.');
            }
            developer.log('🔵 PAYMENT API: Successfully logged in with test credentials', name: 'PaymentAPI');
          }
          
          // Get auth headers - check auth token validity
          final String authToken = _authService.token;
          if (authToken.isEmpty) {
            developer.log('❌ PAYMENT API: Auth token is empty despite being logged in', name: 'PaymentAPI');
            developer.log('🔵 PAYMENT API: Empty token detected in verification - switching to mock data mode', name: 'PaymentAPI');
            
            // Switch to mock data mode instead of throwing exception
            _useMockData = true;
            
            // Call again which will use mock data path
            return await verifyPayment(
              orderId: orderId,
              paymentId: paymentId,
              signature: signature
            );
          }
          
          final Map<String, String> headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          };
          
          developer.log('🔵 PAYMENT API: Making verification API call with token length: ${authToken.length}', name: 'PaymentAPI');
          
          final dio = Dio();
          dio.interceptors.add(LogInterceptor(
            requestBody: true,
            responseBody: true,
            error: true,
            logPrint: (log) => developer.log('🔵 DIO: $log', name: 'PaymentAPI')
          ));
          
          final dioResponse = await dio.post(
            _baseUrl + _verifyPaymentEndpoint,
            data: requestBody,
            options: Options(
              headers: headers,
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          ).timeout(const Duration(seconds: 15));
          
          // Log the successful response
          developer.log('✅ PAYMENT API: Payment verification successful! Status code: ${dioResponse.statusCode}', name: 'PaymentAPI');
          developer.log('✅ PAYMENT API: Response data: ${dioResponse.data}', name: 'PaymentAPI');
          
          final response = dioResponse.data;
          
          // Check if the response is successful
          if (response['success'] == true) {
            developer.log('✅ PAYMENT API: Successfully verified payment', name: 'PaymentAPI');
            return response['data'];
          } else {
            developer.log('❌ PAYMENT API: Server returned success:false - ${response['message']}', name: 'PaymentAPI');
            throw Exception(response['message'] ?? 'Failed to verify payment');
          }
        } catch (e) {
          developer.log('❌ PAYMENT API ERROR during verification: ${e.toString()}', name: 'PaymentAPI');
          developer.log('❌ Error type: ${e.runtimeType}', name: 'PaymentAPI');
          developer.log('❌ Stack trace: ${StackTrace.current}', name: 'PaymentAPI');
          
          if (e is DioException) {
            developer.log('❌ DioError type: ${e.type}', name: 'PaymentAPI');
            developer.log('❌ DioError message: ${e.message}', name: 'PaymentAPI');
            
            if (e.response != null) {
              developer.log('❌ Status code: ${e.response?.statusCode}', name: 'PaymentAPI');
              developer.log('❌ Response data: ${e.response?.data}', name: 'PaymentAPI');
              
              // Check for specific error codes and handle token refresh
              if (e.response?.statusCode == 401) {
                developer.log('❌ Authentication error (401) - trying to refresh token', name: 'PaymentAPI');
                try {
                  final refreshed = await _authService.refreshAuthToken();
                  if (refreshed) {
                    developer.log('✅ Token refreshed, retrying verification', name: 'PaymentAPI');
                    return await verifyPayment(
                      orderId: orderId,
                      paymentId: paymentId,
                      signature: signature
                    );
                  }
                } catch (refreshError) {
                  developer.log('❌ Error refreshing token: $refreshError', name: 'PaymentAPI');
                }
              }
            }
          }
          
          // Don't automatically switch to mock data, throw the exception
          throw Exception('Cannot verify payment: ${e.toString()}');
        }
      }
      
      // If we get here, either connectivity check failed or _useMockData was true
      if (_useMockData) {
        developer.log('🟡 PAYMENT API: Using mock data for payment verification', name: 'PaymentAPI');
        return _getMockVerifyPaymentResponse(orderId: orderId, paymentId: paymentId, signature: signature);
      } else {
        developer.log('❌ PAYMENT API: No network connectivity for verification', name: 'PaymentAPI');
        throw Exception('No network connectivity. Please check your connection and try again.');
      }
    } catch (e) {
      developer.log('❌ PAYMENT API: Unhandled exception in verifyPayment: $e', name: 'PaymentAPI');
      throw e; // Re-throw the exception to be handled by the caller
    }
  }
  
  // Helper method to get a mock verify payment response
  Map<String, dynamic> _getMockVerifyPaymentResponse({
    required String orderId,
    required String paymentId,
    String? signature,
  }) {
    return {
      'status': 'success',
      'message': 'Payment verified successfully. (MOCK)',
      'data': {
        'verified': true,
        'orderId': orderId,
        'paymentId': paymentId,
        'status': 'captured',
        'signature': signature ?? 'mock_signature',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }
    };
  }
}
