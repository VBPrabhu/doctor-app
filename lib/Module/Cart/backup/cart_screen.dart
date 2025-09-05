import 'package:flutter/material.dart';
import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> products = [
    {
      'name': 'Red Rose Cream',
      'quantity': 1,
      'price': 4.99,
      'image': AppImages.faceLotion,
    },
    {
      'name': 'Beauty Cream',
      'quantity': 1,
      'price': 1.99,
      'image': AppImages.faceLotion,
    },
    {
      'name': 'Organic Cream',
      'quantity': 1,
      'price': 3.00,
      'image': AppImages.faceLotion,
    },
    {
      'name': 'Sunscreen',
      'quantity': 1,
      'price': 2.99,
      'image': AppImages.faceLotion,
    },
  ];

  @override
  Widget build(BuildContext context) {

    double subtotal = 2039.0;
    double tax = 0.0;
    double netTotal = subtotal + tax;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Row(
          children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'My Cart',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.black87),
              onPressed: () {},
            ),
          ],
        ),
      body: Column(
        children: [
          20.toHeight(),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          product['image'],
                          width: context.screenWidth * .20,
                          height: context.screenWidth * .20,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product['name'],
                                    style: AppTextStyle.s18.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // Delete functionality
                                    setState(() {
                                      products.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.clear,
                                      color: Color(0xffB3B3B3),
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${product['quantity']} pcs, Price',
                              style: AppTextStyle.s14.copyWith(
                                color: AppColors.darkGrey
                              ),
                            ),
                    
                    
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (product['quantity'] > 1) product['quantity']--;
                                          });
                                        },
                                        child: Container(
                                          height: 32,
                                          width: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor.withOpacity(0.2),
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              bottomLeft: Radius.circular(8),
                                            ),
                                          ),
                                          child: const Icon(Icons.remove, color: Colors.black, size: 16),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 36,
                                        child: Center(
                                          child: Text(
                                            product['quantity'].toString(),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            product['quantity']++;
                                          });
                                        },
                                        child: Container(
                                          height: 32,
                                          width: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor,
                                            borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                            ),
                                          ),
                                          child: const Icon(Icons.add, color: Colors.black, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '₹${(product['price'] * product['quantity']).toStringAsFixed(2)}',
                                  style: AppTextStyle.s18.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.fontColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),


                    ],
                  ),
                );
                },
              ),
            ),

          const Spacer(),
          totalView(
            netTotal: netTotal,
            subtotal: subtotal,
            tax: tax,
          ),

          10.toHeight(),

          Container(
            width: double.infinity,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'PROCEED TO CHECKOUT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          20.toHeight(),
        ],
      ).toHorizontalPadding(horizontalPadding: 16),
    );


  }


  Widget totalView({
    required double subtotal,
    required double tax,
    required double netTotal,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, -1),
        ),
      ],
    ),
    padding: const EdgeInsets.all(20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub Total
        Row(
          children: [
            Text(
              'Sub Total',
              style: AppTextStyle.s14.copyWith(
                fontSize: 16,
                color: Colors.grey.shade700,
              )
            ),
            const Spacer(),
            Text(
              '₹$subtotal',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: Colors.grey.shade200, height: 1),
        ),
        Row(
          children: [
            Text(
              'Tax',
              style: AppTextStyle.s14.copyWith(
                fontSize: 16,
                color: Colors.grey.shade700,
              )
            ),
            const Spacer(),
            Text(
              '₹$tax',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: Colors.grey.shade200, height: 1),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                'Net Total',
                style: AppTextStyle.s18.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                )
              ),
              const Spacer(),
              Text(
                '₹$netTotal',
                style: AppTextStyle.s18.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.fontColor,
                )
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
