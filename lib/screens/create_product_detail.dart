import 'package:flutter/material.dart';
import 'package:proyecto_flutter/api/models/product_model.dart';
import 'package:proyecto_flutter/utils/constants.dart';

class CreateProductDetail extends StatefulWidget {
  final String productName;

  CreateProductDetail({required this.productName});

  @override
  _CreateProductDetailState createState() => _CreateProductDetailState();
}

class _CreateProductDetailState extends State<CreateProductDetail> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController unitsController = TextEditingController();

  TextStyle labelTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    print('productName in CreateProductDetail: ${widget.productName}');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create a Product',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF486D28),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              'Product Name: ${widget.productName.isNotEmpty ? widget.productName : 'N/A'}',
              style: labelTextStyle,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: labelTextStyle,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price',
                labelStyle: labelTextStyle,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: unitsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Units',
                labelStyle: labelTextStyle,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Product newProduct = Product(
                  id: '',
                  name: widget.productName,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                  units: int.tryParse(unitsController.text) ?? 0,
                );
                print('New Product Details: $newProduct');
              },
              child: Text('Save Product', style: buttonTextStyle),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(buttonColor),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


