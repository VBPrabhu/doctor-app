import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:doctorapp/AppCommon/app_images.dart';
import 'package:get/get.dart';
import 'package:doctorapp/Module/DevTools/dev_tools_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
                'My Profile',
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
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildSectionTitle('Account Information'),
          _buildAccountItems(),
          const SizedBox(height: 24),
          _buildSectionTitle('Orders'),
          _buildOrderItems(),
          const SizedBox(height: 24),
          _buildSectionTitle('Preferences'),
          _buildPreferenceItems(),
          const SizedBox(height: 24),
          _buildLogoutButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primaryColor,
          child: Icon(
            Icons.person,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Jessica Smith',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'jessica.smith@example.com',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem('5', 'Orders'),
            _buildDivider(),
            _buildStatItem('3', 'Pending'),
            _buildDivider(),
            _buildStatItem('8', 'Wishlist'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAccountItems() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildListTile(
            'Personal Information',
            Icons.person_outline,
            () {},
          ),
          const Divider(height: 1),
          _buildListTile(
            'Shipping Addresses',
            Icons.location_on_outlined,
            () {},
          ),
          const Divider(height: 1),
          _buildListTile(
            'Payment Methods',
            Icons.credit_card_outlined,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildListTile(
            'Order History',
            Icons.receipt_long_outlined,
            () {},
          ),
          const Divider(height: 1),
          _buildListTile(
            'Pending Reviews',
            Icons.rate_review_outlined,
            () {},
          ),
          const Divider(height: 1),
          _buildListTile(
            'Returns & Refunds',
            Icons.assignment_return_outlined,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItems() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildListTile(
            'Notifications',
            Icons.notifications_outlined,
            () {},
          ),
          const Divider(height: 1),
          _buildListTile(
            'Language',
            Icons.language_outlined,
            () {},
          ),
          const Divider(height: 1),
          _buildListTile(
            'Help Center',
            Icons.help_outline,
            () {},
          ),
          const Divider(height: 1),
          _buildListTile(
            'Developer Tools',
            Icons.developer_mode,
            () => Get.to(() => const DevToolsPage()),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.fontColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Logout',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
