# Android Payment Setup Guide

This document provides instructions for setting up and testing the payment system on Android devices for the Doctor App.

## Prerequisites

- Android device or emulator running the Doctor App
- Backend payment service running and accessible
- Razorpay test account credentials configured

## Configuration Options

### Base URL Configuration

The payment system automatically selects the appropriate backend URL based on your runtime environment:

1. **Production**: Uses `https://lemicare-payment-service.onrender.com`
2. **Android Emulator**: Uses `http://10.0.2.2:8085` (special address to reach host machine)
3. **Android Physical Device**: Uses configurable IP address

### Setting Custom IP for Physical Android Device

If your app cannot connect to the backend when running on a physical Android device, you need to set the correct development machine IP address:

```dart
// Before initializing any payment flow, add this line:
PaymentApiService.customLocalIP = "192.168.1.xxx"; // Replace with your dev machine's IP
```

You can find your development machine's IP address using:
- macOS/Linux: Run `ifconfig` or `ip addr show` in terminal
- Windows: Run `ipconfig` in command prompt

## Testing the Connection

To verify that your Android device can connect to the payment backend:

1. Open the app and navigate to checkout
2. Monitor Logcat/console for connectivity logs
3. Look for logs containing "PaymentAPI" to see connectivity details

### Connection Troubleshooting

If you see "Failed to reach configured URL" errors:

1. Ensure your backend service is running
2. Verify your Android device is on the same network as your development machine
3. Check for any firewalls or network restrictions
4. Try setting the custom IP address as described above

## Handling Network Changes

The payment system includes automatic fallback mechanisms:

1. It first tries the configured URL (local or production)
2. If that fails, it tries reaching the production URL
3. If all connectivity fails but the device has internet, it proceeds anyway
4. As a last resort, it falls back to mock data mode

## Emulator vs. Physical Device

- **Emulator**: Uses `10.0.2.2` as special localhost address
- **Physical Device**: Must be configured with your development machine's actual IP address

The system uses multiple checks to determine if running on an emulator:
- Environment variables check
- Operating system version check
- Processor count check

## Mock Data Mode

For testing without a backend connection:

```dart
// Enable mock data mode
PaymentApiService().useMockData = true;
```

This allows testing the complete payment flow with simulated backend responses.

## Debugging Tips

### Logs to Monitor

1. **Connection Status**: Look for "Successfully connected" or "Failed to reach" messages
2. **API Calls**: Monitor "Order creation successful" and "Payment verification successful"
3. **Errors**: Check for logs starting with "❌" which indicate problems

### Common Issues

1. **"No network connectivity"**: Device can't access the internet
2. **"Failed to reach configured URL"**: Wrong IP address or backend not running
3. **"Authentication required"**: Invalid or expired authentication token
4. **"Cannot connect to payment server"**: Backend connectivity issue

## Razorpay Integration

### Key Points

1. The order ID must be included in the Razorpay options for proper verification
2. Test mode uses the Razorpay test key: `rzp_test_1DP5mmOlF5G5ag`
3. Successful payments trigger verification with the backend
4. All payment events are logged for debugging

### Testing Card Details

| Card Network | Number           | Result  |
|-------------|------------------|---------|
| Visa        | 4111 1111 1111 1111 | Success |
| Mastercard  | 5267 3181 8797 5449 | Success |
| Visa        | 4000 0000 0000 0002 | Failure |

Use any future expiry date, any 3-digit CVV, and any name.

## Detailed Payment Flow

1. App checks connectivity with payment backend
2. App creates order with backend via `createOrder` API call
3. Razorpay SDK is initialized with order details
4. User completes payment in Razorpay UI
5. Payment success/failure callback is received
6. App verifies payment with backend via `verifyPayment` API call
7. User is shown success/failure UI based on verification result

## Troubleshooting Checklist

- [ ] Backend service is running and accessible
- [ ] Device has internet connectivity
- [ ] Correct IP address is configured for physical device
- [ ] Authentication token is valid
- [ ] API endpoints match between app and backend
- [ ] Razorpay test credentials are valid
- [ ] Order creation succeeds before launching Razorpay
- [ ] Payment verification succeeds after Razorpay callback
