import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// A centralized logging utility for payment-related operations
/// 
/// This class provides consistent logging for all payment services,
/// with custom prefixes, colors, and verbosity levels.
class PaymentLogger {
  // Define log prefixes
  static const String _paymentAPI = 'PaymentAPI';
  static const String _razorpay = 'RazorpayService';
  static const String _checkout = 'RazorpayCheckout';
  
  // Define log level indicators
  static const String _infoEmoji = '🔵';
  static const String _successEmoji = '✅';
  static const String _warningEmoji = '⚠️';
  static const String _errorEmoji = '❌';
  static const String _starEmoji = '⭐️';
  
  // Flag to control debug output verbosity
  static bool verboseLogging = true;
  
  /// Log information message
  static void info(String message, {String service = 'Payment'}) {
    _log(message, _infoEmoji, service);
  }
  
  /// Log success message
  static void success(String message, {String service = 'Payment'}) {
    _log(message, _successEmoji, service);
  }
  
  /// Log warning message
  static void warning(String message, {String service = 'Payment'}) {
    _log(message, _warningEmoji, service);
  }
  
  /// Log error message
  static void error(String message, {String service = 'Payment'}) {
    _log(message, _errorEmoji, service);
    // Always print errors to console too for visibility
    print('$_errorEmoji ERROR[$service]: $message');
  }
  
  /// Log important message (highlighted)
  static void important(String message, {String service = 'Payment'}) {
    _log(message, _starEmoji, service);
    // Also print to console for visibility
    print('$_starEmoji [$service]: $message');
  }
  
  /// Get payment API logger
  static PaymentLoggerService api() {
    return PaymentLoggerService(_paymentAPI);
  }
  
  /// Get Razorpay service logger
  static PaymentLoggerService razorpay() {
    return PaymentLoggerService(_razorpay);
  }
  
  /// Get Razorpay checkout logger
  static PaymentLoggerService checkout() {
    return PaymentLoggerService(_checkout);
  }
  
  /// Internal logging method
  static void _log(String message, String emoji, String service) {
    if (kReleaseMode && !verboseLogging) {
      // Skip verbose logs in release mode unless explicitly enabled
      return;
    }
    
    developer.log('$emoji $message', name: service);
  }
  
  /// Log network request details
  static void logRequest(String url, Map<String, dynamic>? data, {String service = 'Payment'}) {
    if (!verboseLogging) return;
    
    _log('Request URL: $url', _infoEmoji, service);
    if (data != null) {
      // Sanitize sensitive data
      final sanitizedData = _sanitizeSensitiveData(data);
      _log('Request data: $sanitizedData', _infoEmoji, service);
    }
  }
  
  /// Log network response details
  static void logResponse(dynamic response, {String service = 'Payment'}) {
    if (!verboseLogging) return;
    
    // Sanitize any sensitive data in the response
    final sanitizedResponse = _sanitizeSensitiveData(response);
    _log('Response: $sanitizedResponse', _infoEmoji, service);
  }
  
  /// Sanitize sensitive data for logging
  static dynamic _sanitizeSensitiveData(dynamic data) {
    if (data is Map) {
      final sanitized = Map<String, dynamic>.from(data);
      
      // Mask sensitive fields
      final sensitiveFields = [
        'token', 'password', 'secret', 'key', 'apiKey', 'api_key', 
        'auth', 'signature', 'cvv', 'card', 'pan'
      ];
      
      for (final field in sensitiveFields) {
        if (sanitized.containsKey(field)) {
          final value = sanitized[field].toString();
          if (value.isNotEmpty) {
            sanitized[field] = '${value.substring(0, 2)}***${value.substring(value.length - 2)}';
          }
        }
      }
      
      return sanitized;
    }
    
    return data;
  }
}

/// Logger service for a specific payment component
class PaymentLoggerService {
  final String _service;
  
  PaymentLoggerService(this._service);
  
  void info(String message) => PaymentLogger.info(message, service: _service);
  void success(String message) => PaymentLogger.success(message, service: _service);
  void warning(String message) => PaymentLogger.warning(message, service: _service);
  void error(String message) => PaymentLogger.error(message, service: _service);
  void important(String message) => PaymentLogger.important(message, service: _service);
  
  void logRequest(String url, Map<String, dynamic>? data) {
    PaymentLogger.logRequest(url, data, service: _service);
  }
  
  void logResponse(dynamic response) {
    PaymentLogger.logResponse(response, service: _service);
  }
}
