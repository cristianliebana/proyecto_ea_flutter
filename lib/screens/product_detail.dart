import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/api/services/rating_service.dart';
import 'package:proyecto_flutter/screens/user_profile.dart';
import 'package:proyecto_flutter/widget/userId_controller.dart';
import 'package:share_plus/share_plus.dart';
//import 'dart:html' as html;
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/services/room_service.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/services/favorite_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/chat.dart';
import 'package:proyecto_flutter/screens/edit_product.dart';
import 'package:proyecto_flutter/screens/home.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:proyecto_flutter/utils/constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  ProductDetailScreen({required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic> productData = {};
  Map<String, dynamic> creadorData = {};
  Map<String, dynamic> userData = {};
  bool _isFavoriteExists = false;
  Map<String, dynamic> favoriteData = {};
  late String favoriteCount = "";
  late String userRatingCount = "";
  late String userId;
  late String favoriteId;
  bool _isLoading = true; // New variable to track loading state
  String _errorMessage = ''; // New variable to store error messages

  @override
  void initState() {
    super.initState();
    checkAuthAndNavigate();
    obtenerDatosProducto();
    obtenerDatosUsuario();
    countFavorito(widget.productId);
    // _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      await checkAuthAndNavigate();
      await obtenerDatosProducto();
      await obtenerDatosUsuario();
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> obtenerDatosProducto() async {
    ApiResponse response =
        await ProductService.getProductById(widget.productId);
    setState(() {
      productData = response.data;
      userId = productData['user'];
    });
    await obtenerDatosCreadorProducto(productData['user']);
    await checkFavoriteExistence();
  }

  Future<void> obtenerDatosCreadorProducto(String creadorId) async {
    ApiResponse response = await UserService.getCreadorById(creadorId);
    setState(() {
      creadorData = response.data;
    });
    await countRating(creadorData['_id']);
  }

  Future<void> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    setState(() {
      userData = response.data;
    });
  }

  Future<void> crearFavorito(String userId, String productId) async {
    ApiResponse response =
        await FavoriteService.createFavorite(userData['_id'], productId);

    setState(() {
      favoriteData = response.data;
    });
  }

  Future<void> countFavorito(String productId) async {
    String favoritesCount =
        await FavoriteService.getProductFavoritesCount(productId);

    setState(() {
      favoriteCount = favoritesCount;
    });
  }

  Future<void> countRating(String userId) async {
    String usersCount =
        await RatingService.getUserRatingsCount(creadorData['_id']);

    setState(() {
      userRatingCount = usersCount;
    });
  }

  Future<void> borrarFavorito(String userId, String productId) async {
    ApiResponse response = await FavoriteService.deleteFavorite(favoriteId);
  }

  Future<void> _handleFavoriteButton() async {
    if (userData['_id'] == creadorData['_id']) {
      Get.snackbar('Error', 'favoritoTuyo'.tr);
    } else {
      try {
        if (_isFavoriteExists) {
          await borrarFavorito(userData['_id'], widget.productId);
          Get.snackbar('success'.tr, 'favoritoEliminado'.tr);
        } else {
          await crearFavorito(userData['_id'], widget.productId);
          Get.snackbar('success'.tr, 'favoritoAgregado'.tr);
        }

        await countFavorito(widget.productId);

        setState(() {
          _isFavoriteExists = !_isFavoriteExists;
        });
      } catch (error) {
        print('Error: $error');
      }
    }
  }

  Future<void> checkFavoriteExistence() async {
    try {
      Map<String, dynamic> response =
          await FavoriteService.checkIfUserHasFavorite(
              userData['_id'], widget.productId);
      bool exists = response['exists'] ?? false;
      favoriteId = response['favoriteId'] ?? '';

      setState(() {
        _isFavoriteExists = exists;
      });
    } catch (error) {
      setState(() {
        _isFavoriteExists = false;
      });
    }
  }

  Future<void> checkAuthAndNavigate() async {
    await TokenService.loggedIn();
  }

  void _onRemoveTokenPressed() {
    TokenService.removeToken();
  }

  IconButton _buildAppBarIconButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }

  void _shareProductDetails() {
    String productName = productData['name'] ?? 'Product Name';
    //String productDescription = productData['description'] ?? 'Product Description';
    //String currentUrl = html.window.location.href;
    String shareMessage = 'Mira este $productName en km0Market!';

    Share.share(shareMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          ImagesCarousel(productData: productData, buildAppBar: _buildAppBar),
          InformationWidget(
            productData: productData,
            creadorData: creadorData,
            userData: userData,
            favoriteCount: favoriteCount,
            userRatingCount: userRatingCount,
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   if (_isLoading) {
  //     return Scaffold(
  //       body: Center(child: CircularProgressIndicator()),
  //     );
  //   }

  //   if (_errorMessage.isNotEmpty) {
  //     return Scaffold(
  //       body: Center(child: Text('Error: $_errorMessage')),
  //     );
  //   }
  //   return Scaffold(
  //     extendBodyBehindAppBar: true,
  //     appBar: _buildAppBar(),
  //     body: Stack(
  //       children: [
  //         ImagesCarousel(productData: productData, buildAppBar: _buildAppBar),
  //         InformationWidget(
  //           productData: productData,
  //           creadorData: creadorData,
  //           userData: userData,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: _buildAppBarBackButton(),
      actions: [
        _buildAppBarFavoriteButton(),
        _buildAppBarShareButton(),
        if (userData['_id'] == creadorData['_id']) _buildAppBarEditButton(),
      ],
    );
  }

  Widget _buildAppBarEditButton() {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          Icons.edit,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: _handleEditButton,
      ),
    );
  }

  Widget _buildAppBarShareButton() {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          Icons.share,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: () {
          _shareProductDetails();
        },
      ),
    );
  }

  void _handleEditButton() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProductScreen(productId: widget.productId),
      ),
    );
  }

  Widget _buildAppBarFavoriteButton() {
    return _isFavoriteExists
        ? Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.favorite,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                await checkFavoriteExistence();
                await _handleFavoriteButton();
              },
            ),
          )
        : Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.favorite_border,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                await _handleFavoriteButton();
              },
            ),
          );
  }

  Widget _buildAppBarBackButton() {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: () {
          Get.to(HomePage());
        },
      ),
    );
  }
}

