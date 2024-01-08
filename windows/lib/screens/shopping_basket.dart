import 'package:flutter/material.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';

class ShoppingBasketPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text('Cesta')],
        ),
      ),
    );
  }
}
