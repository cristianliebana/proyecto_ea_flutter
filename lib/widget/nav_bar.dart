import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:proyecto_flutter/screens/chat.dart';
import 'package:proyecto_flutter/screens/create_product.dart';
import 'package:proyecto_flutter/screens/favorites.dart';
import 'package:proyecto_flutter/screens/home.dart';
import 'package:proyecto_flutter/screens/map.dart';
import 'package:proyecto_flutter/screens/profile.dart';
import 'package:get/get.dart';

class CustomBottomNavigationBarController extends GetxController {
  String userId = '';
  final MapPageController mapPageController = Get.find<MapPageController>();

  void updateIndex(int index) {
    switch (index) {
      case 0:
        Get.to(HomePage(), transition: Transition.noTransition);
        break;
      case 1:
        Get.to(const MapPageView(), transition: Transition.noTransition);
        mapPageController.checkAuthAndNavigate();
        mapPageController.loadProducts();
        break;
      case 2:
        Get.to(CreateProduct(), transition: Transition.noTransition);
        break;
      case 3:
        Get.to(ChatPage(), transition: Transition.noTransition);
        break;
      case 4:
        Get.to(FavoritesScreen(), transition: Transition.noTransition);
        break;
      case 5:
        Get.to(ProfilePage(), transition: Transition.noTransition);
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

  CustomBottomNavigationBar({Key? key, required this.currentIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconScale = screenWidth / 480; // Adjusted scale for icons

    // Calculate padding based on screen width
    double horizontalPadding = screenWidth * 0.05; // 5% of screen width

    return GetBuilder<CustomBottomNavigationBarController>(
      builder: (controller) {
        return SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: horizontalPadding), // Adjusted margin
            child: GNav(
              rippleColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              hoverColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              gap: 8,
              activeColor: Theme.of(context).colorScheme.primary,
              iconSize: 20 * iconScale, // Adjusted icon size
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              tabBackgroundColor: Theme.of(context).colorScheme.onPrimary,
              color: Theme.of(context).colorScheme.onPrimary,
              tabs: [
                GButton(
                  icon: LineIcons.home,
                  text: 'inicio'.tr,
                ),
                GButton(
                  icon: LineIcons.map,
                  text: 'mapa'.tr,
                ),
                GButton(
                  icon: LineIcons.plusCircle,
                  text: 'publicar'.tr,
                ),
                GButton(
                  icon: LineIcons.comment,
                  text: "Chat",
                ),
                GButton(
                  icon: LineAwesomeIcons.heart,
                  text: 'favoritos'.tr,
                ),
                GButton(
                  icon: LineIcons.user,
                  text: 'perfil'.tr,
                ),
              ],
              selectedIndex: currentIndex,
              onTabChange: controller.updateIndex,
            ),
          ),
        );
      },
    );
  }
}

