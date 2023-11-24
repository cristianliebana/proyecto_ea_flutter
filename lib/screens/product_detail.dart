import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/chat.dart';
//import 'package:proyecto_flutter/screens/chat.dart';
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
  final List<String> imagePaths = [
    'assets/images/tomate.jpeg',
    'assets/images/tomate2.jpg',
    'assets/images/tomate3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    checkAuthAndNavigate();
    obtenerDatosProducto();
  }

  Future<void> obtenerDatosProducto() async {
    ApiResponse response =
        await ProductService.getProductById(widget.productId);
    setState(() {
      productData = response.data;
    });
  }

  Future<void> checkAuthAndNavigate() async {
    await TokenService.loggedIn();
  }

  void _onRemoveTokenPressed() {
    TokenService.removeToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(), // Use the common _buildAppBar method
      body: Stack(
        children: [
          ImagesCarousel(imagePaths: imagePaths, buildAppBar: _buildAppBar),
          InformationWidget(productData: productData),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: _buildAppBarIconButton(
        icon: Icons.arrow_back,
        onPressed: () {
          Get.to(HomePage());
        },
      ),
      actions: [
        _buildAppBarIconButton(
          icon: Icons.favorite_border,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildAppBarIconButton(
      {required IconData icon, required Function() onPressed}) {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Color(0xFF486D28),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Color(0xFFFFFCEA),
        ),
      ),
    );
  }
}

class InformationWidget extends StatelessWidget {
  const InformationWidget({
    Key? key,
    required this.productData,
  });

  final Map<String, dynamic> productData;

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
              decoration: const BoxDecoration(
                color: Color(0xFFFFFCEA),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
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
                          radius: 25,
                          backgroundImage:
                              AssetImage("assets/images/shrek.jpeg"),
                        ),
                        SizedBox(width: 10),
                        UserText(productData: productData),
                        Spacer(), // Añade un espacio flexible para separar los widgets
                        PriceText(productData: productData),
                      ],
                    ),
                    SizedBox(height: 20),
                    Divider(),
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
          child: ChatButton(),
        ),
      ],
    );
  }
}

class ChatButton extends StatelessWidget {
  const ChatButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 100),
      width: gWidth,
      height: gHeight / 15,
      child: ElevatedButton(
        onPressed: () async {
          Get.to(ChatPage());
        },
        child: Text(
          "Contacta",
          style: TextStyle(fontSize: 25),
        ),
        style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(buttonColor)),
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
                  color: Colors.black,
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
        style: TextStyle(color: Color.fromARGB(255, 99, 99, 99), fontSize: 30),
        textAlign: TextAlign.right);
  }
}

class UserText extends StatelessWidget {
  const UserText({
    Key? key,
    required this.productData,
  });

  final Map<String, dynamic> productData;

  @override
  Widget build(BuildContext context) {
    String user = productData['user'] ?? "N/A";

    return Text(
      user != "N/A" ? "$user" : "",
      style: TextStyle(fontSize: 25),
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
        color: Color.fromARGB(255, 99, 99, 99),
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
          color: Colors.black, fontSize: 50, fontWeight: FontWeight.bold),
    );
  }
}

class ImagesCarousel extends StatefulWidget {
  const ImagesCarousel({
    Key? key,
    required this.imagePaths,
    required this.buildAppBar,
  }) : super(key: key);

  final List<String> imagePaths;
  final Function() buildAppBar;

  @override
  _ImagesCarouselState createState() => _ImagesCarouselState();
}

class _ImagesCarouselState extends State<ImagesCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
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
                items: widget.imagePaths.map((path) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    child: Image(
                      image: AssetImage(path),
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
