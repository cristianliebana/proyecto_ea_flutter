import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/product_detail.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/rep_textfiled.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  EditProductScreen({required this.productId});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool? _isSold;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _unitsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  Future<void> _fetchProductData() async {
    setState(() => _isLoading = true);
    ApiResponse response =
        await ProductService.getProductById(widget.productId);
    if (response.statusCode == 200) {
      var productData = response.data;
      _nameController.text = productData['name'] ?? '';
      _descriptionController.text = productData['description'] ?? '';
      _priceController.text = productData['price'].toString();
      _unitsController.text = productData['units'].toString();
       if (productData.containsKey('sold')) {
      setState(() {
        _isSold = productData['sold'];
      });
    } else {
      // Si 'sold' no está presente, deja _isSold como null
      setState(() {
        _isSold = null;
      });
    }
  }  else {
      Get.snackbar('Error', 'Failed to fetch product details');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateProductDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String? userId = await UserService.getUserId();
      if (userId == null) {
        Get.snackbar('Error', 'User not found');
        return;
      }

      Map<String, dynamic> updatedProduct = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'units': int.parse(_unitsController.text),
        'sold': _isSold,
        'user': userId,     
      };

      ApiResponse response =
          await ProductService.updateProduct(widget.productId, updatedProduct);
      setState(() => _isLoading = false);

      if (response.statusCode == 201) {
        showUpdateSuccessDialog(context);
      } else {
        Get.snackbar('Error', 'Failed to update product');
      }
    }
  }

  void showUpdateSuccessDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Success',
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
                  'Product Updated Successfully',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ),
      ),
      radius: 10.0,
      confirm: ElevatedButton(
        onPressed: () {
          Get.offAll(() => ProductDetailScreen(productId: widget.productId));
        },
        child: Text(
          'OK',
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
  }

  void _showSoldMessage(BuildContext context) {
  Get.defaultDialog(
    title: 'sold'.tr,
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
                'checkbox'.tr,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      ),
    ),
    radius: 10.0,
    confirm: ElevatedButton(
      onPressed: () {
        Get.back();
      },
      child: Text(
        'OK',
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
          Get.back();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        AnimationEdit(),
                        RepTextFiled(
                          icon: Icons.edit,
                          text: 'nombreProducto'.tr,
                          controller: _nameController,
                          obscureText: false,
                        ),
                        SizedBox(height: 20),
                        RepTextFiled(
                          icon: Icons.description,
                          text: 'descripcion'.tr,
                          controller: _descriptionController,
                          obscureText: false,
                        ),
                        SizedBox(height: 20),
                        RepTextFiled(
                          icon: Icons.euro_symbol,
                          text: 'precio'.tr,
                          controller: _priceController,
                          obscureText: false,
                        ),
                        SizedBox(height: 20),
                        RepTextFiled(
                          icon: Icons.storage,
                          text: 'unidades'.tr,
                          controller: _unitsController,
                          obscureText: false,
                        ),
                        SizedBox(height: 20),
                        CheckboxListTile(
                        checkColor: Colors.white, 
                        activeColor: Theme.of(context).primaryColor,
                        title: Text('vendido'.tr,
                        style: TextStyle(
                          color: text1Color
                          ),),
                        
                        value: _isSold,
                        onChanged: (value) {
                          setState(() {
                            _isSold = value ?? false;
                             if (_isSold!) {
                            _showSoldMessage(context);
                            _updateProductDetails;
                            }
                          });
                        },
                      ),
                        ElevatedButton(
                          onPressed: _updateProductDetails,
                          child: Text('updateProduct'.tr),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.onPrimary),
                            foregroundColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class AnimationEdit extends StatelessWidget {
  const AnimationEdit({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Lottie.asset(
        "assets/json/edit.json",
      ),
    );
  }
}
