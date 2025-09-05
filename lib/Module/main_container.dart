import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/Module/Cart/cart_screen.dart';
import 'package:doctorapp/Module/Home/home_screen.dart';
import 'package:doctorapp/Module/Profile/profile_screen.dart';
import 'package:doctorapp/Module/Categories/categories_screen.dart';
import 'package:doctorapp/Module/Orders/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controller for MainContainer to control tab selection from anywhere
class MainContainerController extends GetxController {
  static MainContainerController get to => Get.find();
  
  // Observable for currently selected tab index
  final _selectedIndex = 0.obs;
  
  // Getter for current index
  int get selectedIndex => _selectedIndex.value;
  
  // Method to change tab index
  void changeTabIndex(int index) {
    _selectedIndex.value = index;
  }
}

class MainContainer extends StatefulWidget {
  final int initialTabIndex;
  
  const MainContainer({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  // Use the controller
  final MainContainerController controller = Get.put(MainContainerController());

  final List<Widget> _pages = const [
    HomeScreen(),
    CategoriesScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Set the initial tab from widget parameter
    if (widget.initialTabIndex != 0) {
      controller.changeTabIndex(widget.initialTabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      body: Obx(() => _pages[controller.selectedIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: Obx(() { 
            return BottomNavigationBar(
            currentIndex: controller.selectedIndex,
            onTap: (index) {
              controller.changeTabIndex(index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.primaryColor,
            selectedItemColor: Colors.black87,
            unselectedItemColor: Colors.black54,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category_outlined),
                activeIcon: Icon(Icons.category),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping_outlined),
                activeIcon: Icon(Icons.local_shipping),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
          })
        ),
      ),
    );
  }
}
