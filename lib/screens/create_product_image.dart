// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:proyecto_flutter/api/services/cloudinary_service.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/create_product_detail.dart';
import 'package:proyecto_flutter/screens/user_products.dart';
import 'package:proyecto_flutter/utils/constants.dart';

class CreateProductImage extends StatefulWidget {
  final Map<String, dynamic> productData;

  CreateProductImage({Key? key, required this.productData}) : super(key: key);

  @override
  _CreateProductImageState createState() => _CreateProductImageState();
}

class _CreateProductImageState extends State<CreateProductImage> {
  late CreateProductController productController;
  List<XFile> _selectedImages = [];
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    checkAuthAndNavigate();
    productController = CreateProductController(
      productData: widget.productData,
      state: this,
    );
  }

  Future<void> checkAuthAndNavigate() async {
    await TokenService.loggedIn();
  }

  Future<void> _pickImages() async {
    try {
      List<XFile>? resultList = await ImagePicker().pickMultiImage();

      if (resultList != null) {
        setState(() {
          _selectedImages = resultList;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _uploadImages() async {
    try {
      List<String> imageUrls = [];

      for (var file in _selectedImages) {
        if (file is XFile) {
          final cloudinaryServices = CloudinaryServices();
          final uploadedUrl = await cloudinaryServices.uploadImage(file);

          if (uploadedUrl != null) {
            imageUrls.add(uploadedUrl);
          } else {
            print('Error: uploadedUrl es nulo para una imagen.');
          }
        }
      }

      setState(() {
        _imageUrls = List<String>.from(imageUrls);
      });
    } catch (error) {
      print('Error en la carga de imágenes: $error');
    }
  }

  String? getImageUrl() {
    return _imageUrls.isNotEmpty ? _imageUrls.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 40),
            ImageText(),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickImages,
                      child: Text(
                        'abre la galeria'.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 20),
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.onPrimary),
                        minimumSize: MaterialStateProperty.all(
                          Size(150, 50),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'fotos seleccionadas'.tr +
                          '${_selectedImages.length}' +
                          'de 8'.tr,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: _selectedImages.isNotEmpty
                            ? GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.6,
                                ),
                                itemBuilder: (context, index) {
                                  if (index < _selectedImages.length) {
                                    return Image(
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          _selectedImages[index].path),
                                    );
                                  } else {
                                    return Image(
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                          'assets/images/fotos3.png'),
                                    );
                                  }
                                },
                                itemCount: 8,
                              )
                            : GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.6,
                                ),
                                itemBuilder: (context, index) {
                                  return Image(
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    image:
                                        AssetImage('assets/images/fotos3.png'),
                                  );
                                },
                                itemCount: 8,
                              ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SubmitButton(productController: productController),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateProductController extends GetxController {
  final Map<String, dynamic> productData;
  final TextEditingController productImageController = TextEditingController();
  final _CreateProductImageState _state;
  LatLng? chosenLocation;
  final bool sold = false;

  CreateProductController({
    required this.productData,
    required _CreateProductImageState state,
  }) : _state = state {
    if (productData.containsKey('location') &&
        productData['location'] != null) {
      var location = productData['location'];
      chosenLocation = LatLng(location['latitude'], location['longitude']);
    } else {}
  }

  Future<void> _uploadImagesAndCreateProduct(BuildContext context) async {
    await _state._uploadImages();
    addProduct(context);
  }

  void addProduct(BuildContext context) async {
    String? name = productData['name'];
    String? description = productData['description'];
    int? units = productData['units'];
    double? price = productData['price'].toDouble();
    String? userId = productData['user'];
    List<String> productImage = List<String>.from(_state._imageUrls);
    DateTime date = productData['date'];
    bool sold = false;

    Map<String, dynamic> productImageData = {
      'name': name,
      'description': description,
      'price': price,
      'units': units,
      'user': userId,
      'productImage': productImage,
      'location': chosenLocation != null
          ? {
              'latitude': chosenLocation!.latitude,
              'longitude': chosenLocation!.longitude
            }
          : null,
      'date': date.toIso8601String(),
      'sold': sold,
    };

    try {
      print(productImageData);
      ApiResponse response = await ProductService.addProduct(productImageData);
      Get.defaultDialog(
        title: 'felicidades'.tr,
        titleStyle: TextStyle(color: Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  children: [
                    Lottie.asset(
                      "assets/json/check3.json",
                      width: 100,
                      height: 100,
                      repeat: false,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'publicado'.tr,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        radius: 10.0,
        confirm: ElevatedButton(
          onPressed: () {
            Get.offAll(UserProductsScreen());
          },
          child: Text(
            'aceptar'.tr,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(
                Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        'falloProducto'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class SubmitButton extends StatelessWidget {
  final CreateProductController productController;

  SubmitButton({
    required this.productController,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Adjust the button size and margin based on the screen size
    double buttonWidth = screenWidth * 0.8; // 80% of screen width
    double buttonHeight = screenHeight * 0.06; // 6% of screen height
    double horizontalMargin = screenWidth * 0.1; // 10% of screen width for both sides

    return FadeInDown(
      delay: Duration(milliseconds: 25),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
        width: buttonWidth,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: () async {
            await productController._uploadImagesAndCreateProduct(context);
          },
          child: Text(
            'añadirProducto'.tr,
            style: TextStyle(
              fontSize: 20, // Consider making font size responsive if needed
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
      ),
    );
  }
}


class ImageText extends StatelessWidget {
  const ImageText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 10),
        child: Text(
          'fotos'.tr,
          style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 30,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
