// ignore_for_file: file_names, unused_local_variable

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/api/models/product_model.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto_flutter/screens/map.dart';

class MapPageBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final userId = sharedPreferences.getString('userId');

    final bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      return;
    }

    final Position? currentPosition = await _getCurrentPosition();
    final MapPageController mapPageController = Get.put(MapPageController());

    if (currentPosition != null) {
      mapPageController.currentPosition.value = currentPosition;
    } else {
    }

    try {
      final List<Product> productList = await ProductService.getProducts(1);
      mapPageController.listProducts.assignAll(productList);
    } catch (e) {
      debugPrint('Error fetching products: ${e.toString()}');
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return position;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
