import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/home.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductDetailScreen2 extends StatefulWidget {
  final String productId;

  ProductDetailScreen2({required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen2> {
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
    return Positioned(
      top: 0, // Ajusta esta posición según tus necesidades
      left: 0,
      right: 0,
      bottom: 0,
      child: DraggableScrollableSheet(
        initialChildSize: 0.70, // Ajusta este valor según tus necesidades
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
                  PriceText(productData: productData),
                  DescriptionText(productData: productData),
                ],
              ),
            ),
          );
        },
      ),
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

    return Text(
      price != 0 ? "$price €/Kg" : "",
      style: TextStyle(
          color: Color(0xFF486D28), fontSize: 30, fontWeight: FontWeight.bold),
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
        color: Color(0xFF486D28),
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
          color: Color(0xFF486D28), fontSize: 50, fontWeight: FontWeight.bold),
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
