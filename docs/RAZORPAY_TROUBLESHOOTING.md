# Razorpay Integration Troubleshooting Guide

This document provides solutions for common issues with Razorpay integration in Flutter Android apps.

## Common "Something Went Wrong" Errors

The generic "Uh! oh! Something went wrong" message from Razorpay can be caused by:

### 1. Order ID Format Issues
- **Symptom**: Blank checkout page or error screen appears
- **Solution**:
  - Ensure order_id starts with `order_`
  - Keep order_id reasonably short
  - Avoid special characters in order_id

### 2. Razorpay Options Formatting
- **Symptom**: Checkout loads but fails to process payment
- **Solution**:
  - Format `amount` as a string, not integer
  - Place required parameters (`key`, `amount`, `order_id`) first
  - Include only necessary fields
  - Properly format nested objects (prefill, theme)
  - Remove any null values from options

### 3. API Key Issues
- **Symptom**: Authentication error in Razorpay checkout
- **Solution**: 
  - Ensure consistent key usage (test vs. live)
  - The key used must match the one associated with the order
  - For testing, use `rzp_test_1DP5mmOlF5G5ag` consistently

### 4. WebView Configuration
- **Symptom**: Canvas rendering issues, Chrome warnings
- **Solution**:
  - Enable DOM storage in WebView
  - Set the `willReadFrequently` attribute for Canvas2D contexts
  - Add proper JavaScript communication channels

## Debug Process

1. **Enable Verbose Logging**:
   - Check console for specific error messages
   - Look for order_id, key, or amount format issues

2. **Use Mock Data Fallback**:
   - Test with consistent mock data format
   - Verify the format matches exactly what Razorpay expects

3. **Verify API Communication**:
   - Confirm authentication token validity
   - Check network connectivity and URL configuration
   - Verify backend order creation endpoint is accessible

4. **Test with Known Working Values**:
   - Test with simple, known-good values before customizing
   - Use Razorpay test mode credentials

## Common Error Codes

| Error Code | Description | Solution |
|------------|-------------|----------|
| BAD_REQUEST_ERROR | Invalid parameters | Check order_id format, amount format |
| NETWORK_ERROR | Network connectivity issues | Check internet connection, API URLs |
| EXTERNAL_WALLET_SELECTED | User selected external wallet | Handle as a separate flow |
| PAYMENT_CANCELED | User canceled payment | Normal user action, handle gracefully |
| AUTHENTICATION_ERROR | Invalid key or auth token | Check key ID matches order |

## Testing Tips

- Use Razorpay test mode with test credentials
- Test on both emulator and physical devices
- Verify backend connectivity before testing payments
- Check logs from both app and WebView for errors
