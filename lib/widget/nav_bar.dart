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
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: GNav(
              rippleColor:
                  Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              hoverColor:
                  Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              gap: 8,
              activeColor: Theme.of(context).colorScheme.primary,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              tabBackgroundColor: Theme.of(context).colorScheme.onPrimary,
              color: Theme.of(context).colorScheme.onPrimary,
              tabs: [
                GButton(
                  icon: LineIcons.home,
                  text: "Inicio",
                ),
                GButton(
                  icon: LineIcons.map,
                  text: "Mapa",
                ),
                GButton(
                  icon: LineIcons.plusCircle,
                  text: "Publicar",
                ),
                GButton(
                  icon: LineIcons.comment,
                  text: "Chat",
                ),
                GButton(
                  icon: LineAwesomeIcons.heart,
                  text: "Favoritos",
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
