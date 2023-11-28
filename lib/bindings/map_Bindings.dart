import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:proyecto_flutter/screens/map.dart';

class MapPageBinding extends Bindings {
  bool _requestedNavigation = false;

  @override
  Future<void> dependencies() async {
    if (_requestedNavigation) {
      Get.to(() => MapPageView(
          currentPositionFuture: _getPositionFuture()
      ));
    }
  }

  void requestNavigation() {
    _requestedNavigation = true;
    dependencies();
  }

  Future<LatLng> _getPositionFuture() async {
    final bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      return LatLng(41.2731, 1.9865);
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint(e.toString());
      return LatLng(41.2731, 1.9865);
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
      ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
        content: Text('Location permissions are denied. You can still view the map.')));
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
}

