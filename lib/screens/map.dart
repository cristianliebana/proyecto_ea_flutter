import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/screens/product_detail.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/models/product_model.dart';

class MapPageController extends GetxController {
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxList<Product> listProducts = RxList<Product>([]);

  @override
  void onInit() {
    super.onInit();
    checkAuthAndNavigate();
    loadProducts();
  }

  Future<void> checkAuthAndNavigate() async {
    await TokenService.loggedIn();
  }

  Future<void> loadProducts() async {
    try {
      bool morePagesAvailable = true;
      int currentPage = 1;

      while (morePagesAvailable) {
        var products = await ProductService.getProducts(currentPage);

        if (products.isNotEmpty) {
          listProducts.addAll(products);
          currentPage++;
        } else {
          morePagesAvailable = false;
        }
      }
    } catch (e) {
      print("Error loading products: $e");
    }
  }
}

class MapPageView extends StatefulWidget {
  const MapPageView({Key? key});

  @override
  _MapPageViewState createState() => _MapPageViewState();
}

class _MapPageViewState extends State<MapPageView> {
  final MapPageController controller = Get.put(MapPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1),
      body: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 9,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 9,
                      child: buildMap(),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Marker createProductMarker(Product product) {
    final latitude = product.location?.latitude;
    final longitude = product.location?.longitude;

    return Marker(
      width: 30.0,
      height: 30.0,
      point: LatLng(latitude ?? 41.2833, longitude ?? 1.9667),
      builder: (ctx) => GestureDetector(
        onTap: () {
          if (product.id != null) {
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailScreen(productId: product.id!),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: product.productImage != null &&
                      product.productImage!.isNotEmpty
                  ? NetworkImage(product.productImage!.first)
                  : AssetImage('assets/images/profile.png')
                      as ImageProvider, // Use the image URL
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMap() {
    final currentPosition = controller.currentPosition.value;

    final fallbackPosition =
        LatLng(41.2833, 1.9667);
    LatLng mapCenter;
    if (currentPosition != null) {
      mapCenter = LatLng(currentPosition.latitude, currentPosition.longitude);
    } else {
      mapCenter = fallbackPosition;
    }

    final markers = controller.listProducts.map((product) {
      return createProductMarker(product);
    }).toList();

    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: mapCenter,
        builder: (ctx) => const Icon(
          Icons.my_location,
          size: 30.0,
          color: Color(0xFF486D28),
        ),
      ),
    );

    return FlutterMap(
      options: MapOptions(
        center: mapCenter,
        zoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: markers,
        ),
      ],
    );
  }
}
