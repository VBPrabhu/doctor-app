import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/Module/Home/home_screen.dart';
import 'package:doctorapp/Module/Orders/order_tracking_page.dart';
import 'package:flutter/material.dart';

class OrderSuccessPage extends StatelessWidget {
  final String orderId;
  final double totalAmount;

  const OrderSuccessPage({
    Key? key,
    required this.orderId,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success animation (using a simple container for now)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Success message
                      const Text(
                        'Order Placed Successfully!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        'Your order #$orderId has been confirmed and will be shipped soon.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Order details
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildOrderDetailRow(
                              'Order ID',
                              '#$orderId',
                              boldValue: true,
                            ),
                            const SizedBox(height: 12),
                            _buildOrderDetailRow(
                              'Order Date',
                              _getCurrentDate(),
                            ),
                            const SizedBox(height: 12),
                            _buildOrderDetailRow(
                              'Order Amount',
                              '₹${totalAmount.toStringAsFixed(2)}',
                              boldValue: true,
                            ),
                            const SizedBox(height: 12),
                            _buildOrderDetailRow(
                              'Payment Method',
                              'Online Payment',
                            ),
                            const SizedBox(height: 12),
                            _buildOrderDetailRow(
                              'Estimated Delivery',
                              _getEstimatedDeliveryDate(),
                              boldValue: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Track order button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderTrackingPage(
                                  orderId: orderId,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Track Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Continue shopping button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            // Navigate back to home screen, clearing the stack
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: BorderSide(color: AppColors.primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Continue Shopping',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer with customer support info
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  Text(
                    'Need help with your order?',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      // Contact customer support
                    },
                    child: Text(
                      'Contact Customer Support',
                      style: TextStyle(
                        color: AppColors.fontColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value, {bool boldValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: boldValue ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }

  String _getEstimatedDeliveryDate() {
    final now = DateTime.now();
    final delivery = now.add(const Duration(days: 5));
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${delivery.day} ${months[delivery.month - 1]}, ${delivery.year}';
  }
}
