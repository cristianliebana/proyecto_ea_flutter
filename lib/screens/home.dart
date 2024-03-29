import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:proyecto_flutter/api/models/product_model.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/screens/product_detail.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';

class HomePage extends StatefulWidget {
  String selectedFilter =
      'Nombre'.tr; // Puedes establecer un valor predeterminado
  double maxDistance = 100.0;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Product> productList = [];
  late List<Product> productListOferta = [];
  late List<Product> filteredList = [];
  late ScrollController _scrollController;
  late List<Product> productListbyDistance = [];
  late List<Product> filteredByDistanceList = [];
  bool _loading = false;
  TextEditingController _searchController = TextEditingController();
  LatLng _currentLocation = LatLng(41.2731, 1.9865);

  final List locale = [
    {'name': 'Español', 'locale': Locale('es')},
    {'name': 'English', 'locale': Locale('en')},
  ];
  updateLanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
  }

  buildLanguageDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            title: Text('Choose Your Language'),
            content: Container(
              width: double.maxFinite,
              child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Text(locale[index]['name']),
                        onTap: () {
                          print(locale[index]['name']);
                          updateLanguage(locale[index]['locale']);
                        },
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      color: Colors.blue,
                    );
                  },
                  itemCount: locale.length),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    checkAuthAndNavigate();
    _scrollController = ScrollController()..addListener(_scrollListener);
    fetchProducts();
    fetchProductsOferta();
  }

  Future<void> checkAuthAndNavigate() async {
    await TokenService.loggedIn();
  }

  Future<void> fetchProducts() async {
    int page = 1;
    List<Product> products = await ProductService.getProducts(page);

    // Filtrar solo productos no vendidos
    products = products.where((product) => product.sold == false).toList();

    setState(() {
      productList = products;
      filteredList =
          products; // Inicializa la lista filtrada con todos los productos
    });
  }

  Future<void> fetchProductsOferta() async {
    List<Product> products = await ProductService.getProductsOferta();

    // Filtrar solo productos no vendidos
    products = products.where((product) => product.sold == false).toList();

    setState(() {
      productListOferta = products;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (!_loading) {
      setState(() {
        _loading = true;
      });

      int nextPage = (productList.length / 50).ceil() + 1;
      List<Product> nextPageProducts =
          await ProductService.getProducts(nextPage);

      // Filtrar solo productos no vendidos
      nextPageProducts =
          nextPageProducts.where((product) => product.sold == false).toList();

      setState(() {
        productList.addAll(nextPageProducts);
        _applyFilter(); // Aplicar el filtro actual
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      if (widget.selectedFilter == 'Nombre'.tr) {
        filteredList = productList
            .where((product) =>
                product.name
                    ?.toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ??
                false)
            .toList();
      } else if (widget.selectedFilter == 'Precio'.tr) {
        _filterProductsByPrice(_searchController.text);
      } else if (widget.selectedFilter == 'Distancia'.tr) {
        double? maxDistance = double.tryParse(_searchController.text);
        _filterProductsbyDistance(maxDistance!);
      }
    });
  }

  void _filterProducts(String searchTerm) {
    setState(() {
      if (widget.selectedFilter == 'Nombre'.tr) {
        filteredList = productList
            .where((product) =>
                product.name
                    ?.toLowerCase()
                    .contains(searchTerm.toLowerCase()) ??
                false)
            .toList();
      } else if (widget.selectedFilter == 'Precio'.tr) {
        _resetFilteredList();
        _filterProductsByPrice(searchTerm);
      } else if (widget.selectedFilter == 'Distancia'.tr) {
        _resetFilteredList();
        double? maxDistance = double.tryParse(searchTerm);
        _filterProductsbyDistance(maxDistance!);
      }
    });
  }

  void _resetFilteredList() {
    setState(() {
      filteredList = productList;
    });
  }

  void _filterProductsbyDistance(double maxDistance) {
    setState(() {
      filteredList = productList
          .where((product) => _calculateDistance(product) <= maxDistance)
          .toList();
    });
  }

  void _filterProductsByPrice(String searchTerm) {
    double? maxPrice = double.tryParse(searchTerm);
    if (maxPrice != null) {
      filteredList = productList
          .where(
              (product) => product.price != null && product.price! <= maxPrice)
          .toList();
    }
  }

  double calculateDistance(
      double lat1, double lon1, double? lat2, double? lon2) {
    const R = 6371.0; // Radio de la Tierra en kilómetros
    final dLat = _toRadians(lat2! - lat1);
    final dLon = _toRadians(lon2! - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2!)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));

    return R * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  double _calculateDistance(Product product) {
    final productLatitude = product.location?.latitude ?? 0.0;
    final productLongitude = product.location?.longitude ?? 0.0;

    return calculateDistance(
      _currentLocation.latitude,
      _currentLocation.longitude,
      productLatitude,
      productLongitude,
    );
  }

  void _handleFilterChanged(String newFilter) {
    setState(() {
      widget.selectedFilter = newFilter;
    });
  }

  Future<void> _getCurrentUserLocation() async {
    LatLng location = await _getUserLocation();
    setState(() {
      _currentLocation = location;
    });
  }

  Future<LatLng> _getUserLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      return LatLng(0.0, 0.0);
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    int gridCrossAxisCount = screenWidth > 600 ? 3 : 2; // 3 columns for wider screens, 2 for narrower

    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: screenHeight * 0.04), // Adjusted height
              SearchBar(
                onSearch: _filterProducts,
                searchController: _searchController,
                selectedFilter: 'Nombre'.tr,
                onFilterChanged: _handleFilterChanged,
              ),
            ]),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Visibility(
                visible: productListOferta.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Ensuring alignment
                  children: [
                    SizedBox(height: screenHeight * 0.02), // Adjusted height based on screen size
                    TopText(),
                    SizedBox(height: screenHeight * 0.01), // Adjusted height based on screen size
                  ],
                ),
              ),
              Visibility(
                visible: productListOferta.isNotEmpty,
                child: Container(
                  width: screenWidth, // Adjusted width based on screen size
                  child: ProductsHorizontal(
                    productListOferta: productListOferta,
                    userLocation: _currentLocation,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01), // Adjusted height based on screen size
              MidText(), // Ensure MidText is aligned similarly to TopText
              SizedBox(height: screenHeight * 0.00625),
            ]),
          ), 
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridCrossAxisCount, // Adjusted dynamically
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.9, // You can adjust this based on your content
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < filteredList.length) {
                  return ProductsVerticalItem(
                    product: filteredList[index],
                    userLocation: _currentLocation,
                  );
                } else {
                  return _loading ? CircularProgressIndicator() : Container();
                }
              },
              childCount: filteredList.length + 1,
            ),
          ),
        ],
      ),
    );
  }

}

