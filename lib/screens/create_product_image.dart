import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:proyecto_flutter/api/services/cloudinary_service.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
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

  @override
  void initState() {
    super.initState();
    productController = CreateProductController(
      productData: widget.productData,
      state: this,
    );
  }

  XFile? _imageFile;
  String? _imageUrl;
  String? getImageUrl() {
    return _imageUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _uploadImage() async {
    try {
      if (_imageFile == null) {
        // Manejar el caso cuando _imageFile es nulo
        print('Error: _imageFile es nulo.');
        return;
      }

      // Crear una instancia de CloudinaryServices
      final cloudinaryServices = CloudinaryServices();

      // Subir la imagen a Cloudinary usando CloudinaryServices
      final uploadedUrl = await cloudinaryServices.uploadImage(
        _imageFile!, /*"registroProducto"*/
      );
      print("URL de Cloudinary: $uploadedUrl");

      if (uploadedUrl != null) {
        // Si uploadedUrl no es nulo, actualizar la interfaz de usuario
        setState(() {
          _imageUrl = uploadedUrl;
        });
      } else {
        // Manejar el caso cuando uploadedUrl es nulo
        print('Error: uploadedUrl es nulo.');
      }
    } catch (error) {
      // Manejar errores generales
      print('Error en la carga de la imagen: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(15),
                width: gWidth,
                height: gHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    ImageText(),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _pickImage(ImageSource.camera);
                          },
                          child: const Text('Abre la cámara'),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            backgroundColor:
                                MaterialStateProperty.all(buttonColor),
                            minimumSize: MaterialStateProperty.all(Size(150,
                                50)), // Ajusta el tamaño según sea necesario
                          ),
                        ),
                        SizedBox(width: 10), // Espacio entre los botones
                        ElevatedButton(
                          onPressed: () {
                            _pickImage(ImageSource.gallery);
                          },
                          child: const Text('Abre la galería'),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            backgroundColor:
                                MaterialStateProperty.all(buttonColor),
                            minimumSize: MaterialStateProperty.all(Size(150,
                                50)), // Ajusta el tamaño según sea necesario
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      height:
                          300, // Altura fija para el contenedor que contiene CircleAvatar
                      child: Center(
                        child: _imageFile != null
                            ? CircleAvatar(
                                radius: 150,
                                backgroundImage: NetworkImage(_imageFile!.path),
                              )
                            : SizedBox.shrink(),
                      ),
                    ),
                    SizedBox(height: 20),
                    SubmitButton(productController: productController),
                  ],
                ),
              ),
            )));
  }
}

class CreateProductController extends GetxController {
  final Map<String, dynamic> productData;
  final TextEditingController productImageController = TextEditingController();
  final _CreateProductImageState _state;

  CreateProductController({
    required this.productData,
    required _CreateProductImageState state,
  }) : _state = state;

  Future<void> _uploadImageAndCreateProduct(BuildContext context) async {
    await _state._uploadImage(); // Llama a la función de subir imagen
    addProduct(context);
  }

  void addProduct(BuildContext context) async {
    String? name = productData['name'];
    String? description = productData['description'];
    int? units = productData['units'];
    double? price = productData['price'];
    String? userId = productData['user'];
    String? productImage = _state.getImageUrl();

    Map<String, dynamic> productImageData = {
      'name': name,
      'description': description,
      'price': price,
      'units': units,
      'user': userId,
      'productImage': productImage,
    };

    try {
      print(productData);
      ApiResponse response = await ProductService.addProduct(productImageData);
      Get.defaultDialog(
        title: "¡Felicidades!",
        backgroundColor: Color(0xFFFFFCEA),
        content: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Color(0xFFFFFCEA),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFFCEA),
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
                    Text("¡Acabas de publicar tu producto!"),
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
          child: Text("Aceptar"),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(buttonColor),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Algo falló al intentar publicar el producto",
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
    return FadeInDown(
      delay: Duration(milliseconds: 25),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 100),
        width: gWidth,
        height: gHeight / 15,
        child: ElevatedButton(
          onPressed: () async {
            await productController._uploadImageAndCreateProduct(context);
          },
          child: Text(
            "Añadir Producto",
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
            "¡Escoge una foto para tu producto!",
            style: TextStyle(
                color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          )),
    );
  }
}
