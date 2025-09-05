# Authentication Implementation Guide

This document describes the authentication flow implemented between the Flutter mobile app and the backend services.

## Architecture Overview

The authentication system uses JWT (JSON Web Tokens) for secure communication between the mobile app and backend services. Key components include:

1. **AuthService** - Manages authentication state and tokens
2. **PaymentApiService** - Uses AuthService to authenticate API calls
3. **Backend Security** - Spring Security with OAuth2 Resource Server and tenant context management

## Mobile App Implementation

### AuthService (auth_service.dart)

The `AuthService` class is responsible for:

- Managing login state
- Storing and retrieving JWT tokens
- Parsing JWT claims (organizationId, branchId, etc.)
- Providing authentication headers for API calls
- Token refresh capabilities

```dart
// Key methods
Future<bool> login(String username, String password)  // Authenticates user and stores JWT
Future<bool> refreshAuthToken()  // Refreshes expired tokens
Map<String, String> getAuthHeaders()  // Returns headers with Bearer token
Future<void> saveTokens(String token, String refreshToken)  // Stores tokens and parses claims
```

### PaymentApiService Integration

The `PaymentApiService` integrates with `AuthService` to:

1. Automatically include authentication headers in all API requests
2. Handle authentication failures with token refresh
3. Fall back to mock data when authentication is not available (for testing)

```dart
// Authentication flow in API calls
if (!_authService.isLoggedIn) {
  // Try to login with test credentials for development
  final bool loginSuccess = await _authService.login('test@lemicare.com', 'password123');
  if (!loginSuccess) {
    throw Exception('Authentication required. Please login first.');
  }
}

// Get auth headers and make authenticated API call
final Map<String, String> headers = _authService.getAuthHeaders();
```

## Backend Implementation

The backend uses Spring Security with JWT validation:

### Security Configuration

- `SecurityConfig` class configures JWT validation and routes
- Uses `TenantFilter` to extract claims from JWT

### Tenant Context Management

- `TenantFilter` extracts claims from JWT: organizationId, branchId, userId
- `TenantContext` stores these in ThreadLocal variables for the request lifecycle
- `SecurityUtils` provides access to these values with validation

### JWT Token Structure

The JWT token contains the following claims:
- `sub`: User ID
- `organizationId`: Organization identifier
- `branchId`: Branch identifier
- `role`: User role (e.g., "PATIENT")
- `exp`: Expiration timestamp

## Testing

The system includes test support:
- Mock JWT generation for testing without a backend
- Automatic retry with token refresh on 401 responses
- Unit tests for authentication flow

## Security Considerations

1. Tokens are stored in SharedPreferences (consider more secure storage in production)
2. Test credentials should be removed in production builds
3. All API endpoints should be secured with HTTPS in production

## Future Improvements

1. Implement secure storage for tokens (e.g., Flutter Secure Storage)
2. Add biometric authentication for token access
3. Implement proper OAuth2 flow with refresh tokens
4. Add token expiration monitoring and preemptive refresh
