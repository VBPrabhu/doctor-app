import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:flutter/material.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;
  
  const CategoryProductsScreen({
    Key? key,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample products data - in a real app, this would come from an API or database
    final List<Map<String, dynamic>> products = getProductsByCategory(categoryName);
    
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          categoryName,
          style: const TextStyle(
            color: Color(0xFF800020),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '$categoryName Products',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Text(
                      'No products available in this category',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(context, product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                Image.asset(
                  product['image'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                if (product['discount'] != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${product['discount']}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Rating
                    if (product['rating'] != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${product['rating']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    const Spacer(),
                    // Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${product['price']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> getProductsByCategory(String categoryName) {
    // Sample product data - in a real app, this would come from an API
    switch (categoryName) {
      case 'Skincare':
        return [
          {
            'name': 'Hanan Serum',
            'price': 29.99,
            'discount': 40,
            'rating': 4.8,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Collagen Cream',
            'price': 34.99,
            'discount': 30,
            'rating': 4.7,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Rose Face Cream',
            'price': 19.99,
            'rating': 4.8,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Night Cream',
            'price': 34.99,
            'rating': 4.9,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Hyaluronic Acid',
            'price': 22.99,
            'rating': 4.6,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Vitamin C Serum',
            'price': 24.99,
            'rating': 4.7,
            'image': AppImages.faceLotion,
          },
        ];
      case 'Makeup':
        return [
          {
            'name': 'Foundation',
            'price': 25.99,
            'rating': 4.5,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Lipstick',
            'price': 15.99,
            'discount': 20,
            'rating': 4.7,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Eyeshadow Palette',
            'price': 29.99,
            'rating': 4.8,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Mascara',
            'price': 18.99,
            'rating': 4.6,
            'image': AppImages.faceLotion,
          },
        ];
      case 'Hair':
        return [
          {
            'name': 'Shampoo',
            'price': 19.99,
            'rating': 4.7,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Conditioner',
            'price': 19.99,
            'rating': 4.6,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Hair Serum',
            'price': 24.99,
            'discount': 15,
            'rating': 4.8,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Hair Oil',
            'price': 16.99,
            'rating': 4.9,
            'image': AppImages.faceLotion,
          },
        ];
      case 'Body':
        return [
          {
            'name': 'Body Lotion',
            'price': 18.99,
            'rating': 4.5,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Body Scrub',
            'price': 22.99,
            'discount': 25,
            'rating': 4.7,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Body Wash',
            'price': 15.99,
            'rating': 4.6,
            'image': AppImages.faceLotion,
          },
        ];
      case 'Fragrance':
        return [
          {
            'name': 'Perfume',
            'price': 39.99,
            'rating': 4.8,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Body Mist',
            'price': 19.99,
            'discount': 20,
            'rating': 4.6,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Cologne',
            'price': 34.99,
            'rating': 4.7,
            'image': AppImages.faceLotion,
          },
        ];
      default:
        return [
          {
            'name': 'Brushes Set',
            'price': 29.99,
            'rating': 4.7,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Beauty Sponge',
            'price': 14.99,
            'discount': 10,
            'rating': 4.6,
            'image': AppImages.faceLotion,
          },
          {
            'name': 'Makeup Bag',
            'price': 19.99,
            'rating': 4.5,
            'image': AppImages.faceLotion,
          },
        ];
    }
  }
}
