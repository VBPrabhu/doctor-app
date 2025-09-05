import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:doctorapp/Module/Categories/category_products_screen.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Row(
          children: [
            // App logo image
            Image.asset(
              AppImages.appLogoPng,
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Categories',
                style: TextStyle(
                  color: Color(0xFF800020), // Deep burgundy color
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoryCard(
            context,
            'Skincare',
            'Cleansers, Moisturizers, Serums, and more',
            Icons.face_retouching_natural,
            Colors.pink.shade100,
          ),
          _buildCategoryCard(
            context,
            'Makeup',
            'Foundation, Lipstick, Eyeshadow, and more',
            Icons.palette,
            Colors.purple.shade100,
          ),
          _buildCategoryCard(
            context,
            'Hair Care',
            'Shampoo, Conditioner, Hair masks, and more',
            Icons.brush,
            Colors.blue.shade100,
          ),
          _buildCategoryCard(
            context,
            'Body Care',
            'Body wash, Lotions, Scrubs, and more',
            Icons.spa,
            Colors.green.shade100,
          ),
          _buildCategoryCard(
            context,
            'Fragrances',
            'Perfumes, Body mists, and more',
            Icons.air,
            Colors.amber.shade100,
          ),
          _buildCategoryCard(
            context,
            'Tools & Accessories',
            'Brushes, Sponges, Bags, and more',
            Icons.precision_manufacturing,
            Colors.orange.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to category products
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryProductsScreen(categoryName: title),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 30, color: Colors.black),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
