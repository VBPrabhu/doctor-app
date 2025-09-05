# Payment Authentication Testing Guide

This guide provides step-by-step instructions for testing the payment authentication system in the Doctor App.

## Prerequisites

1. Android or iOS device/emulator
2. Flutter development environment set up
3. Backend services running (optional for testing with mock data)

## Setup Testing Environment

### Option 1: Testing with Mock Data (No Backend Required)

1. Ensure the `_useMockData` flag in `PaymentApiService` is set to `true`.
2. The app will use mock authentication and payment data.

### Option 2: Testing with Backend

1. Update the backend URL in `PaymentApiService._baseUrl` to point to your backend:
   - Android Emulator: `http://10.0.2.2:8085` 
   - iOS Simulator: `http://127.0.0.1:8085`
   - Real Device: Use the IP address of your development machine: `http://192.168.x.x:8085`

2. Ensure backend services are running:
   - Auth service
   - Payment service

## Test Authentication Flow

### 1. Test Login

1. Clear app data or uninstall/reinstall the app
2. Launch the app
3. Navigate to the login screen
4. Enter test credentials:
   - Email: `test@lemicare.com`
   - Password: `password123`
5. Verify in logs that authentication succeeded and token was saved

### 2. Test Token Persistence

1. Login to the app
2. Force close the app
3. Relaunch the app
4. Check logs to verify token is loaded from SharedPreferences
5. Navigate to a screen that requires authentication

### 3. Test Token Refresh

1. Login to the app
2. Wait for token expiration or manually expire token (for testing)
3. Make an API call that requires authentication
4. Verify in logs that token refresh is attempted
5. Confirm new token is received and saved

## Test Payment Flow

### 1. Test Order Creation

1. Navigate to checkout page
2. Enter payment details
3. Verify in logs that authentication headers are added to API request
4. Confirm order creation API response

### 2. Test Payment Processing

1. Complete a payment through Razorpay test mode
2. Verify payment verification API is called with authentication headers
3. Check logs for successful verification response

### 3. Test Failure Scenarios

1. Test with invalid auth token:
   - Clear token in app but keep login status
   - Attempt payment
   - Verify auto-login or token refresh is attempted

2. Test with backend unavailable:
   - Turn off backend services
   - Attempt payment
   - Verify fallback to mock data works correctly

## Troubleshooting

### Common Issues

1. **Authentication Failures**
   - Check token format in logs
   - Verify backend JWT secret matches mobile app
   - Check if token is expired

2. **Connection Issues**
   - Verify backend URL is correct for your environment
   - Check network permissions in app

3. **Payment Failures**
   - Check Razorpay test credentials
   - Verify order parameters match Razorpay requirements

### Debugging Tips

1. Enable detailed logging by adding this before API calls:
   ```dart
   print('Auth headers: ${_authService.getAuthHeaders()}');
   ```

2. Monitor token expiration with:
   ```dart
   final tokenPayload = _authService.parseJwt(_authService.token);
   final expiration = DateTime.fromMillisecondsSinceEpoch(
     (tokenPayload['exp'] as int) * 1000);
   print('Token expires at: $expiration');
   ```

3. If using real backend, check server logs for auth validation errors
