import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/api/models/product_model.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/screens/product_detail.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Product> productList = [];
  late List<Product> filteredList = [];
  late ScrollController _scrollController;
  bool _loading = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkAuthAndNavigate();
    _scrollController = ScrollController()..addListener(_scrollListener);
    fetchProducts();
  }

  Future<void> checkAuthAndNavigate() async {
    await TokenService.loggedIn();
  }

  Future<void> fetchProducts() async {
    int page = 1;
    List<Product> products = await ProductService.getProducts(page);
    setState(() {
      productList = products;
      filteredList =
          products; // Inicializa la lista filtrada con todos los productos
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

      int nextPage = (filteredList.length / 50).ceil() + 1;
      List<Product> nextPageProducts =
          await ProductService.getProducts(nextPage);

      setState(() {
        productList.addAll(nextPageProducts);
        filteredList = productList
            .where((product) =>
                product.name
                    ?.toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ??
                false)
            .toList();
        _loading = false;
      });
    }
  }

  void _filterProducts(String searchTerm) {
    setState(() {
      filteredList = productList
          .where((product) =>
              product.name?.toLowerCase().contains(searchTerm.toLowerCase()) ??
              false)
          .toList();
    });
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
                productList: productList,
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
                  return ProductsVerticalItem(product: filteredList[index]);
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

  const SearchBar(
      {Key? key, required this.onSearch, required this.searchController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.only(),
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
            prefixIcon: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.primary,
            ),
            hintText: "Busca en Km0 Market",
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          onChanged: onSearch,
        ),
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
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${product.price} €/Kg', // Agrega el precio del producto
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
  final List<Product> productList;

  const ProductsHorizontal({
    super.key,
    required this.productList,
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
              itemCount: productList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Get.to(ProductDetailScreen(
                        productId: productList[index].id ?? ''));
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
                              image: productList[index].productImage != null &&
                                      productList[index]
                                          .productImage!
                                          .isNotEmpty
                                  ? NetworkImage(
                                      productList[index].productImage!.first)
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
                              productList[index].name ?? '',
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
                              '${productList[index].price} €/Kg', // Agrega el precio del producto
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
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
            child: Text("Productos en oferta",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Theme.of(context).primaryColor,
                )),
          )),
    );
  }
}
