import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ShipRocketService {
  // ShipRocket API credentials and endpoints
  static const String _baseUrl = 'https://apiv2.shiprocket.in/v1';
  static const String _loginEndpoint = '/external/auth/login';
  static const String _trackingEndpoint = '/external/courier/track';
  static const String _createOrderEndpoint = '/external/orders/create/adhoc';
  
  // Credentials - In a real app, these should be securely stored
  static const String _email = 'your_shiprocket_email@example.com'; // Replace with actual email
  static const String _password = 'your_shiprocket_password'; // Replace with actual password

  static String? _authToken;
  
  // Initialize and get authentication token
  static Future<bool> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('shiprocket_token');
      
      // Check if token exists or needs refresh
      if (_authToken == null) {
        return await _login();
      }
      return true;
    } catch (e) {
      print('ShipRocket initialization error: $e');
      return false;
    }
  }
  
  // Login to ShipRocket and get token
  static Future<bool> _login() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_loginEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _email,
          'password': _password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        
        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('shiprocket_token', _authToken!);
        
        return true;
      } else {
        print('ShipRocket login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('ShipRocket login error: $e');
      return false;
    }
  }
  
  // Create a new order for tracking
  static Future<Map<String, dynamic>?> createOrder({
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String shippingAddress,
    required String shippingCity,
    required String shippingState,
    required String shippingPincode,
    required String shippingCountry,
    required double orderAmount,
    required List<Map<String, dynamic>> orderItems,
  }) async {
    if (_authToken == null && !await initialize()) {
      print('Failed to initialize ShipRocket service');
      return null;
    }
    
    try {
      final payload = {
        'order_id': orderId,
        'order_date': DateTime.now().toIso8601String().split('T')[0],
        'pickup_location': 'Primary',
        'billing_customer_name': customerName,
        'billing_last_name': '',
        'billing_email': customerEmail,
        'billing_phone': customerPhone,
        'billing_address': shippingAddress,
        'billing_city': shippingCity,
        'billing_state': shippingState,
        'billing_country': shippingCountry,
        'billing_pincode': shippingPincode,
        'shipping_is_billing': true,
        'shipping_customer_name': customerName,
        'shipping_address': shippingAddress,
        'shipping_city': shippingCity,
        'shipping_state': shippingState,
        'shipping_country': shippingCountry,
        'shipping_pincode': shippingPincode,
        'shipping_email': customerEmail,
        'shipping_phone': customerPhone,
        'order_items': orderItems,
        'payment_method': 'Prepaid',
        'sub_total': orderAmount,
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl$_createOrderEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Failed to create ShipRocket order: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating ShipRocket order: $e');
      return null;
    }
  }
  
  // Track a shipment
  static Future<Map<String, dynamic>?> trackShipment(String awbCode) async {
    if (_authToken == null && !await initialize()) {
      print('Failed to initialize ShipRocket service');
      return null;
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_trackingEndpoint?awb=$awbCode'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to track shipment: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error tracking shipment: $e');
      return null;
    }
  }
  
  // Get tracking URL for customer
  static String getTrackingUrl(String awbCode) {
    return 'https://shiprocket.co/tracking/$awbCode';
  }
}
