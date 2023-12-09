import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:latlong2/latlong.dart';
import 'package:animate_do/animate_do.dart';
import 'package:proyecto_flutter/screens/create_product_detail.dart';
import 'package:proyecto_flutter/screens/create_product_image.dart';
import 'package:proyecto_flutter/utils/constants.dart';

class CreateProductLocation extends StatefulWidget {
  final Map<String, dynamic> productData;

  CreateProductLocation({Key? key, required this.productData})
      : super(key: key);

  @override
  _CreateProductLocationState createState() => _CreateProductLocationState();
}

class _CreateProductLocationState extends State<CreateProductLocation> {
  LatLng _currentLocation = LatLng(41.2731, 1.9865);
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentUserLocation();
  }

  Future<void> _getCurrentUserLocation() async {
    LatLng location = await _getUserLocation();
    setState(() {
      _currentLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildBackButton(),
        ],
      ),
      floatingActionButton: _buildLocationButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMap() {
    return FadeInDown(
      delay: Duration(milliseconds: 150),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _currentLocation,
          zoom: 13.0,
          onTap: (TapPosition tapPosition, LatLng latLng) {
            _handleMapTap(latLng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: _currentLocation,
                builder: (ctx) => Icon(
                  Icons.location_pin,
                  color: Color(0xFF486D28),
                  size: 40.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMapTap(LatLng tappedPoint) {
    setState(() {
      _currentLocation = tappedPoint;
    });
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 8.0,
      left: 8.0,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF486D28),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xFFFFFCEA),
          ),
          onPressed: () {
            Get.to(CreateProductDetail(
              productName: '',
            ));
          },
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return FloatingActionButton(
      onPressed: () {
        _getCurrentUserLocation();
        _mapController.move(_currentLocation, 13.0);
      },
      child: Icon(Icons.my_location),
      backgroundColor: Color(0xFF486D28),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {
          widget.productData['location'] = {
            'latitude': _currentLocation.latitude,
            'longitude': _currentLocation.longitude,
          };
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CreateProductImage(productData: widget.productData)),
          );
        },
        child: Text(
          "Guardar Ubicación",
          style: TextStyle(fontSize: 20),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(buttonColor),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Future<LatLng> _getUserLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      return LatLng(0.0, 0.0);
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }
}
