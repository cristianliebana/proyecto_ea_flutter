import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
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
    loadProducts();
  }

void loadProducts() async {
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
  const MapPageView({super.key});

  @override
  _MapPageViewState createState() => _MapPageViewState();
}

class _MapPageViewState extends State<MapPageView>{
  final MapPageController controller = Get.put(MapPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 50),
          Expanded(
            flex: 9,
            child: Row(children: <Widget>[
              Expanded(
                flex: 9,
                child: Obx(() {
                  final currentPosition = controller.currentPosition.value;
                  if (currentPosition == null) {
                    return Center(
                      child: Text('noLocation'.tr),
                    );
                  }

                  final markers = controller.listProducts.map((product) {
                    final latitude = product.location?.latitude;
                    final longitude = product.location?.longitude;

                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(latitude ?? 41.2833, longitude ?? 1.9667),
                      builder: (ctx) => GestureDetector(
                        onTap: () {
                          if (product.id != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(productId: product.id!),
                              ),
                            );
                          }
                        },
                        child: const Icon(
                          Icons.location_on,
                          size: 30.0,
                          color: Color(0xFF486D28),
                        ),
                      ),
                    );
                  }).toList();

                  markers.add(
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(currentPosition.latitude, currentPosition.longitude),
                      builder: (ctx) => const Icon(
                        Icons.my_location,
                        size: 30.0,
                        color: Color(0xFF486D28),
                      ),
                    ),
                  );

                  return FlutterMap(
                    options: MapOptions(
                      center: LatLng(currentPosition.latitude, currentPosition.longitude),
                      zoom: 10,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: markers
                      )
                    ],
                  );
                }),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

