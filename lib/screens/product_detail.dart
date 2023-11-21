import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/home.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
      backgroundColor: Color(0xFFFFFCEA),
      appBar: AppBar(
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ImagesCarousel(imagePaths: imagePaths),
          const SizedBox(height: 20),
          if (productData.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    child: NameText(productData: productData),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  child: PriceText(productData: productData),
                ),
              ],
            ),
          const SizedBox(height: 5),
          if (productData.isNotEmpty)
            Card(
              color: Color(0xFF486D28),
              child: Column(
                children: [
                  DescText(),
                  SizedBox(height: 5),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    color: Color(0xFF486D28).withOpacity(0.7),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: DescriptionText(productData: productData),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (productData.isEmpty) CircularProgressIndicator(),
        ],
      ),
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

class DescText extends StatelessWidget {
  const DescText({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
          margin: EdgeInsets.only(top: 10, left: 20),
          width: gWidth,
          height: gHeight / 25,
          child: SizedBox(
            child: Text("Descripción:",
                style: TextStyle(
                  color: Color(0xFFFFFCEA),
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
        color: Color(0xFFFFFCEA),
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
  }) : super(key: key);

  final List<String> imagePaths;

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
          height: gHeight / 2.82,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: gHeight / 2.82,
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
                    width: gWidth,
                    child: Image(
                      image: AssetImage(path),
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.imagePaths.map((path) {
                    int index = widget.imagePaths.indexOf(path);
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Color(0xFF486D28)
                            : Colors.grey,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
