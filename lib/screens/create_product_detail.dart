// ignore_for_file: unused_import

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/create_product.dart';
import 'package:proyecto_flutter/screens/create_product_image.dart';
import 'package:proyecto_flutter/screens/create_product_location.dart';
import 'package:proyecto_flutter/screens/user_products.dart';
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
  DateTime selectedDate = DateTime.now();
  bool sold = false;

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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<CreateProductController?>(
      future: _controllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('Data is null'));
        }

        CreateProductController createProductController = snapshot.data!;
        createProductController.nameController.text = widget.productName;

        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: _buildAppBar(),
            body: Container(
              margin: EdgeInsets.all(screenWidth * 0.03), // Responsive margin
              width: screenWidth,
              height: screenHeight,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimationFarmer(),
                    TitleText(),
                    DescriptionText(),
                    NameTextField(
                      createProductController: createProductController,
                    ),
                    SizedBox(height: 10),
                    DescriptionTextField(
                      createProductController: createProductController,
                    ),
                    SizedBox(height: 10),
                    PriceTextField(
                      createProductController: createProductController,
                    ),
                    SizedBox(height: 10),
                    UnitsTextField(
                      createProductController: createProductController,
                    ),
                    SizedBox(height: 20),
                    _buildDatePicker(createProductController),
                    SizedBox(height: 20),
                    SaveButton(createProductController: createProductController, sold: sold),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(CreateProductController createProductController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: const Text("¿Cuándo caduca?"),
          onPressed: () async {
            final DateTime? dateTime = await showDatePicker(
              context: context,
              initialDate:
                  createProductController.selectedDate.value,
              firstDate: DateTime(2024),
              lastDate: DateTime(2025),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary:
                          Theme.of(context).colorScheme.onPrimary,
                      onPrimary:
                          Theme.of(context).colorScheme.primary,
                      onSurface: Theme.of(context).primaryColor,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .onPrimary,
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (dateTime != null &&
                dateTime !=
                    createProductController.selectedDate.value) {
              createProductController.selectedDate.value =
                  dateTime;
            }
          },
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).colorScheme.onPrimary, // Background color of the button
            onPrimary: Theme.of(context).colorScheme.primary, // Text color of the button
          ),
        ),
        SizedBox(width: 20),
        Obx(() => Text(
              'Fecha seleccionada: ${createProductController.selectedDate.value.toLocal()}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
              ),
            )),
      ],
    );
  }

}

class CreateProductController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController unitsController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  Rx<DateTime> selectedDate = DateTime.now().obs;

  Map<String, dynamic> userData;
  CreateProductController({required this.userData});

  void addProduct(BuildContext context, bool sold) async {
    String? name = nameController.text;
    String? description = descriptionController.text;
    int? units = int.tryParse(unitsController.text);
    double? price = double.tryParse(priceController.text);
    String? userId = userData['_id'] ?? '';
    DateTime date = selectedDate.value;
    bool sold = false;

    if (name.isEmpty || units == null || price == null) {
      Get.snackbar(
        "Error",
        'debes de'.tr,
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
      'date': date,
      'sold': sold,
    };

    try {
      print(productData);
      Get.offAll(CreateProductLocation(productData: productData));
    } catch (e) {
      Get.snackbar(
        "Error",
        'algofallo'.tr,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(left: screenWidth * 0.05), // Adjusted margin
      child: Text(
        'cuentanos mas'.tr,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: screenWidth * 0.08, // Responsive font size
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}

class DescriptionText extends StatelessWidget {
  const DescriptionText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(
        top: screenWidth * 0.02,
        left: screenWidth * 0.05,
        right: screenWidth * 0.05,
        bottom: screenWidth * 0.01,
      ), // Adjusted margins relative to screen width
      child: Text(
        'queremos'.tr,
        style: TextStyle(
          color: Theme.of(context).shadowColor,
          fontSize: screenWidth * 0.045, // Responsive font size
        ),
        textAlign: TextAlign.justify,
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
    // Get screen dimensions for responsive design
    double screenWidth = MediaQuery.of(context).size.width;

    return FadeInDown(
      delay: Duration(milliseconds: 200),
      child: RepTextFiled(
        controller: createProductController.nameController,
        icon: LineIcons.carrot,
        text: 'producto'.tr,
        // Add properties related to sizing, padding, etc., that scale with screenWidth
        // Example: fontSize: screenWidth * 0.04
        // Other properties like padding, margin, or text field size can also be adjusted similarly
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
        text: 'descripcion'.tr,
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
        text: 'precio'.tr,
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
        text: 'unidades'.tr,
        controller: createProductController.unitsController,
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final CreateProductController createProductController;
  final bool sold;

  SaveButton({required this.createProductController, required this.sold});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return FadeInDown(
      delay: Duration(milliseconds: 150),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.2), // Responsive margin
        width: double.infinity, // Full width of the parent container
        height: screenHeight * 0.07, // Responsive height
        child: ElevatedButton(
          onPressed: () {
            createProductController.addProduct(context, sold);
          },
          child: Text(
            'continuar'.tr,
            style: TextStyle(
              fontSize: screenWidth * 0.05, // Responsive font size
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
