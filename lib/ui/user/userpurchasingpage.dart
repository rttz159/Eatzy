import 'package:assignment/datamodel/products.dart';
import 'package:assignment/ui/user/usercart.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart' as intl;

import '../../services/usercartdataprovider.dart';

class UserPurchasingPage extends StatefulWidget {
  const UserPurchasingPage({super.key});

  @override
  State<UserPurchasingPage> createState() => _UserPurchasingPageState();
}

class _UserPurchasingPageState extends State<UserPurchasingPage> {
  final numberFormat = intl.NumberFormat("RM #####0.0#");
  String? selectedSellerId;
  List<Products> filteredProdList = [];
  final _searchController = TextEditingController();
  bool isLoading = false;
  late int _itemCount = 0;

  void _filterProducts(String query) {
    final providerList =
        Provider.of<UserCartDataProvider>(context, listen: false).prodList;
    if (providerList.isEmpty) {
      setState(() {
        filteredProdList = [];
      });
      return;
    }

    List<Products> filtered = providerList;

    if (selectedSellerId != null && selectedSellerId!.isNotEmpty) {
      filtered = filtered
          .where((product) => product.sellerId == selectedSellerId)
          .toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered
          .where((product) =>
              product.getDesc.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredProdList = filtered;
    });
  }

  void getSellerList() async {
    setState(() {
      isLoading = true;
    });

    await Provider.of<UserCartDataProvider>(context, listen: false).getData();

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        filteredProdList =
            Provider.of<UserCartDataProvider>(context, listen: false).prodList;
        isLoading = false;
      });
    });
  }

  void _showQuantityDialog(Products prod) {
    int prodQty = prod.getQty;
    int selectedQuantity = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Quantity'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: selectedQuantity > 1
                        ? () {
                            setState(() {
                              selectedQuantity--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    selectedQuantity.toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    onPressed: selectedQuantity < prodQty
                        ? () {
                            setState(() {
                              selectedQuantity++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedQuantity > 0) {
                  Provider.of<UserCartDataProvider>(context, listen: false)
                      .addToCart(prod, selectedQuantity);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid quantity'),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
      highlightColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
      child: GridView.builder(
        itemCount: 8,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          childAspectRatio: 0.75,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: filteredProdList.isEmpty
          ? const Center(
              child: Text("No Products"),
            )
          : GridView.builder(
              itemCount: filteredProdList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                Products prod = filteredProdList[index];
                bool isAvailable = prod.getQty > 0;

                return GestureDetector(
                  onTap: isAvailable
                      ? () {
                          _showQuantityDialog(prod);
                        }
                      : null,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          height: MediaQuery.of(context).size.height / 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: isAvailable
                                ? Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.1),
                            boxShadow: isAvailable
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: isAvailable
                                      ? Theme.of(context).cardColor
                                      : Colors.grey.shade300,
                                  border: Border.all(
                                    color: isAvailable
                                        ? Theme.of(context).dividerColor
                                        : Colors.grey,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: prod.getImageUrl == null
                                      ? Image.asset(
                                          "assets/logo/logo.png",
                                          fit: BoxFit.cover,
                                          color: isAvailable
                                              ? null
                                              : Colors.grey.withOpacity(0.5),
                                          colorBlendMode: BlendMode.modulate,
                                        )
                                      : ColorFiltered(
                                          colorFilter: isAvailable
                                              ? const ColorFilter.mode(
                                                  Colors.transparent,
                                                  BlendMode.multiply)
                                              : const ColorFilter.mode(
                                                  Colors.grey,
                                                  BlendMode.saturation),
                                          child: Image.network(
                                            prod.getImageUrl!,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              } else {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            (loadingProgress
                                                                    .expectedTotalBytes ??
                                                                1)
                                                        : null,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Text(
                                  prod.getDesc,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isAvailable
                                            ? Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                            : Colors.grey,
                                      ),
                                ),
                              ),
                              Text(
                                numberFormat.format(prod.getSellingPrice),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: isAvailable
                                          ? Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.color
                                          : Colors.grey,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: isAvailable
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16),
                                  child: Text(
                                    isAvailable ? 'Add' : 'Not Available',
                                    style: TextStyle(
                                        color: isAvailable
                                            ? (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.black
                                                : Colors.white)
                                            : Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isAvailable)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSellerList();
      setState(() {
        _itemCount = Provider.of<UserCartDataProvider>(context, listen: false)
            .cart
            .length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          Consumer<UserCartDataProvider>(
            builder: (context, provider, child) {
              return DropdownButton<String>(
                hint: const Text("Filter by Seller"),
                value: selectedSellerId,
                items: provider.sellerList.isEmpty
                    ? []
                    : [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text("All"),
                        ),
                        ...provider.sellerList
                            .map((seller) => DropdownMenuItem<String>(
                                  value: seller.id,
                                  child: Text(seller.name),
                                )),
                      ],
                onChanged: provider.sellerList.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          selectedSellerId = value;
                          _filterProducts(_searchController.text);
                        });
                      },
              );
            },
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      floatingActionButton: Consumer<UserCartDataProvider>(
        builder: (context, provider, child) {
          _itemCount = provider.cart.length;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                onPressed: () {
                  if (provider.cart.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "Your cart is empty, please add something.");
                  } else {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const UserCart(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          }),
                    );
                  }
                },
                child: const Icon(Icons.shopping_cart),
              ),
              if (_itemCount > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$_itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SearchBar(
              leading: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.search),
              ),
              hintText: "Search...",
              controller: _searchController,
              onChanged: (query) {
                _filterProducts(query);
              },
            ),
            Consumer<UserCartDataProvider>(
              builder: (context, provider, child) {
                return isLoading
                    ? Expanded(child: _buildShimmerLoading())
                    : Expanded(child: _buildProductCard());
              },
            )
          ],
        ),
      ),
    ));
  }
}
