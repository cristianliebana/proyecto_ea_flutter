import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/services/room_service.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/services/favorite_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/chat.dart';
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
  late String userId;
  late String favoriteId;

  @override
  void initState() {
    super.initState();
    checkAuthAndNavigate();
    obtenerDatosProducto();
    obtenerDatosUsuario();
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

  Future<void> borrarFavorito(String userId, String productId) async {
    ApiResponse response = await FavoriteService.deleteFavorite(favoriteId);
  }

  Future<void> _handleFavoriteButton() async {
    if (userData['_id'] == creadorData['_id']) {
      Get.snackbar('Error', 'No puedes darle a favorito a un producto tuyo');
    } else {
      try {
        if (_isFavoriteExists) {
          await borrarFavorito(userData['_id'], widget.productId);
          Get.snackbar('Éxito', 'Producto eliminado de favoritos');
        } else {
          await crearFavorito(userData['_id'], widget.productId);
          Get.snackbar('Éxito', 'Producto agregado a favoritos');
        }

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
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: _buildAppBarBackButton(),
      actions: [
        _buildAppBarFavoriteButton(),
      ],
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
  const InformationWidget(
      {Key? key,
      required this.productData,
      required this.creadorData,
      required this.userData});

  final Map<String, dynamic> productData;
  final Map<String, dynamic> userData;
  final Map<String, dynamic> creadorData;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DraggableScrollableSheet(
          initialChildSize: 0.70,
          maxChildSize: 1.0,
          minChildSize: 0.65,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    NameText(productData: productData),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: creadorData['profileImage'] !=
                                      null &&
                                  creadorData['profileImage'].isNotEmpty
                              ? NetworkImage(creadorData['profileImage']!)
                              : Image.asset('assets/images/profile.png').image,
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(width: 10),
                        SizedBox(height: 30),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UserText(creadorData: creadorData),
                              Transform.scale(
                                alignment: Alignment.centerLeft,
                                scale: 0.7,
                                child: RatingBar(
                                  ignoreGestures: true,
                                  initialRating: creadorData['rating'] ?? 3.5,
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
                              ),
                            ]),
                        Spacer(),
                        PriceText(productData: productData),
                      ],
                    ),
                    SizedBox(height: 20),
                    Divider(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    SizedBox(height: 10),
                    DescText(),
                    DescriptionText(productData: productData),
                    SizedBox(height: 10),
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
          child: ChatButton(userData: userData, creadorData: creadorData),
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 170),
      width: gWidth / 4,
      height: gHeight / 16,
      child: ElevatedButton(
        onPressed: () async {
          String userId1 = userData['_id'] ?? '';
          String userId2 = creadorData['_id'] ?? '';

          ApiResponse response =
              await RoomService.checkIfRoomExists(userId1, userId2);

          if (response.statusCode == 200) {
            bool roomExists = response.data['exist'];

            if (roomExists) {
              Get.to(ChatPage());
            } else {
              ApiResponse createResponse =
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
          "Contacta",
          style: TextStyle(
              fontSize: 25, color: Theme.of(context).colorScheme.primary),
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}

class DescText extends StatelessWidget {
  const DescText({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
          margin: EdgeInsets.only(top: 10),
          width: gWidth,
          height: gHeight / 25,
          child: SizedBox(
            child: Text("Descripción",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                )),
          )),
    );
  }
}

class PriceText extends StatelessWidget {
  const PriceText({
    Key? key,
    required this.productData,
  });

  final Map<String, dynamic> productData;

  @override
  Widget build(BuildContext context) {
    int price = productData['price'] ?? 0;

    return Text(price != 0 ? "$price €/Kg" : "",
        style: TextStyle(color: Theme.of(context).shadowColor, fontSize: 30),
        textAlign: TextAlign.right);
  }
}

class UserText extends StatelessWidget {
  const UserText({
    Key? key,
    required this.creadorData,
  });

  final Map<String, dynamic> creadorData;

  @override
  Widget build(BuildContext context) {
    String username = creadorData['username'] ?? "N/A";

    return Text(
      username != "N/A" ? "$username" : "",
      style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor),
    );
  }
}

class DescriptionText extends StatelessWidget {
  const DescriptionText({
    Key? key,
    required this.productData,
  });

  final Map<String, dynamic> productData;

  @override
  Widget build(BuildContext context) {
    String description = productData['description'] ?? "N/A";

    return Text(
      description != "N/A" ? "$description" : "",
      style: TextStyle(
        color: Theme.of(context).shadowColor,
        fontSize: 20,
        fontWeight: FontWeight.w200,
      ),
      textAlign: TextAlign.justify,
    );
  }
}

class NameText extends StatelessWidget {
  const NameText({
    Key? key,
    required this.productData,
  });

  final Map<String, dynamic> productData;

  @override
  Widget build(BuildContext context) {
    String name = productData['name'] ?? "N/A";

    return Text(
      name != "N/A" ? "$name" : "",
      style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 50,
          fontWeight: FontWeight.bold),
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
      imageUrls.add('assets/images/profile.png');
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
                          imageUrl ?? 'assets/images/profile.png',
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
