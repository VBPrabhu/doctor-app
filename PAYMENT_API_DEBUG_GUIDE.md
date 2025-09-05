# Payment API Debugging Guide

This guide helps you debug and test the API calls between the Flutter app and the payment backend service.

## Table of Contents
1. [Overview](#overview)
2. [Common Issues](#common-issues)
3. [Debug Mode](#debug-mode)
4. [Checking Logs](#checking-logs)
5. [Testing Different Environments](#testing-different-environments)
6. [Network Testing](#network-testing)
7. [Mock Data vs Real API](#mock-data-vs-real-api)

## Overview

The payment flow involves several components:
- The Flutter app UI (`checkout_page.dart`)
- Razorpay integration service (`razorpay_service.dart`)
- Payment API service (`payment_api_service.dart`)
- Authentication service (`auth_service.dart`)
- Backend payment service

When making a payment, the app follows these steps:
1. Create an order via API
2. Show Razorpay payment form to user
3. Process payment in Razorpay
4. Verify payment via API
5. Show success/failure UI to user

## Common Issues

### API Calls Not Being Made
- **Check logs**: Look for 🔵 (info), ✅ (success), and ❌ (error) log messages with the tag "PaymentAPI"
- **Network connectivity**: The app will check connectivity before making API calls
- **Server availability**: If the server is unreachable, check your environment URL settings
- **Authentication**: Ensure that auth tokens are valid

### Mock Data Fallback
- The system is designed to fallback to mock data if API calls fail
- To disable mock data fallback and force API errors, modify `_useMockData = false` in the catch blocks

## Debug Mode

Enhanced logging is enabled in debug builds. To view the logs:
1. Run the app in debug mode via VSCode/Android Studio
2. Check the console output for logs tagged with "PaymentAPI"
3. Filter logs: Use "🔵 PAYMENT API" to see all payment API activity

## Checking Logs

Important log prefixes:
- 🔵 - Informational messages
- ✅ - Success messages
- ❌ - Error messages

Key logging points:
1. **API Service Initialization**: Shows selected base URL based on platform
2. **Network Connectivity**: Logs from connectivity checks
3. **API Calls**: Full request/response logging with Dio interceptor
4. **Authentication**: Token status and login attempts

## Testing Different Environments

The app supports multiple server environments:
- **Production**: https://lemicare-payment-service.onrender.com
- **Android Emulator**: http://10.0.2.2:8085 
- **iOS Simulator**: http://127.0.0.1:8085
- **Direct Device**: http://192.168.1.101:8085

To change environments:
1. Environment is auto-selected based on platform and build type
2. For manual testing, temporarily modify `_initBaseUrl()` to force a specific URL

## Network Testing

### Verifying API Connectivity
```dart
// Manual test code snippet
final connectivityResult = await Connectivity().checkConnectivity();
final pingResult = await InternetAddress.lookup('8.8.8.8');
```

### Testing API Directly
Use an API testing tool like Postman or curl:
```bash
curl -X POST https://lemicare-payment-service.onrender.com/api/internal/payments/create-order \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"amount": 100, "currency": "INR", "sourceInvoiceId": "test_123", "sourceService": "MOBILE_APP"}'
```

## Mock Data vs Real API

When debugging, be aware of:

1. **Mock Data Flag**: If `_useMockData` is true, the app will use mock data without API calls
2. **API Error Fallback**: API errors now throw exceptions instead of automatically falling back to mock data
3. **Error Messages**: Check for detailed API error logs to understand why an API call failed

To force real API usage:
- Ensure network connectivity
- Verify server is up and running
- Make sure authentication is working
- Check that the correct environment URL is being used

---

For more details about Razorpay testing, see [RAZORPAY-TESTING-GUIDE.md](RAZORPAY-TESTING-GUIDE.md)
