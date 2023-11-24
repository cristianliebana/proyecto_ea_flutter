// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
//import 'package:get/get.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';

class MapPageView extends StatelessWidget {
  const MapPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 50),
          const SizedBox(height: 20),
          Expanded(
            flex: 9,
            child: FlutterMap(
              options: MapOptions(
                // Set a default center (e.g., center of a city)
                center: LatLng(37.7749, -122.4194),
                zoom: 10,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
