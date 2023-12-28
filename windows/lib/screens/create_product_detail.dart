import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/create_product.dart';
import 'package:proyecto_flutter/screens/create_product_image.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/rep_textfiled.dart';

class CreateProductDetail extends StatefulWidget {
  final String productName;
  const CreateProductDetail({Key? key, required this.productName, req})
      : super(key: key);

  @override
  _CreateProductDetailState createState() => _CreateProductDetailState();
}

class _CreateProductDetailState extends State<CreateProductDetail> {
  late Future<CreateProductController?> _controllerFuture;

  @override
  void initState() {
    super.initState();
    _controllerFuture = obtenerDatosUsuario();
  }

  Future<CreateProductController?> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    Map<String, dynamic> userData = response.data;
    print("User Data: $userData");

    return CreateProductController(userData: userData);
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: _buildAppBarBackButton(),
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
          Get.to(CreateProduct());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CreateProductController?>(
      future: _controllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text('Data is null');
        }

        CreateProductController createProductController = snapshot.data!;

        createProductController.nameController.text = widget.productName;

        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: _buildAppBar(),
            body: Container(
              margin: EdgeInsets.all(15),
              width: gWidth,
              height: gHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimationFarmer(),
                  TitleText(),
                  DescriptionText(),
                  NameTextField(
                      createProductController: createProductController),
                  SizedBox(height: 10),
                  DescriptionTextField(
                      createProductController: createProductController),
                  SizedBox(height: 10),
                  PriceTextField(
                      createProductController: createProductController),
                  SizedBox(height: 10),
                  UnitsTextField(
                      createProductController: createProductController),
                  SizedBox(height: 20),
                  SaveButton(createProductController: createProductController),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CreateProductController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController unitsController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  Map<String, dynamic> userData;
  CreateProductController({required this.userData});

  void addProduct(BuildContext context) async {
    String? name = nameController.text;
    String? description = descriptionController.text;
    int? units = int.tryParse(unitsController.text);
    double? price = double.tryParse(priceController.text);
    String? userId = userData['_id'] ?? '';

    if (name.isEmpty || units == null || price == null) {
      Get.snackbar(
        "Error",
        "Debes de rellenar todos los campos",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Map<String, dynamic> productData = {
      'name': name,
      'description': description,
      'price': price,
      'units': units,
      'user': userId,
    };

    try {
      print(productData);
      // ApiResponse response = await ProductService.addProduct(productData);
      Get.offAll(CreateProductImage(productData: productData));
    } catch (e) {
      Get.snackbar(
        "Error",
        "Algo falló al intentar publicar el producto",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class AnimationFarmer extends StatelessWidget {
  const AnimationFarmer({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Lottie.asset(
        "assets/json/AnimationFarmer1.json",
      ),
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        margin: EdgeInsets.only(left: 20.0),
        child: Text(
          "¡Cuentanos mas!",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}

class DescriptionText extends StatelessWidget {
  const DescriptionText({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 20.0, right: 20.0, bottom: 5),
        child: Text(
          "Queremos que nos cuentes todo para dar a conocer tu producto",
          style: TextStyle(
            color: Theme.of(context).shadowColor,
            fontSize: 20,
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}

class NameTextField extends StatefulWidget {
  final CreateProductController createProductController;

  NameTextField({required this.createProductController});

  @override
  _NameTextFieldState createState() =>
      _NameTextFieldState(createProductController: createProductController);
}

class _NameTextFieldState extends State<NameTextField> {
  final CreateProductController createProductController;

  _NameTextFieldState({required this.createProductController});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 200),
      child: RepTextFiled(
        controller: createProductController.nameController,
        icon: LineIcons.carrot,
        text: "Producto",
      ),
    );
  }
}

class DescriptionTextField extends StatelessWidget {
  final CreateProductController createProductController;

  DescriptionTextField({required this.createProductController});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 225),
      child: RepTextFiled(
        icon: LineIcons.archive,
        text: "Descripción",
        controller: createProductController.descriptionController,
      ),
    );
  }
}

class PriceTextField extends StatelessWidget {
  final CreateProductController createProductController;

  PriceTextField({required this.createProductController});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 225),
      child: RepTextFiled(
        icon: LineIcons.moneyBill,
        text: "Precio",
        controller: createProductController.priceController,
      ),
    );
  }
}

class UnitsTextField extends StatelessWidget {
  final CreateProductController createProductController;

  UnitsTextField({required this.createProductController});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 225),
      child: RepTextFiled(
        icon: LineIcons.sortNumericDown,
        text: "Unidades",
        controller: createProductController.unitsController,
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final CreateProductController createProductController;

  SaveButton({required this.createProductController});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 150),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 100),
        width: gWidth,
        height: gHeight / 15,
        child: ElevatedButton(
          onPressed: () {
            createProductController.addProduct(context);
          },
          child: Text(
            "Continuar",
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
      ),
    );
  }
}
