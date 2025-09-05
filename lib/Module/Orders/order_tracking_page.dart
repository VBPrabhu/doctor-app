import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppServices/shiprocket_service.dart';
import 'package:doctorapp/Module/Orders/order_cancellation_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;
  
  const OrderTrackingPage({
    Key? key, 
    required this.orderId,
  }) : super(key: key);

  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  // Order data
  late Map<String, dynamic> orderDetails;
  
  // Current step in the order process
  int currentStep = 2;
  
  // ShipRocket tracking info
  String? trackingId;
  String? courierName;
  bool isLoading = true;
  Map<String, dynamic>? shipmentDetails;
  
  @override
  void initState() {
    super.initState();
    _initializeOrderDetails();
    _fetchShipmentDetails();
  }
  
  Future<void> _fetchShipmentDetails() async {
    // Initialize ShipRocket service
    bool initialized = await ShipRocketService.initialize();
    
    if (initialized) {
      // Use mock AWB code for now - in real app, this would come from backend
      String mockAwb = 'SR${widget.orderId.replaceAll("ORDER-", "")}'; 
      
      try {
        final trackingDetails = await ShipRocketService.trackShipment(mockAwb);
        
        if (trackingDetails != null) {
          setState(() {
            shipmentDetails = trackingDetails;
            trackingId = mockAwb;
            courierName = trackingDetails['courier_name'] ?? 'Express Delivery';
            isLoading = false;
            
            // Update timeline based on shipment status if available
            if (trackingDetails['tracking_data'] != null && 
                trackingDetails['tracking_data']['shipment_track'] != null) {
              var trackData = trackingDetails['tracking_data']['shipment_track'];
              var status = trackData['current_status']?.toLowerCase() ?? '';
              
              if (status.contains('delivered')) {
                orderDetails['status'] = 'Delivered';
                currentStep = 4;
              } else if (status.contains('out for delivery')) {
                orderDetails['status'] = 'Out for Delivery';
                currentStep = 3;
              }
            }
          });
        } else {
          setState(() => isLoading = false);
        }
      } catch (e) {
        print('Error fetching shipment details: $e');
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }
  
  void _initializeOrderDetails() {
    // Initialize with local data - in a real app, this would come from an API
    orderDetails = {
      'id': widget.orderId,
      'status': 'In Transit',
      'date': '${DateTime.now().day} Jul ${DateTime.now().year}',
      'total': 2599.00,
      'items': [
        {
          'name': 'Hanan Serum',
          'quantity': 2,
          'price': 999.00,
          'image': 'assets/Images/faceLotion.png',
        },
        {
          'name': 'Face Moisturizer',
          'quantity': 1,
          'price': 599.00,
          'image': 'assets/Images/faceLotion.png',
        }
      ],
      'shipping_address': {
        'name': 'Venkat Raman',
        'address': '123 Main Street, Apartment 4B',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'pincode': '400001',
        'phone': '+91 98765 43210',
      },
      'payment_method': 'UPI Payment',
      'tracking_info': {
        'courier': courierName ?? 'Express Delivery',
        'tracking_id': trackingId ?? 'SR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'estimated_delivery': _getEstimatedDeliveryDate(),
      },
      'timeline': [
        {
          'status': 'Order Placed',
          'date': '${DateTime.now().subtract(const Duration(days: 2)).day} Jul ${DateTime.now().year}',
          'time': '10:30 AM',
          'description': 'Your order has been placed successfully.',
          'completed': true,
        },
        {
          'status': 'Order Confirmed',
          'date': '${DateTime.now().subtract(const Duration(days: 1)).day} Jul ${DateTime.now().year}',
          'time': '9:15 AM',
          'description': 'Your order has been confirmed and is being processed.',
          'completed': true,
        },
        {
          'status': 'Shipped',
          'date': '${DateTime.now().day} Jul ${DateTime.now().year}',
          'time': '11:45 AM',
          'description': 'Your order has been shipped with Express Delivery.',
          'completed': true,
        },
        {
          'status': 'Out for Delivery',
          'date': 'Expected ${DateTime.now().add(const Duration(days: 1)).day} Jul ${DateTime.now().year}',
          'time': 'By 6:00 PM',
          'description': 'Your order will be out for delivery soon.',
          'completed': false,
        },
        {
          'status': 'Delivered',
          'date': 'Expected ${DateTime.now().add(const Duration(days: 2)).day} Jul ${DateTime.now().year}',
          'time': 'By 8:00 PM',
          'description': 'Estimated time of delivery.',
          'completed': false,
        },
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          'Order Tracking',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderStatusCard(),
              const SizedBox(height: 20),
              _buildTrackingTimeline(),
              const SizedBox(height: 20),
              _buildOrderDetailsCard(),
              const SizedBox(height: 20),
              _buildShippingDetailsCard(),
              const SizedBox(height: 20),
              _buildOrderItemsCard(),
              const SizedBox(height: 20),
              _buildCancelButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID: #${orderDetails['id']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Placed on ${orderDetails['date']}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  orderDetails['status'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.local_shipping, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Expected delivery by ${orderDetails['tracking_info']['estimated_delivery']}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch(orderDetails['status']) {
      case 'Ordered':
        return Colors.blue;
      case 'Processing':
        return Colors.orange;
      case 'In Transit':
        return Colors.purple;
      case 'Out for Delivery':
        return Colors.indigo;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTrackingTimeline() {
    final timeline = orderDetails['timeline'] as List;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Timeline',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < timeline.length; i++)
            _buildTimelineStep(timeline[i], i == timeline.length - 1),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(Map<String, dynamic> step, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: step['completed'] ? Colors.green : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(
                  color: step['completed'] ? Colors.green.shade700 : Colors.grey,
                  width: 2,
                ),
              ),
              child: step['completed'] 
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: step['completed'] ? Colors.green : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['status'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: step['completed'] ? Colors.black : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${step['date']} | ${step['time']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: step['completed'] ? Colors.grey.shade800 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailsRow('Order ID:', '#${orderDetails['id']}'),
          _buildDetailsRow('Order Date:', orderDetails['date']),
          _buildDetailsRow('Order Status:', orderDetails['status']),
          _buildDetailsRow('Payment Method:', orderDetails['payment_method']),
          _buildDetailsRow('Order Total:', '₹${orderDetails['total'].toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildShippingDetailsCard() {
    final address = orderDetails['shipping_address'] as Map<String, dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            address['name'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(address['address']),
          Text('${address['city']}, ${address['state']} - ${address['pincode']}'),
          const SizedBox(height: 4),
          Text('Phone: ${address['phone']}'),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.local_shipping, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderDetails['tracking_info']['courier'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tracking ID: ${orderDetails['tracking_info']['tracking_id']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _openShipRocketTracking(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.track_changes),
                SizedBox(width: 8),
                Text('Track Live Location'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    final items = orderDetails['items'] as List;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Items in your Order',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _buildOrderItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item['image'].toString().replaceFirst('assets/', ''), // Fixed image path
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${item['quantity']}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item['price'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    // Only show cancel button if order is not delivered or cancelled
    if (orderDetails['status'] == 'Delivered' || 
        orderDetails['status'] == 'Cancelled') {
      return const SizedBox.shrink();
    }
    
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderCancellationPage(
                orderId: widget.orderId,
              ),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Cancel Order',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  String _getEstimatedDeliveryDate() {
    final now = DateTime.now();
    final delivery = now.add(const Duration(days: 3));
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${delivery.day} ${months[delivery.month - 1]} ${delivery.year}';
  }
  
  // Open ShipRocket tracking in a browser
  void _openShipRocketTracking() async {
    final trackingId = orderDetails['tracking_info']['tracking_id'];
    final url = ShipRocketService.getTrackingUrl(trackingId);
    
    try {
      // Use url_launcher to open the tracking URL
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open tracking website')),
        );
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open tracking website')),
      );
    }
  }
}