class SearchBar extends StatelessWidget {
  final Function(String) onSearch;
  final TextEditingController searchController;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const SearchBar({
    Key? key,
    required this.onSearch,
    required this.searchController,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // Adjusted padding
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              style: TextStyle(
                fontSize: screenWidth * 0.035, // Adjusted font size
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.primary,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: screenWidth * 0.04), // Adjusted padding
                filled: true,
                fillColor: Theme.of(context).colorScheme.onPrimary,
                hintText: 'buscaKm0'.tr,
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: screenWidth * 0.035), // Adjusted font size
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              onChanged: onSearch,
            ),
          ),
          SizedBox(width: screenWidth * 0.02), // Adjusted width
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: Theme.of(context).colorScheme.onPrimary, // Background color
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary, // Text color
                  fontSize: screenWidth * 0.035, // Adjusted font size
                ),
              ),
            ),
            child: PopupMenuButton<String>(
              initialValue: selectedFilter,
              onSelected: (String value) {
                onFilterChanged(value);
              },
              itemBuilder: (BuildContext context) {
                return ['Nombre'.tr, 'Precio'.tr, 'Distancia'.tr]
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(
                      choice,
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: screenWidth * 0.035), // Adjusted font size
                    ),
                  );
                }).toList();
              },
              icon: Icon(Icons.filter_alt,
                  color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductsVerticalItem extends StatelessWidget {
  final Product product;
  final LatLng userLocation;

  const ProductsVerticalItem(
      {Key? key, required this.product, required this.userLocation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    DateTime now = DateTime.now();
    Duration? difference;
    if (product.date != null) {
      difference = product.date!.difference(now);
    }

    String formattedDifference = difference != null
        ? difference.isNegative
            ? 'Producto caducado'.tr
            : 'Expira'.tr +
                '${difference.inHours}h ${difference.inMinutes.remainder(60)}m'
        : 'Fecha no disponible'.tr;

    return GestureDetector(
      onTap: () {
        Get.to(ProductDetailScreen(productId: product.id ?? ''));
      },
      child: Container(
        margin: EdgeInsets.all(screenWidth * 0.01), // Adjusted margin
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image: product.productImage != null &&
                          product.productImage!.isNotEmpty
                      ? NetworkImage(product.productImage!.first)
                      : AssetImage('assets/images/profile.png')
                          as ImageProvider,
                  fit: BoxFit.cover,
                  colorFilter: difference != null && difference.isNegative
                      ? ColorFilter.mode(
                          Colors.grey.withOpacity(0.8),
                          BlendMode.saturation,
                        )
                      : null,
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  product.name ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: screenWidth * 0.020, // Adjusted font size
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  formattedDifference,
                  style: TextStyle(
                    color: Color(0xFFFFFCEA),
                    fontSize: screenWidth * 0.020, // Adjusted font size
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${product.price} €/Kg',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: screenWidth * 0.020, // Adjusted font size
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'A: '.tr + '${_calculateDistance().toStringAsFixed(2)}' + 'km'.tr,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: screenWidth * 0.020, // Adjusted font size
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  double calculateDistance(
      double lat1, double lon1, double? lat2, double? lon2) {
    const R = 6371.0; // Radio de la Tierra en kilómetros
    final dLat = _toRadians(lat2! - lat1);
    final dLon = _toRadians(lon2! - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2!)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));

    return R * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  double _calculateDistance() {
    final productlatitude = product.location?.latitude;
    final productlongitude = product.location?.longitude;
    return calculateDistance(userLocation.latitude, userLocation.longitude,
        productlatitude, productlongitude);
  }
}

class MidText extends StatelessWidget {
  const MidText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(top: screenWidth * 0.01, left: screenWidth * 0.05, right: screenWidth * 0.05),
      child: Text(
        'todosProductos'.tr,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.05, // Adjust font size
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}


class ProductsHorizontal extends StatelessWidget {
  final List<Product> productListOferta;
  final LatLng userLocation;

  const ProductsHorizontal({
    super.key,
    required this.productListOferta,
    required this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: screenHeight / 4.5, // Height scaled relative to screen height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: productListOferta.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                DateTime now = DateTime.now();
                Duration? difference;
                if (productListOferta[index].date != null) {
                  difference = productListOferta[index].date!.difference(now);
                }

                String formattedDifference = difference != null
                    ? difference.isNegative
                        ? 'Producto caducado'
                        : 'Expira'.tr +
                            '${difference.inHours}h ${difference.inMinutes.remainder(60)}m'
                    : 'Fecha no disponible';

                double distance = calculateDistance(
                  userLocation.latitude,
                  userLocation.longitude,
                  productListOferta[index].location?.latitude ?? 0.0,
                  productListOferta[index].location?.longitude ?? 0.0,
                );

                return GestureDetector(
                  onTap: () {
                    Get.to(ProductDetailScreen(
                        productId: productListOferta[index].id ?? ''));
                  },
                  child: Container(
                    margin: EdgeInsets.all(screenWidth * 0.02), // Adjusted margin
                    width: screenWidth * 0.6, // Adjust width to 60% of screen width
                    child: Stack(
                      children: [
                        Container(
                          width: screenWidth * 0.55, // Adjusted width
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            image: DecorationImage(
                              image: productListOferta[index].productImage !=
                                          null &&
                                      productListOferta[index]
                                          .productImage!
                                          .isNotEmpty
                                  ? NetworkImage(productListOferta[index]
                                      .productImage!
                                      .first)
                                  : AssetImage('assets/images/profile.png')
                                      as ImageProvider, // Use the image URL
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 20,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              productListOferta[index].name ?? '',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: screenWidth * 0.02, // Adjusted font size
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 20,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              formattedDifference,
                              style: TextStyle(
                                color: Color(0xFFFFFCEA),
                                fontSize: screenWidth * 0.02, // Adjusted font size
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 40,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              '${productListOferta[index].price} €/Kg',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: screenWidth * 0.02, // Adjusted font size
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 40,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'A: '.tr +
                              '${distance.toStringAsFixed(2)}' +
                              'km'.tr, // Display the distance
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: screenWidth * 0.02, // Adjusted font size
                          ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  double calculateDistance(
      double lat1, double lon1, double? lat2, double? lon2) {
    const R = 6371.0; // Radio de la Tierra en kilómetros
    final dLat = _toRadians(lat2! - lat1);
    final dLon = _toRadians(lon2! - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2!)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));

    return R * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}

class TopText extends StatelessWidget {
  const TopText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(top: screenWidth * 0.01, left: screenWidth * 0.05),
      child: Text(
        'oferta'.tr,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.05, // Adjust font size
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}


