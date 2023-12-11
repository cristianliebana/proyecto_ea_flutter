import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:proyecto_flutter/screens/chat.dart';
import 'package:proyecto_flutter/screens/create_product.dart';
import 'package:proyecto_flutter/screens/favorites.dart';
import 'package:proyecto_flutter/screens/home.dart';
import 'package:proyecto_flutter/screens/profile.dart';
import 'package:proyecto_flutter/bindings/map_Bindings.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/screens/review.dart';
import 'package:proyecto_flutter/screens/user_products.dart';
import 'package:proyecto_flutter/screens/user_profile.dart';
import 'package:proyecto_flutter/screens/user_profile_reviews.dart';


class ProfileTabBarController extends GetxController {
  String userId = '';
  String userId2 = '';

  void updateIndex(int index) {
    switch (index) {
      case 0:
        Get.to(UserProfileScreen(), transition: Transition.noTransition);
        break;
      case 1:
        Get.to(UserProfileReviewsScreen(),transition: Transition.noTransition);
        break;
      default:
        break;
    }
  }
}


class ProfileTabBar extends StatelessWidget {
  final ProfileTabBarController controller =
      Get.put(ProfileTabBarController());

  final int currentIndex;

  ProfileTabBar({Key? key, required this.currentIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileTabBarController>(
      builder: (controller) {
        return SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 1,
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 8),
            child: GNav(
              rippleColor:
                  Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              hoverColor:
                  Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              gap: 4,
              activeColor: Theme.of(context).colorScheme.primary,
              iconSize: 35,
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 8),
              tabBackgroundColor: Theme.of(context).colorScheme.onPrimary,
              color: Theme.of(context).colorScheme.onPrimary,
              tabs: [
                GButton(
                  icon: LineIcons.fruitApple,
                  text: "Productos",
                ),
                GButton(
                  icon: LineIcons.star,
                  text: "Reviews",
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