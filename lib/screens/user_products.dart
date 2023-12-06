import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/api/models/product_model.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/product_detail.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';

class UserProductsScreen extends StatefulWidget {
  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  List<Product> products = [];
  Map<String, dynamic> userData = {};
  late ScrollController _scrollController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    obtenerDatosUsuario();
  }

  Future<void> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    setState(() {
      userData = response.data;
      print(userData);
      print(userData['_id']);
      loadUserProducts(userData['_id']);
    });
  }

  Future<void> loadUserProducts(String? userId) async {
    if (userId != null) {
      final List<Product> userproducts =
          await ProductService.getUserProducts(userId);
      setState(() {
        products = userproducts;
        print(products);
      });
    } else {
      print('UserId is null.');
    }
  }

/*  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreProducts();
    }
  }*/

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
      appBar: AppBar(
          title: Text('Mis productos publicados'),
          backgroundColor: Color(0xFF486D28),
          centerTitle: true),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: SearchBar(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ProductsVerticalItem(product: products[index]);
              },
              childCount: products.length,
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: 20), // Ajusta el valor según sea necesario
          Padding(
            padding: const EdgeInsets.only(),
            child: TextField(
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFFFFCEA),
              ),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                filled: true,
                fillColor: Color(0xFF486D28),
                prefixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.search,
                    color: Color(0xFFFFFCEA),
                  ),
                ),
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFFFFCEA),
                ),
                hintText: "Busca en tus productos",
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductsVerticalItem extends StatelessWidget {
  final Product product;

  const ProductsVerticalItem({Key? key, required this.product})
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
        margin: EdgeInsets.only(
            left: gWidth * 0.04, top: gHeight * 0.02, right: gWidth * 0.04),
        width: gWidth / 1.5,
        height: gHeight / 4,
        decoration: BoxDecoration(
          color: Color(0xFF486D28),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            SizedBox(width: 20),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                product.name ?? '',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
