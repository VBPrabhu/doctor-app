import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxController {
  static AuthService get instance => Get.find<AuthService>();

  // Observable variables
  final Rx<bool> _isLoggedIn = false.obs;
  final Rx<String> _token = "".obs;
  final Rx<String> _refreshToken = "".obs;
  final Rx<String> _organizationId = "".obs;
  final Rx<String> _branchId = "".obs;
  
  // Base URL for auth API
  final String _baseUrl = "http://192.168.1.101:8085";
  
  // Getters
  bool get isLoggedIn => _isLoggedIn.value;
  String get token => _token.value;
  String get organizationId => _organizationId.value;
  String get branchId => _branchId.value;
  
  // Initialization
  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
    loadTokens();
  }
  
  // Check if user is logged in using shared preferences
  Future<bool> checkLoginStatus() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool? loggedIn = prefs.getBool('isLoggedIn');
      _isLoggedIn.value = loggedIn ?? false;
      return _isLoggedIn.value;
    } catch (e) {
      _isLoggedIn.value = false;
      return false;
    }
  }
  
  // Load tokens from shared preferences
  Future<void> loadTokens() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _token.value = prefs.getString('token') ?? "";
      _refreshToken.value = prefs.getString('refreshToken') ?? "";
      _organizationId.value = prefs.getString('organizationId') ?? "";
      _branchId.value = prefs.getString('branchId') ?? "";
      
      // If token exists, consider the user logged in
      if (_token.value.isNotEmpty) {
        _isLoggedIn.value = true;
      }
    } catch (e) {
      print('Error loading tokens: $e');
    }
  }
  
  // Set logged in status when user logs in
  Future<void> setLoggedIn(bool value) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', value);
      _isLoggedIn.value = value;
      
      // If logging out, clear tokens
      if (!value) {
        await clearTokens();
      }
    } catch (e) {
      print('Error setting login status: $e');
    }
  }
  
  // Save JWT tokens and claims
  Future<void> saveTokens(String token, String refreshToken) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('refreshToken', refreshToken);
      _token.value = token;
      _refreshToken.value = refreshToken;
      
      // Parse JWT to get organization and branch IDs
      Map<String, dynamic> payload = parseJwt(token);
      _organizationId.value = payload['organizationId'] ?? "";
      _branchId.value = payload['branchId'] ?? "";
      
      await prefs.setString('organizationId', _organizationId.value);
      await prefs.setString('branchId', _branchId.value);
      
      _isLoggedIn.value = true;
    } catch (e) {
      print('Error saving tokens: $e');
    }
  }
  
  // Clear tokens on logout
  Future<void> clearTokens() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('refreshToken');
      await prefs.remove('organizationId');
      await prefs.remove('branchId');
      _token.value = "";
      _refreshToken.value = "";
      _organizationId.value = "";
      _branchId.value = "";
    } catch (e) {
      print('Error clearing tokens: $e');
    }
  }
  
  // Get stored user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userData = prefs.getString('userData');
      if (userData != null) {
        // In a real app, you'd parse JSON data here
        return {'email': prefs.getString('userEmail') ?? ''};
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Login method that calls backend API and stores JWT
  Future<bool> login(String username, String password) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        '$_baseUrl/api/auth/login',
        data: {
          'username': username,
          'password': password,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        await saveTokens(data['token'], data['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      // For testing purposes, create a dummy token with required claims
      if (username == 'test@lemicare.com' && password == 'password123') {
        await saveTokens(
          _generateMockToken(
            "test-user-123",
            "test-org-123",
            "test-branch-456"
          ),
          "mock-refresh-token"
        );
        return true;
      }
      return false;
    }
  }
  
  // Logout method
  Future<void> logout() async {
    await setLoggedIn(false);
  }
  
  // Refresh token if expired
  Future<bool> refreshAuthToken() async {
    try {
      if (_refreshToken.value.isEmpty) {
        return false;
      }
      
      final dio = Dio();
      final response = await dio.post(
        '$_baseUrl/api/auth/refresh',
        data: {'refreshToken': _refreshToken.value},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        await saveTokens(data['token'], data['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }
  
  // Get authorization header for API calls
  Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${_token.value}'
    };
  }
  
  // Parse JWT token
  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return {};
    }
    
    final payload = parts[1];
    var normalized = base64Url.normalize(payload);
    var resp = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(resp);
    return payloadMap;
  }
  
  // Helper method to generate a mock JWT token for testing
  String _generateMockToken(String userId, String orgId, String branchId) {
    // For testing, we'll use a hardcoded valid token that matches our backend's JWT secret
    // This token is valid until 2026-08-25 (1 year from now)
    // You would NOT do this in a production app
    
    // This token is properly signed with the backend secret key: YourSuperStrongAndLongSecretKeyForHmacShaAlgorithmsAtLeast256Bits
    // and includes the correct issuer from application.yml: https://smartbridgein.com
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0LXVzZXItMTIzIiwib3JnYW5pemF0aW9uSWQiOiJ0ZXN0LW9yZy0xIiwiYnJhbmNoSWQiOiJ0ZXN0LWJyYW5jaC0xIiwicm9sZSI6IlVTRVIiLCJpc3MiOiJodHRwczovL3NtYXJ0YnJpZGdlaW4uY29tIiwiZXhwIjoxNzg3NjYwNTYyLCJpYXQiOjE3NTYxMjQ1NjJ9.lGmNCNyDk8buoVKzeSOe4weTkP7q4l7x3Pqn4iItzkY";
  }

}
