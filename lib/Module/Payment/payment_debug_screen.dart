import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:doctorapp/AppServices/payment_debug_helper.dart';

/// A debug screen to test and diagnose payment flow issues
class PaymentDebugScreen extends StatefulWidget {
  const PaymentDebugScreen({Key? key}) : super(key: key);

  @override
  _PaymentDebugScreenState createState() => _PaymentDebugScreenState();
}

class _PaymentDebugScreenState extends State<PaymentDebugScreen> {
  final PaymentDebugHelper _debugHelper = PaymentDebugHelper();
  
  bool _isLoading = false;
  String _statusText = '';
  Map<String, dynamic>? _lastResults;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Debugging'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showEnvironmentInfo,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Payment Flow Diagnostic Tools',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Test buttons
            _buildTestButton(
              'Test Backend Connectivity',
              'Checks if your backend server is reachable',
              _testBackendConnectivity,
              Icons.network_check,
            ),
            
            _buildTestButton(
              'Test Order Creation',
              'Creates a test order with minimum amount (₹1)',
              _testOrderCreation,
              Icons.shopping_cart,
            ),
            
            const SizedBox(height: 20),
            
            // Status area
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
              
            if (_statusText.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_statusText),
              ),
              
            const SizedBox(height: 20),
            
            // Results area
            if (_lastResults != null) ...[
              const Text(
                'Test Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildResultsCard(_lastResults!),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestButton(
    String title, 
    String subtitle, 
    VoidCallback onPressed,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
        onTap: _isLoading ? null : onPressed,
      ),
    );
  }
  
  Widget _buildResultsCard(Map<String, dynamic> results) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              results['success'] == true ? 'Success' : 'Error',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: results['success'] == true ? Colors.green : Colors.red,
              ),
            ),
            const Divider(),
            
            // Conditionally show different result types
            if (results.containsKey('error'))
              Text('Error: ${results['error']}', style: const TextStyle(color: Colors.red)),
              
            if (results.containsKey('tests'))
              _buildTestResultsList(results['tests']),
              
            if (results.containsKey('orderData'))
              _buildOrderDataSection(results['orderData'], results['isMockData'] ?? false),
              
            const SizedBox(height: 12),
            
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _lastResults = null;
                  });
                },
                child: const Text('CLEAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestResultsList(List<dynamic> tests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Connectivity Tests:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...tests.map((test) {
          final bool success = test['success'] ?? false;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error_outline,
                  color: success ? Colors.green : Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(test['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                      if (test['error'] != null)
                        Text(
                          test['error'],
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      if (test['details'] != null && test['details'].toString().isNotEmpty)
                        Text(
                          test['details'].toString(),
                          style: TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildOrderDataSection(Map<String, dynamic> orderData, bool isMock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Order Details:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            if (isMock)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amber[700]!),
                ),
                child: const Text('MOCK DATA', style: TextStyle(fontSize: 10, color: Colors.black87)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...orderData.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text('${entry.key}:', style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value?.toString() ?? 'null',
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        
        if (orderData.containsKey('orderId') && !orderData['orderId'].toString().startsWith('order_'))
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red[300]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Invalid order ID format! Razorpay requires IDs to start with "order_"',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Future<void> _testBackendConnectivity() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Testing backend connectivity...';
    });
    
    try {
      final results = await _debugHelper.testBackendConnectivity();
      setState(() {
        _lastResults = results;
        _statusText = 'Connectivity test completed';
      });
    } catch (e) {
      setState(() {
        _lastResults = {
          'success': false,
          'error': e.toString(),
        };
        _statusText = 'Error testing connectivity';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _testOrderCreation() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Creating test order...';
    });
    
    try {
      final results = await _debugHelper.testPaymentOrderCreation();
      setState(() {
        _lastResults = results;
        _statusText = results['success'] 
            ? 'Order created successfully'
            : 'Failed to create order';
      });
    } catch (e) {
      setState(() {
        _lastResults = {
          'success': false,
          'error': e.toString(),
        };
        _statusText = 'Error creating test order';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _showEnvironmentInfo() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Getting environment info...';
    });
    
    try {
      final info = await _debugHelper.getEnvironmentInfo();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Environment Info'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoSection('Platform', {
                  'OS': info['platform'],
                  'Version': info['version'],
                  'Android': info['isAndroid'].toString(),
                  'iOS': info['isIOS'].toString(),
                }),
                const Divider(),
                _buildInfoSection('Network', {
                  'API Base URL': info['apiBaseUrl'],
                }),
                const Divider(),
                const Text('Network Interfaces:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...List.generate(info['networkInterfaces']?.length ?? 0, (index) {
                  final interface = info['networkInterfaces'][index];
                  final addresses = interface['addresses'] as List;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${interface['name']}:', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ...addresses.map((addr) => Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 2),
                          child: Text('${addr['address']} (${addr['type']})'),
                        )).toList(),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CLOSE'),
            ),
          ],
        ),
      );
      
      setState(() {
        _statusText = 'Environment info loaded';
      });
    } catch (e) {
      setState(() {
        _statusText = 'Error getting environment info: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Widget _buildInfoSection(String title, Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...data.entries.map((e) => Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 4),
          child: Row(
            children: [
              Text('${e.key}: ', style: const TextStyle(fontWeight: FontWeight.w500)),
              Expanded(child: Text(e.value)),
            ],
          ),
        )).toList(),
      ],
    );
  }
}
