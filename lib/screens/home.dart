import 'package:flutter/material.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    checkAuthAndNavigate();
  }

  Future<void> checkAuthAndNavigate() async {
    await TokenService.loggedIn();
  }

  void _onRemoveTokenPressed() {
    TokenService.removeToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Inicio'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onRemoveTokenPressed,
              child: Text('Remove Token'),
            ),
          ],
        ),
      ),
    );
  }
}
