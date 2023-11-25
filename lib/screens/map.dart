import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';

class MapPageView extends StatelessWidget {
  final Future<LatLng> currentPositionFuture;

  const MapPageView({Key? key, required this.currentPositionFuture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFCEA),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1),
      body: FutureBuilder<LatLng>(
        future: currentPositionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error fetching location"));
          } else if (snapshot.hasData) {
            return buildMapView(context, snapshot.data);
          } else {
            return Center(child: Text("No data available"));
          }
        },
      ),
    );
  }

  Widget buildMapView(BuildContext context, LatLng? currentPosition) {
    var markers = <Marker>[];
    if (currentPosition != null) {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: currentPosition,
          builder: (ctx) => Container(
            child: Icon(Icons.location_pin, color: Color(0xFF486D28), size: 40.0),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 50),
        const SizedBox(height: 20),
        Expanded(
          flex: 9,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            margin: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FlutterMap(
                options: MapOptions(
                  center: currentPosition ?? LatLng(41.2731, 1.9865),
                  zoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
