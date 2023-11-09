import 'package:flutter/material.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';
// Importa el archivo nav_bar.dart

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text('Chat')],
        ),
      ),
    );
  }
}
