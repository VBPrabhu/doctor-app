import 'package:get/get.dart';

/// Service to temporarily store cart data during authentication flow
class CartDataService extends GetxService {
  // Cart items storage
  final Rx<List<Map<String, dynamic>>> _cartItems = Rx<List<Map<String, dynamic>>>([]);
  // Cart values
  final RxDouble _subtotal = 0.0.obs;
  final RxDouble _shippingFee = 0.0.obs;
  final RxDouble _discount = 0.0.obs;
  final RxDouble _total = 0.0.obs;
  
  CartDataService() {
    // Initialize with dummy data for testing
    _initWithDummyData();
  }
  
  // Getters for the cart data
  List<Map<String, dynamic>> get cartItems => _cartItems.value;
  double get subtotal => _subtotal.value;
  double get shippingFee => _shippingFee.value;
  double get discount => _discount.value;
  double get total => _total.value;
  
  // Set cart data for temporary storage during authentication flow
  void setCartData({
    required List<Map<String, dynamic>> cartItems,
    required double subtotal,
    required double shippingFee,
    required double discount,
    required double total,
  }) {
    _cartItems.value = List.from(cartItems);
    _subtotal.value = subtotal;
    _shippingFee.value = shippingFee;
    _discount.value = discount;
    _total.value = total;
  }
  
  // Clear cart data
  void clearCartData() {
    _cartItems.value = [];
    _subtotal.value = 0.0;
    _shippingFee.value = 0.0;
    _discount.value = 0.0;
    _total.value = 0.0;
  }
  
  // Check if cart has data
  bool hasCartData() {
    return _cartItems.value.isNotEmpty;
  }
  
  // Initialize with dummy data for testing purposes
  void _initWithDummyData() {
    // Sample product data - matches checkout_page.dart expected structure
    final List<Map<String, dynamic>> dummyCartItems = [
      {
        'product': {
          'name': 'Medicine Pack',
          'price': 499.99,
          'image': 'assets/Images/medicine_icon.png',
        },
        'quantity': 2,
      },
      {
        'product': {
          'name': 'Beauty Cream',
          'price': 399.99,
          'image': 'assets/Images/faceLotion.png',
        },
        'quantity': 1,
      },
      {
        'product': {
          'name': 'Organic Cream',
          'price': 599.00,
          'image': 'assets/Images/faceLotion.png',
        },
        'quantity': 1,
      },
    ];
    
    // Calculate subtotal
    double subtotal = 0.0;
    for (var item in dummyCartItems) {
      final product = item['product'];
      final quantity = item['quantity'];
      subtotal += (product['price'] as double) * (quantity as int);
    }
    
    // Set values
    _cartItems.value = List.from(dummyCartItems);
    _subtotal.value = subtotal;
    _shippingFee.value = 50.0; // Fixed shipping fee
    _discount.value = 100.0; // Sample discount
    _total.value = subtotal + _shippingFee.value - _discount.value;
    
    print('CartDataService initialized with dummy data: ${_cartItems.value.length} items, total: ${_total.value}');
  }
}