class InformationWidget extends StatelessWidget {
  const InformationWidget({
    Key? key,
    required this.productData,
    required this.creadorData,
    required this.userData,
    required this.favoriteCount,
    required this.userRatingCount,
  }) : super(key: key);

  final Map<String, dynamic> productData;
  final Map<String, dynamic> userData;
  final Map<String, dynamic> creadorData;
  final String favoriteCount;
  final String userRatingCount;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double initialChildSize = screenHeight > 700 ? 0.70 : 0.60;
    double minChildSize = screenHeight > 700 ? 0.65 : 0.55;
    double textSize = screenWidth / 480 * 25;

    return Stack(
      children: [
        DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          maxChildSize: 1.0,
          minChildSize: minChildSize,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 5,
                            width: 35,
                            color: Colors.black12,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: NameText(
                              productData: productData, fontSize: textSize),
                        ),
                        SizedBox(
                            width:
                                10), // Adjust the spacing between NameText and FavoriteCount
                        FavoriteCount(
                          favoriteCount: favoriteCount,
                          fontSize: textSize,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage:
                              creadorData['profileImage'] != null &&
                                      creadorData['profileImage'].isNotEmpty
                                  ? NetworkImage(creadorData['profileImage']!)
                                  : AssetImage('assets/images/profile.png')
                                      as ImageProvider<Object>,
                          backgroundColor: Colors.transparent,
                          child: GestureDetector(
                            onTap: () {
                              print(creadorData['_id']);
                              userController
                                  .setUserId(creadorData['_id'] ?? '');
                              // Navegar a la pantalla de perfil del creador con el ID del creador
                              Get.to(UserProfileScreen(
                                  userId: userController.userId.value));
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UserText(
                                  creadorData: creadorData, fontSize: textSize),
                              Transform.scale(
                                alignment: Alignment.centerLeft,
                                scale: screenWidth / 700,
                                child: Row(
                                  children: [
                                    RatingBar(
                                      ignoreGestures: true,
                                      initialRating:
                                          creadorData['rating'] ?? 3.5,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      ratingWidget: RatingWidget(
                                        full: Image(
                                            image: AssetImage(
                                                'assets/ratingimages/zanahoriaentera.png')),
                                        half: Image(
                                            image: AssetImage(
                                                'assets/ratingimages/mediazanahoria.png')),
                                        empty: Image(
                                            image: AssetImage(
                                                'assets/ratingimages/zanahoriavacia.png')),
                                      ),
                                      itemPadding:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      onRatingUpdate: (rating) {},
                                    ),
                                    UserRating(
                                      userRatingCount: userRatingCount,
                                      fontSize: textSize,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        PriceText(productData: productData, fontSize: textSize),
                      ],
                    ),
                    SizedBox(height: 20),
                    Divider(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    SizedBox(height: 10),
                    DescText(fontSize: textSize),
                    DescriptionText(
                        productData: productData, fontSize: textSize),
                    SizedBox(height: 70),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              ChatButton(userData: userData, creadorData: creadorData),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatButton extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic> creadorData;

  const ChatButton({
    Key? key,
    required this.userData,
    required this.creadorData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate button width and margin based on screen width
    double buttonWidth = screenWidth >= 700 ? screenWidth / 4 : screenWidth / 2;
    double buttonMargin = screenWidth >= 700 ? 170 : 20;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: buttonMargin),
      width: buttonWidth,
      height: 50, // Set your desired height
      child: ElevatedButton(
        onPressed: () async {
          final String userId1 = userData['_id'] ?? '';
          final String userId2 = creadorData['_id'] ?? '';

          final ApiResponse response =
              await RoomService.checkIfRoomExists(userId1, userId2);

          if (response.statusCode == 200) {
            final bool roomExists = response.data['exist'];

            if (roomExists) {
              Get.to(ChatPage());
            } else {
              final ApiResponse createResponse =
                  await RoomService.createRoom(userId1, userId2);

              if (createResponse.statusCode == 201) {
                Get.to(ChatPage());
              } else {
                print("Error al crear la sala: ${createResponse.data}");
              }
            }
          } else {
            print("Error al verificar la sala: ${response.data}");
          }
        },
        child: Text(
          'contacta'.tr,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
            Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class DescText extends StatelessWidget {
  final double fontSize;

  const DescText({Key? key, required this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Text(
        'descripcion'.tr, // Ensure you have translation setup for this
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

class PriceText extends StatelessWidget {
  final Map<String, dynamic> productData;
  final double fontSize;

  const PriceText({Key? key, required this.productData, required this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic priceValue = productData['price'];
    double price = priceValue is num ? priceValue.toDouble() : 0.0;

    return Text(
      price != 0.0 ? "$price €/Kg" : "",
      style: TextStyle(
        color: Theme.of(context).shadowColor,
        fontSize: fontSize,
      ),
    );
  }
}

class UserRating extends StatelessWidget {
  final String userRatingCount;
  final double fontSize;

  const UserRating(
      {Key? key, required this.userRatingCount, required this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = userRatingCount ?? "N/A";

    return Text(
      name != "N/A" ? " ($name)" : "",
      style: TextStyle(
        color: Theme.of(context).shadowColor.withOpacity(0.7),
        fontSize: fontSize - 9,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class UserText extends StatelessWidget {
  final Map<String, dynamic> creadorData;
  final double fontSize;

  const UserText({Key? key, required this.creadorData, required this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String username = creadorData['username'] ?? "N/A";
    return Text(
      username != "N/A" ? "$username" : "",
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: fontSize,
      ),
    );
  }
}

class DescriptionText extends StatelessWidget {
  final Map<String, dynamic> productData;
  final double fontSize;

  const DescriptionText(
      {Key? key, required this.productData, required this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String description = productData['description'] ?? "N/A";
    return Text(
      description != "N/A" ? "$description" : "",
      style: TextStyle(
        color: Theme.of(context).shadowColor,
        fontSize: fontSize,
      ),
    );
  }
}

class FavoriteCount extends StatelessWidget {
  final String favoriteCount;
  final double fontSize;

  const FavoriteCount(
      {Key? key, required this.favoriteCount, required this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = favoriteCount ?? "N/A";

    return Row(
      children: [
        Icon(
          Icons.favorite_border, // Puedes cambiar este icono por el que desees
          color: Theme.of(context).shadowColor,
          size: fontSize,
        ),
        Text(
          name != "N/A" ? " $name" : "",
          style: TextStyle(
            color: Theme.of(context).shadowColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class NameText extends StatelessWidget {
  final Map<String, dynamic> productData;
  final double fontSize;

  const NameText({Key? key, required this.productData, required this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = productData['name'] ?? "N/A";
    return Text(
      name != "N/A" ? "$name" : "",
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ImagesCarousel extends StatefulWidget {
  const ImagesCarousel({
    Key? key,
    required this.productData,
    required this.buildAppBar,
  }) : super(key: key);

  final Map<String, dynamic> productData;
  final Function() buildAppBar;

  @override
  _ImagesCarouselState createState() => _ImagesCarouselState();
}

class _ImagesCarouselState extends State<ImagesCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<String?> imageUrls =
        List<String?>.from(widget.productData['productImage'] ?? []);

    // Agrega 'assets/images/profile.png' si la lista de imágenes está vacía
    if (imageUrls.isEmpty) {
      imageUrls.add('assets/assets/images/profile.png');
    }

    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 2.82,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height / 2.82,
                  enableInfiniteScroll: true,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: imageUrls
                    .map(
                      (imageUrl) => Container(
                        width: MediaQuery.of(context).size.width,
                        child: Image.network(
                          imageUrl ?? 'assets/assets/images/profile.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
