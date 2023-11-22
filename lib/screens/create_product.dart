import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:proyecto_flutter/screens/create_product_detail.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';
import 'package:proyecto_flutter/widget/rep_textfiled.dart';
import 'package:get/get.dart';

class CreateProduct extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 2),
      body: Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 140),
          AnimationFarmer(),
          TitleText(),
          DescriptionText(),
          TitleTextFiled(),
          SampleText(),
          SizedBox(height: 30),
          FormButton(),
        ]),
      ),
    );
  }
}

class FormButton extends StatelessWidget {
  const FormButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 100),
      width: gWidth,
      height: gHeight / 15,
      child: ElevatedButton(
        onPressed: () async {
          Get.to(CreateProductDetail());
        },
        child: Text(
          "Continuar",
          style: TextStyle(fontSize: 25),
        ),
        style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(buttonColor)),
      ),
    );
  }
}

class SampleText extends StatelessWidget {
  const SampleText({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
          margin: EdgeInsets.only(left: 78.0),
          child: Text(
            "Ejemplo: Plátano de Canarias",
            style: TextStyle(
              color: Color.fromARGB(255, 99, 99, 99),
              fontSize: 12,
            ),
            textAlign: TextAlign.justify,
          )),
    );
  }
}

class TitleTextFiled extends StatelessWidget {
  const TitleTextFiled({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
        child:
            RepTextFiled(icon: LineIcons.carrot, text: "Título del producto"));
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
          margin: EdgeInsets.all(20.0),
          child: Text(
            "Los buenos títulos presentan el producto y sus detalles clave en pocas palabras.",
            style: TextStyle(
              color: Color.fromARGB(255, 99, 99, 99),
              fontSize: 20,
            ),
            textAlign: TextAlign.justify,
          )),
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
          margin: EdgeInsets.only(top: 10, left: 20.0),
          child: Text(
            "¿Qué vas a vender?",
            style: TextStyle(
                color: Colors.black, fontSize: 35, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          )),
    );
  }
}

class AnimationFarmer extends StatelessWidget {
  const AnimationFarmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Lottie.asset(
        "assets/json/animationGranjero.json",
      ),
    );
  }
}
