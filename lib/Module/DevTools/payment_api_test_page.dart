import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../AppServices/payment_api_test.dart';

class PaymentApiTestPage extends StatefulWidget {
  const PaymentApiTestPage({Key? key}) : super(key: key);

  @override
  State<PaymentApiTestPage> createState() => _PaymentApiTestPageState();
}

class _PaymentApiTestPageState extends State<PaymentApiTestPage> {
  final PaymentApiTest _apiTest = PaymentApiTest();
  Map<String, dynamic>? _createOrderResult;
  Map<String, dynamic>? _verifyPaymentResult;
  bool _isTestingCreateOrder = false;
  bool _isTestingVerifyPayment = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment API Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _createOrderResult = null;
                _verifyPaymentResult = null;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment API Test Tool',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use this page to verify direct API connectivity to the payment backend endpoints without relying on the Razorpay plugin.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // Create Order Test Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Test Create Order API',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: _isTestingCreateOrder ? null : _testCreateOrderApi,
                          child: _isTestingCreateOrder
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Run Test'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Tests connectivity to /api/internal/payments/create-order endpoint'),
                    const SizedBox(height: 16),
                    if (_createOrderResult != null) ...[
                      const Divider(),
                      const Text(
                        'Test Results:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildResultCard(_createOrderResult!),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Verify Payment Test Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Test Verify Payment API',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: _isTestingVerifyPayment ? null : _testVerifyPaymentApi,
                          child: _isTestingVerifyPayment
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Run Test'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Tests connectivity to /api/internal/payments/verify-payment endpoint'),
                    const SizedBox(height: 16),
                    if (_verifyPaymentResult != null) ...[
                      const Divider(),
                      const Text(
                        'Test Results:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildResultCard(_verifyPaymentResult!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testCreateOrderApi() async {
    try {
      setState(() {
        _isTestingCreateOrder = true;
      });
      
      developer.log('🔵 Starting create-order API test', name: 'PaymentAPITest');
      final result = await _apiTest.testCreateOrderConnection();
      developer.log('🔵 Test complete: ${result['success']}', name: 'PaymentAPITest');
      
      setState(() {
        _createOrderResult = result;
        _isTestingCreateOrder = false;
      });
    } catch (e) {
      developer.log('❌ Test error: $e', name: 'PaymentAPITest');
      setState(() {
        _createOrderResult = {
          'success': false,
          'errors': [e.toString()],
          'details': {'error': 'Exception occurred while running test'},
        };
        _isTestingCreateOrder = false;
      });
    }
  }

  Future<void> _testVerifyPaymentApi() async {
    try {
      setState(() {
        _isTestingVerifyPayment = true;
      });
      
      developer.log('🔵 Starting verify-payment API test', name: 'PaymentAPITest');
      final result = await _apiTest.testVerifyPaymentConnection();
      developer.log('🔵 Test complete: ${result['success']}', name: 'PaymentAPITest');
      
      setState(() {
        _verifyPaymentResult = result;
        _isTestingVerifyPayment = false;
      });
    } catch (e) {
      developer.log('❌ Test error: $e', name: 'PaymentAPITest');
      setState(() {
        _verifyPaymentResult = {
          'success': false,
          'errors': [e.toString()],
          'details': {'error': 'Exception occurred while running test'},
        };
        _isTestingVerifyPayment = false;
      });
    }
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final bool success = result['success'] == true;
    
    return Container(
      decoration: BoxDecoration(
        color: success ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: success ? Colors.green.shade300 : Colors.red.shade300,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                success ? 'Success' : 'Failed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: success ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Connectivity info
          if (result.containsKey('connectivity')) ...[
            const Text('Network Connectivity:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Status: ${result['connectivity']['status']}'),
            Text('Type: ${result['connectivity']['type']}'),
            if (result['connectivity'].containsKey('internet'))
              Text('Internet Available: ${result['connectivity']['internet']}'),
            const SizedBox(height: 8),
          ],
          
          // Authentication info
          if (result.containsKey('auth')) ...[
            const Text('Authentication:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Status: ${result['auth']['status']}'),
            if (result['auth'].containsKey('token_length'))
              Text('Token Length: ${result['auth']['token_length']}'),
            if (result['auth'].containsKey('login_attempt'))
              Text('Login Attempt: ${result['auth']['login_attempt']}'),
            const SizedBox(height: 8),
          ],
          
          // Response info
          if (result.containsKey('response')) ...[
            const Text('API Response:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Status Code: ${result['response']['status_code']}'),
            const SizedBox(height: 4),
            const Text('Response Data:'),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              child: Text(
                '${result['response']['data']}',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // Error info
          if ((result['errors'] as List).isNotEmpty) ...[
            const Text('Errors:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            ...List.generate(
              (result['errors'] as List).length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.red)),
                    Expanded(
                      child: Text(
                        '${result['errors'][index]}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // Details
          if (result.containsKey('details') && (result['details'] as Map).isNotEmpty) ...[
            const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...List.generate(
              (result['details'] as Map).entries.length,
              (index) {
                final entry = (result['details'] as Map).entries.elementAt(index);
                return Text('${entry.key}: ${entry.value}');
              },
            ),
          ],
        ],
      ),
    );
  }
}
