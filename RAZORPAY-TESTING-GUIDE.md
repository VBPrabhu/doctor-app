# End-to-End Razorpay Payment Flow Testing Guide

This document provides step-by-step instructions for testing the Razorpay payment integration in the Doctor App.

## Prerequisites

1. **Environment Setup**:
   - Flutter app is installed and running
   - Backend API server is running and accessible
   - Razorpay test mode is enabled in backend configuration
   - Valid Razorpay test API keys are configured

2. **Test Accounts**:
   - A user account in the app for testing
   - Razorpay test credentials for simulating payments

## Test Scenarios

### 1. Basic Payment Flow

**Steps to Test**:

1. Launch the app and login
2. Add products to cart
3. Navigate to checkout page
4. Fill in delivery details
5. Select Razorpay as payment method
6. Click "Place Order" button
7. Verify loading dialog appears
8. Verify Razorpay checkout screen loads properly
9. Use Razorpay test card details:
   - Card Number: 4111 1111 1111 1111
   - Expiry: Any future date (MM/YY)
   - CVV: Any 3 digits (e.g., 123)
   - Name: Any name
10. Complete payment
11. Verify success callback is triggered
12. Confirm navigation to Order Success page
13. Verify order details on success page

**Expected Results**:
- Payment processing is smooth with no errors
- Backend creates and tracks the order correctly
- Order ID appears on success page
- Payment status is correctly recorded

### 2. Error Handling Tests

#### Network Error Test
1. Enable airplane mode on device
2. Attempt payment process
3. Verify appropriate error message

**Expected Result**: App displays connectivity error message

#### Payment Cancellation Test
1. Start payment process
2. Click "Back" or "Cancel" in Razorpay UI
3. Verify app handles cancellation gracefully

**Expected Result**: User returns to checkout page with error message about cancelled payment

#### Backend API Failure Test
1. Temporarily disable backend API (if possible)
2. Attempt payment process
3. Verify error handling

**Expected Result**: Appropriate error message shown about server issues

### 3. Backend Verification

After successful test payments:

1. Check backend logs for:
   - Order creation records
   - Payment verification calls
   - Webhook processing (if implemented)

2. Verify database entries:
   - Order records with correct status
   - Payment records linked to orders
   - Customer details properly recorded

## Razorpay Test Cards

| Card Network | Number           | Result  |
|--------------|------------------|---------|
| Visa         | 4111 1111 1111 1111 | Success |
| Mastercard   | 5267 3181 8797 5449 | Success |
| Visa         | 4000 0000 0000 0002 | Failure |

## Test Environment Variables

Ensure these environment variables are set correctly for testing:

- `RAZORPAY_KEY_ID`: Test key ID from Razorpay dashboard
- `RAZORPAY_SECRET_KEY`: Test secret key from Razorpay dashboard
- `PAYMENT_API_BASE_URL`: URL of the payment service backend

## Troubleshooting Common Issues

1. **Payment Not Processing**:
   - Check Razorpay credentials in backend
   - Verify network connectivity
   - Examine backend logs for errors

2. **Verification Failing**:
   - Check signature verification logic
   - Ensure webhook secret is correct
   - Verify order ID formats match between app and backend

3. **Navigation Issues**:
   - Check for proper context usage in Flutter callbacks
   - Verify state management during payment flow

## Regression Testing Checklist

- [ ] Place order with Razorpay payment
- [ ] Verify payment success flow
- [ ] Test payment failure handling
- [ ] Check order history after payment
- [ ] Verify payment details in user account
- [ ] Test on multiple devices (iOS and Android)

---

For any questions or issues, please contact the development team.
