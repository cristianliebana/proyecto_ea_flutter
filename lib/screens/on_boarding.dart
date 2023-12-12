import 'package:flutter/material.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:proyecto_flutter/screens/home.dart';

class ConcentricTransitionPage extends StatefulWidget {
  const ConcentricTransitionPage({Key? key}) : super(key: key);

  @override
  State<ConcentricTransitionPage> createState() =>
      _ConcentricTransitionPageState();
}

class _ConcentricTransitionPageState extends State<ConcentricTransitionPage> {
  List<ConcentricModel> concentrics = [
    ConcentricModel(
      lottie: "assets/assets/onboard/hello.json",
      text: "¡Bienvenido a\nKM.0 Market!",
    ),
    ConcentricModel(
      lottie: "assets/assets/onboard/productos.json",
      text: "Aquí podrás publicar\ny encontrar productos frescos de proximidad",
    ),
    ConcentricModel(
      lottie: "assets/assets/onboard/like.json",
      text: "Guarda tus productos\nfavoritos y contacta\ncon el vendedor",
    ),
    ConcentricModel(
      lottie: "assets/assets/onboard/opiniones.json",
      text: "Tienes la opción de compartir opiniones mediante reseñas 🚀",
    ),
    ConcentricModel(
      lottie: "assets/assets/onboard/mapa.json",
      text: "¡Explora nuevos productos con el mapa!",
    ),
    ConcentricModel(
      lottie: "assets/assets/onboard/mundo.json",
      text:
          "¡Dale vida a los productos próximos a caducar!\n¡Juntos, ayudaremos al mundo!",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ConcentricPageView(
          onChange: (val) {},
          colors: <Color>[
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.onPrimary,
          ],
          itemCount: concentrics.length,
          onFinish: () {
            Get.to(HomePage());
          },
          itemBuilder: (int index) {
            return Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, right: 20),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(HomePage());
                      },
                      child: Text(
                        "Saltar",
                        style: TextStyle(
                          color: (index == 1 ||
                                  index == 3 ||
                                  index == 5) // Cambiado: Ajuste de condiciones
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w300,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 290,
                  width: 300,
                  child: Lottie.network(
                    concentrics[index].lottie,
                    animate: true,
                  ),
                ),
                Text(
                  concentrics[index].text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: (index == 0 ||
                            index == 2 ||
                            index == 4) // Cambiado: Ajuste de condiciones
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    "${index + 1} / ${concentrics.length}",
                    style: TextStyle(
                      color: (index == 0 ||
                              index == 2 ||
                              index == 4) // Cambiado: Ajuste de condiciones
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w400,
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ConcentricModel {
  String lottie;
  String text;

  ConcentricModel({
    required this.lottie,
    required this.text,
  });
}
