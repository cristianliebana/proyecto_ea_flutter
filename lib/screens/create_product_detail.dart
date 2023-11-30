import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:animate_do/animate_do.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/home.dart';
import 'package:proyecto_flutter/screens/login.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/rep_textfiled.dart';

class CreateProductDetail extends StatefulWidget {
  final String productName;
  const CreateProductDetail({Key? key, required this.productName, req}) : super(key: key);

  @override
  _CreateProductDetailState createState() => _CreateProductDetailState();
}
class _CreateProductDetailState extends State<CreateProductDetail> {
  Map<String, dynamic> userData = {};
   late CreateProductController createProductController;

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
  }

  Future<void> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    Map<String, dynamic> userData = response.data;
    print("User Data: $userData");

    createProductController = CreateProductController(userData: userData);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
  createProductController.nameController.text = widget.productName; // S// Set the product name
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.all(15),
          width: gWidth,
          height: gHeight,
          child: Column(
            children: [
              SizedBox(height: 10),
              NameTextField(createProductController: createProductController),
              SizedBox(height: 10),
              DescriptionTextField(createProductController: createProductController),
              SizedBox(height: 10),
              PriceTextField(createProductController: createProductController),
              SizedBox(height: 10),
              UnitsTextField(createProductController: createProductController),
              SizedBox(height: 10),
              SaveButton(createProductController: createProductController),
            ],
          ),
        ),
      ),
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
    String ?name = nameController.text;
    String ?description = descriptionController.text;
    int? units = int.tryParse(unitsController.text);
    double? price = double.tryParse(priceController.text);
   String? userId = userData['_id'] ?? '';

    if (name.isEmpty || units == null || price == null) {
      Get.snackbar(
        "Error",
        "Invalid input. Please check the product details.",
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
      ApiResponse response = await ProductService.addProduct(productData);
      Get.offAll(() => HomePage());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add product. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
            "Añadir Producto",
            style: TextStyle(fontSize: 25),
          ),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(buttonColor),
          ),
        ),
      ),
    );
  }
}