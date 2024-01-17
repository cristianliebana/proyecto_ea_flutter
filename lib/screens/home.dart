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
    filteredList = products; // Inicializa la lista filtrada con todos los productos
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
    nextPageProducts = nextPageProducts.where((product) => product.sold == false).toList();

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
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 30),
              Container(
                child: SearchBar(
                  onSearch: _filterProducts,
                  searchController: _searchController,
                  selectedFilter: 'Nombre'.tr,
                  onFilterChanged: _handleFilterChanged,
                ),
              ),
            ]),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 20),
              Container(child: TopText()),
              SizedBox(height: 10),
            ]),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                  child: ProductsHorizontal(
                productListOferta: productListOferta,
                userLocation: _currentLocation,
              )),
              SizedBox(height: 10),
            ]),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(child: MidText()),
              SizedBox(height: 5),
            ]),
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.9,
              // Adjust the margin values as needed
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
          )
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.primary,
              ),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                filled: true,
                fillColor: Theme.of(context).colorScheme.onPrimary,
                hintText: 'buscaKm0'.tr,
                hintStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              onChanged: onSearch,
            ),
          ),
          SizedBox(width: 10),
          PopupMenuButton<String>(
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
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                );
              }).toList();
            },
            icon: Icon(Icons.filter_alt,
                color: Theme.of(context).colorScheme.onPrimary),
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
    return GestureDetector(
      onTap: () {
        Get.to(
          ProductDetailScreen(productId: product.id ?? ''),
        );
      },
      child: Container(
        margin: EdgeInsets.only(left: 5, top: 5, right: 5),
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
                          as ImageProvider, // Use the image URL
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  product.name ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18.0,
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${product.price} €/Kg',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 5), // Espacio entre el precio y la distancia
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'A: '.tr +
                      '${_calculateDistance().toStringAsFixed(2)}' +
                      'km'.tr,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14.0,
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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
          margin: EdgeInsets.only(top: 10, left: 20),
          width: gWidth,
          height: gHeight / 25,
          child: SizedBox(
            child: Text("Todos los productos",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Theme.of(context).primaryColor,
                )),
          )),
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
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 0.25),
            width: 1,
            height: gHeight / 4.5,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: productListOferta.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
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
                    margin: EdgeInsets.all(gHeight * 0.01),
                    width: gWidth / 1.5,
                    child: Stack(
                      children: [
                        Container(
                          width: gWidth / 1,
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
                                horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              productListOferta[index].name ?? '',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              '${productListOferta[index].price} €/Kg', // Agrega el precio del producto
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 20,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'A: '.tr +
                                  '${distance.toStringAsFixed(2)}' +
                                  'km'.tr, // Muestra la distancia
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize:
                                    14.0, // Ajusta el tamaño según tus necesidades
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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
          margin: EdgeInsets.only(top: 10, left: 20),
          width: gWidth,
          height: gHeight / 25,
          child: SizedBox(
            child: Text('oferta'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Theme.of(context).primaryColor,
                )),
          )),
    );
  }
}
