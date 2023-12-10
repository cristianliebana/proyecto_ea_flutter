import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:proyecto_flutter/api/services/rating_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/chat.dart';

class ReviewScreen extends StatefulWidget {
  final String userId2;

  ReviewScreen({required this.userId2});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? userData2;
  TextEditingController commentController = TextEditingController();
  double ratingValue = 3.5; // Valor inicial del rating

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
    obtenerDatosUsuario2(widget.userId2);
  }

  Future<void> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    setState(() {
      userData = response.data;
    });
  }

  Future<void> obtenerDatosUsuario2(String userId) async {
    ApiResponse response = await UserService.getCreadorById(userId);
    setState(() {
      userData2 = response.data;
    });
  }

  void enviarValoracion() async {
    print('Enviando valoración...');

    String comentario = commentController.text;

    // Crear un mapa con los datos de la valoración
    Map<String, dynamic> ratingData = {
      'userId1': userData!['_id'],
      'userId2': userData2!['_id'],
      'rating': ratingValue,
      'comment': comentario,
    };

    try {
      ApiResponse response = await RatingService.createRating(ratingData);
      ApiResponse response2 =
          await RatingService.updateAverageRating(userData2!['_id']);
      Get.defaultDialog(
        title: "¡Felicidades!",
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
              child: Container(
                decoration: BoxDecoration(
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
                      "¡Acabas de publicar tu valoración!",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        radius: 10.0,
        confirm: ElevatedButton(
          onPressed: () {
            Get.to(ChatPage());
          },
          child: Text(
            "Aceptar",
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
    } catch (e) {
      Get.snackbar(
        "Error",
        "Algo falló al intentar publicar el producto",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ReviewFarmer(),
            TitleText(),
            UserInfo(userData2: userData2),
            Rating(
              ratingValue: ratingValue,
              onRatingUpdate: (rating) {
                setState(() {
                  ratingValue = rating;
                });
              },
            ),
            CommentText(),
            CommentBox(commentController: commentController),
            SendButton(onPressed: enviarValoracion),
          ],
        ),
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final VoidCallback onPressed;

  SendButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Ocupar todo el ancho disponible
      margin: EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 10), // Ajusta el margen horizontal y vertical
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          "Mandar valoración",
          style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.primary), // Tamaño del texto
        ),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
              EdgeInsets.all(20)), // Ajusta el relleno del botón
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}

class CommentBox extends StatelessWidget {
  const CommentBox({
    super.key,
    required this.commentController,
  });

  final TextEditingController commentController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: TextField(
          controller: commentController,
          maxLines: 8,
          decoration: InputDecoration(
            labelText: 'Deja tu comentario',
            labelStyle: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onPrimary), // Color del labelText
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary), // Color del borde
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary), // Color del borde cuando está enfocado
            ),
          ),
        ),
      ),
    );
  }
}

class Rating extends StatelessWidget {
  const Rating({
    Key? key,
    required this.ratingValue,
    required this.onRatingUpdate,
  });

  final double ratingValue;
  final ValueChanged<double> onRatingUpdate;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          InfoText(),
          SizedBox(height: 5),
          Center(
            child: RatingBar(
              ignoreGestures: false,
              initialRating: 3.5,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              ratingWidget: RatingWidget(
                full: Image.asset('assets/ratingimages/zanahoriaentera.png'),
                half: Image.asset('assets/ratingimages/mediazanahoria.png'),
                empty: Image.asset('assets/ratingimages/zanahoriavacia.png'),
              ),
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              onRatingUpdate: onRatingUpdate,
            ),
          ),
        ],
      ),
    );
  }
}

class CommentText extends StatelessWidget {
  const CommentText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "Deja un comentario:",
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor),
    );
  }
}

class InfoText extends StatelessWidget {
  const InfoText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "Puntua del 0 al 5:",
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor),
    );
  }
}

class UserInfo extends StatelessWidget {
  const UserInfo({
    Key? key,
    required this.userData2,
  });

  final Map<String, dynamic>? userData2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: userData2?['profileImage'] != null
                ? NetworkImage(userData2!['profileImage']!)
                : AssetImage('assets/images/profile.png')
                    as ImageProvider<Object>,
          ),
          SizedBox(width: 16),
          Text(
            userData2 != null ? userData2!['username'] : 'Nombre del Usuario',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
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
      child: Center(
        child: Text(
          "¿Cómo puntuarías a..?",
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

class ReviewFarmer extends StatelessWidget {
  const ReviewFarmer({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: Lottie.asset(
        "assets/json/review.json",
      ),
    );
  }
}
