import 'package:flutter/material.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';
// Importa el archivo nav_bar.dart

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text('Inicio')],
        ),
      ),
    );
  }
}
