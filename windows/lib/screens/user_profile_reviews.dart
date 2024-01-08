import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:proyecto_flutter/api/models/product_model.dart';
import 'package:proyecto_flutter/api/models/rating_model.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/services/rating_service.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/chat.dart';
import 'package:proyecto_flutter/screens/product_detail.dart';
import 'package:proyecto_flutter/screens/profile.dart';
import 'package:proyecto_flutter/screens/update_user.dart';
import 'package:proyecto_flutter/screens/user_products.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/utils/theme_provider.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';
import 'package:proyecto_flutter/widget/profile_tab_bar.dart';


class UserProfileReviewsScreen extends StatefulWidget {
  @override
  _UserProfileReviewsScreenState createState() => _UserProfileReviewsScreenState();
}

class _UserProfileReviewsScreenState extends State<UserProfileReviewsScreen> {
  List<Product> products = [];
  List<Rating> ratings = [];
  Map<String, dynamic> userData = {};
  Map<String, dynamic> userData2 = {};
  
  late ScrollController _scrollController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    obtenerDatosUsuario();
  }

  Future<void> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    setState(() {
      userData = response.data;
      loadUserProducts(userData['_id']);
      loadUserRatings(userData['_id']);
    });
  }


  Future<void> loadUserProducts(String? userId) async {
    if (userId != null) {
      final List<Product> userproducts =
          await ProductService.getUserProducts(userId);
      setState(() {
        products = userproducts;
        print(products);
      });
    } else {
      print('UserId is null.');
    }
  }

  Future<void> loadUserRatings(String? userId) async {
  if (userId != null) {
    final List<Rating> userratings = await RatingService.getUserRatings(userId);
    setState(() {
      ratings = userratings;
      print(ratings);
      obtenerDatosCreadorReview(ratings);
    });
  } else {
    print('UserId is null.');
  }
}

Future<void> obtenerDatosCreadorReview (List<Rating> ratings) async{
   for (var rating in ratings) {
      if (rating.userId1 != null) {
        final userData2 = await UserService.getCreadorById(rating.userId1!);
        print(userData2);
      }
    }
}

/*  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreProducts();
    }
  }*/

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      actions: [
        _buildAppBarThemeButton(),
      ],
    );
  }

  Widget _buildAppBarThemeButton() {
    final ThemeProvider themeProvider = Get.find<ThemeProvider>();

    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: () {
          // Lógica para cambiar el tema
          Get.find<ThemeProvider>().toggleTheme();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 5),
      body: Column(
        children: [
          // Sección de información del usuario (arriba)
          SizedBox(height: 10),
          ProfileImage(userData: userData),
          const SizedBox(height: 10),
          if (userData.isNotEmpty) UsernameText(userData: userData),
          const SizedBox(height: 10),
          if (userData.isNotEmpty) EmailText(userData: userData),
          if (userData.isEmpty) CircularProgressIndicator(),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          ProfileTabBar(currentIndex: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                return RatingsListItem(rating: ratings[index], userData2: userData2);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 10), 
          Padding(
            padding: const EdgeInsets.only(),
            child: TextField(
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.primary,
              ),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                filled: true,
                fillColor: Theme.of(context).colorScheme.onPrimary,
                prefixIcon: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                hintStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.primary,
                ),
                hintText: "Busca en productos",
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmailText extends StatelessWidget {
  const EmailText({
    Key? key,
    required this.userData,
  });

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    String email = userData['email'] ?? "N/A";

    return Text(
      email != "N/A" ? "$email" : "",
      style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w200,
          color: Theme.of(context).primaryColor),
    );
  }
}

class UsernameText extends StatelessWidget {
  const UsernameText({
    Key? key,
    required this.userData,
  });

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    String username = userData['username'] ?? "N/A";

    return Text(
      username != "N/A" ? "$username" : "",
      style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    Key? key,
    required this.userData,
  }) : super(key: key);

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    String profileImage = userData['profileImage'] ?? "";

    return Container(
      width: 175,
      height: 175,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: CldImageWidget(
          publicId: profileImage.isNotEmpty
              ? profileImage
              : "https://res.cloudinary.com/dfwsx27vx/image/upload/v1701028188/profile_ju3yvo.png",
          width: 175,
          height: 175,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}


class RatingsListItem extends StatelessWidget {
  final Rating rating;
  final Map<String, dynamic> userData2;
  const RatingsListItem({Key? key, required this.rating, required this.userData2}) : super(key: key);
  
  

@override
Widget build(BuildContext context) {
  return Container(
    margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
    padding: EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onPrimary,
      borderRadius: BorderRadius.circular(15.0),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 35,
          backgroundImage: userData2['profileImage'] != null &&
                  userData2['profileImage'].isNotEmpty
              ? NetworkImage(userData2['profileImage']!)
              : Image.asset('assets/images/profile.png').image,
          backgroundColor: Colors.transparent,
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RatingBar(
                    ignoreGestures: true,
                    initialRating: rating.rating ?? 3.5,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    ratingWidget: RatingWidget(
                      full: Image.asset(
                          'assets/ratingimages/zanahoriaentera.png'),
                      half: Image.asset(
                          'assets/ratingimages/mediazanahoria.png'),
                      empty: Image.asset(
                          'assets/ratingimages/zanahoriavacia.png'),
                    ),
                    itemPadding:
                        EdgeInsets.symmetric(horizontal: 4.0),
                    onRatingUpdate: (rating) {},
                  ),
                  Text(
                    userData2['username'] ?? '',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              // Comment
              Text(
                rating.comment ?? '',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}}


