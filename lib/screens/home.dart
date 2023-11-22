import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/api/models/product_model.dart';
import 'package:proyecto_flutter/api/services/product_service.dart';
import 'package:proyecto_flutter/screens/product_detail.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Product> productList = [];
  late ScrollController _scrollController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    int page = 1;
    List<Product> products = await ProductService.getProducts(page);
    setState(() {
      productList = products;
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

      int nextPage = (productList.length / 3).ceil() + 1;
      List<Product> nextPageProducts =
          await ProductService.getProducts(nextPage);

      setState(() {
        productList.addAll(nextPageProducts);
        _loading = false;
      });
    }
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
              Container(child: SearchBar()),
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
              Container(child: ProductsHorizontal(productList: productList)),
              SizedBox(height: 10),
            ]),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(child: MidText()),
              SizedBox(height: 5),
            ]),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < productList.length) {
                  return ProductsVerticalItem(product: productList[index]);
                } else {
                  return _loading ? CircularProgressIndicator() : Container();
                }
              },
              childCount: productList.length + 1,
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
      child: Padding(
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
            hintText: "Busca en Km0 Market",
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
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
          ProductDetailScreen(productId: product.id),
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
                product.name,
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
            margin: EdgeInsets.only(left: gWidth * 0.02),
            width: gWidth,
            height: gHeight / 4.5,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: productList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Get.to(
                        ProductDetailScreen(productId: productList[index].id));
                  },
                  child: Container(
                    margin: EdgeInsets.all(gHeight * 0.01),
                    width: gWidth / 1.5,
                    child: Stack(
                      children: [
                        Container(
                          width: gWidth / 1,
                          decoration: BoxDecoration(
                            color: Color(0xFF486D28),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(width: 20),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                productList[index].name,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
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
                )),
          )),
    );
  }
}
