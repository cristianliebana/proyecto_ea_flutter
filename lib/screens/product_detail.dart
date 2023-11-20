import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/screens/home.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductDetailScreen extends StatelessWidget {
  final List<String> imagePaths = [
    'assets/images/tomate.jpeg',
    'assets/images/tomate2.jpg',
    'assets/images/tomate3.jpg',
  ];

  ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Color(0xFFFFFCEA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Color(0xFF486D28),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                Get.to(HomePage());
              },
              icon: Icon(
                Icons.arrow_back,
                color: Color(0xFFFFFCEA),
              ),
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color(0xFF486D28),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.favorite_border,
                  color: Color(0xFFFFFCEA),
                ),
              ),
            ),
          ],
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ImagesCarousel(imagePaths: imagePaths),
          const Divider(),
        ]));
  }
}

class ImagesCarousel extends StatelessWidget {
  const ImagesCarousel({
    super.key,
    required this.imagePaths,
  });

  final List<String> imagePaths;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: gHeight / 2.82,
            enableInfiniteScroll: true,
            viewportFraction: 1.0,
          ),
          items: imagePaths.map((path) {
            return Container(
              width: gWidth,
              child: Image(
                image: AssetImage(path),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
