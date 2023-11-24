// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/screens/map.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class MapPageBinding extends Bindings {
  @override
  Future<void> dependencies() async {

    //final sharedPreferences = await SharedPreferences.getInstance();
    //final userId = sharedPreferences.getString('userId');

    final bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      // ignore: avoid_print
      print("Location permission denied.");
      return;
    }

    final Position? currentPosition = await _getCurrentPosition();

    if (currentPosition != null) {
      final MapPageController mapFieldsController = Get.find<MapPageController>();
      mapFieldsController.currentPosition.value = currentPosition;
    } else {
      // ignore: avoid_print
      print("Current position is null.");
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
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
          content: Text('Location permissions are permanently denied, we cannot request permissions.')));
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