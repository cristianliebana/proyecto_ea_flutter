import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:proyecto_flutter/screens/chat.dart';
import 'package:proyecto_flutter/screens/home.dart';
import 'package:proyecto_flutter/screens/profile.dart';
import 'package:proyecto_flutter/screens/shopping_basket.dart';
import 'package:get/get.dart';

class CustomBottomNavigationBarController extends GetxController {
  void updateIndex(int index) {
    switch (index) {
      case 0:
        Get.offAll(HomePage(), transition: Transition.noTransition);
        break;
      case 1:
        Get.offAll(ShoppingBasketPage(), transition: Transition.noTransition);
        break;
      case 2:
        Get.offAll(ChatPage(), transition: Transition.noTransition);
        break;
      case 3:
        Get.offAll(ProfilePage(), transition: Transition.noTransition);
        break;
      default:
        break;
    }
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final CustomBottomNavigationBarController controller =
      Get.put(CustomBottomNavigationBarController());

  final int currentIndex;

  CustomBottomNavigationBar({Key? key, required this.currentIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomBottomNavigationBarController>(
      builder: (controller) {
        return SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 1,
            color: Color(0xFF486D28).withOpacity(0.2),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: GNav(
              rippleColor: Color(0xFF486D28).withOpacity(0.8),
              hoverColor: Color(0xFF486D28).withOpacity(0.8),
              gap: 8,
              activeColor: Color(0xFFFFFCEA),
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              tabBackgroundColor: Color(0xFF486D28),
              color: Color(0xFF486D28),
              tabs: [
                GButton(
                  icon: LineIcons.home,
                  text: "Inicio",
                ),
                GButton(
                  icon: LineIcons.shoppingBasket,
                  text: "Cesta",
                ),
                GButton(
                  icon: LineIcons.comment,
                  text: "Chat",
                ),
                GButton(
                  icon: LineIcons.user,
                  text: "Perfil",
                ),
              ],
              selectedIndex: currentIndex,
              onTabChange: controller.updateIndex,
            ),
          ),
        ]));
      },
    );
  }
}
