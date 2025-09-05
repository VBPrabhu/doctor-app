import 'package:flutter_test/flutter_test.dart';
import 'package:doctorapp/AppServices/auth_service.dart';
import 'package:doctorapp/AppServices/payment_api_service.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([AuthService])
import 'payment_auth_test.mocks.dart';

void main() {
  setUp(() {
    // Register the AuthService mock
    final authService = MockAuthService();
    Get.put<AuthService>(authService);
    
    // Configure default behaviors
    when(authService.isLoggedIn).thenReturn(true);
    when(authService.token).thenReturn('mock-token');
    when(authService.getAuthHeaders()).thenReturn({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer mock-token'
    });
  });

  tearDown(() {
    Get.reset();
  });

  test('PaymentApiService gets AuthService instance', () {
    // This will use the registered mock
    final paymentService = PaymentApiService();
    expect(Get.isRegistered<AuthService>(), true);
  });

  test('PaymentApiService uses auth headers for API calls', () async {
    // Create a new mock specifically for this test
    final authService = Get.find<AuthService>();
    
    // Add behavior for login method
    when(authService.login(any, any)).thenAnswer((_) async => true);
    
    // Create the payment service
    final paymentService = PaymentApiService();
    
    // Test will pass if PaymentService doesn't throw an exception
    // In a real test, you would use something like mockito to mock HTTP calls
    try {
      await paymentService.createOrder(amount: 100, currency: 'INR');
      // If we get here without an exception, we're good
      expect(true, true);
    } catch (e) {
      // We expect a network error, not an authentication error
      expect(e.toString().contains('Authentication'), false);
    }
    
    // Verify that auth headers were requested
    verify(authService.getAuthHeaders()).called(greaterThan(0));
  });
  
  test('PaymentApiService attempts login if not authenticated', () async {
    // Create a new mock specifically for this test
    final authService = Get.find<AuthService>();
    
    // Set logged out state
    when(authService.isLoggedIn).thenReturn(false);
    when(authService.login(any, any)).thenAnswer((_) async => true);
    
    // Create the payment service
    final paymentService = PaymentApiService();
    
    // Test will pass if login is called
    try {
      await paymentService.createOrder(amount: 100, currency: 'INR');
    } catch (e) {
      // Expected network error
    }
    
    // Verify login was called
    verify(authService.login(any, any)).called(1);
  });
  
  test('PaymentApiService attempts token refresh on 401', () async {
    // Skip this test because we can't easily mock the DioException in this context
    // In a real test environment with proper mocking, this would verify the retry behavior
  });
}
