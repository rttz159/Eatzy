import 'package:assignment/datamodel/products.dart';
import 'package:assignment/datamodel/subscription.dart';
import 'package:assignment/datamodel/vendingmachine.dart';
import 'package:assignment/ui/seller/productdetails.dart';
import 'package:flutter/material.dart';

class StockManagementPage extends StatefulWidget {
  final Subscription selectedSubscription;
  final VendingMachine selectedVendingMachine;

  const StockManagementPage({
    super.key,
    required this.selectedSubscription,
    required this.selectedVendingMachine,
  });

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  late Subscription selectedSubscription;
  late VendingMachine selectedVendingMachine;
  late List<Products> products;
  late int availableItemCount;

  @override
  void initState() {
    super.initState();
    selectedSubscription = widget.selectedSubscription;
    selectedVendingMachine = widget.selectedVendingMachine;
    products = selectedSubscription.getProducts;
    int totalcount = 0;
    for (Products x in products) {
      totalcount += x.getQty;
    }
    availableItemCount = 10 - totalcount;
  }

  void refreshProductList() {
    int totalcount = 0;
    for (Products x in products) {
      totalcount += x.getQty;
    }
    setState(() {
      products = selectedSubscription.getProducts;
      availableItemCount = 10 - totalcount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Manage Your Stock"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: availableItemCount <= 0
              ? null
              : () async {
                  bool? shouldRebuild = await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ProductDetailsPage(
                              subscription: selectedSubscription,
                              availableItemCount: availableItemCount),
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
                      },
                    ),
                  );

                  if (shouldRebuild != null && shouldRebuild) {
                    refreshProductList();
                  }
                },
          child: availableItemCount <= 0
              ? const Icon(Icons.not_interested_rounded)
              : const Icon(Icons.add),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.network(
                            selectedVendingMachine.getImageUrl!,
                            height: 80,
                            width: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Flexible(
                          flex: 1,
                          child: Text(
                            selectedVendingMachine.getDesc,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1),
                          ),
                        ),
                        child: const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "Stock",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: products.isEmpty
                      ? Column(
                          children: [
                            const SizedBox(height: 20),
                            Image.asset("assets/logo/logo_cry_filled.png",
                                height: 100),
                            const SizedBox(height: 20),
                            const Text("No products, please add one"),
                          ],
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: products.map((product) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1),
                                ),
                              ),
                              child: ListTile(
                                onTap: () async {
                                  bool? shouldRebuild = await Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          ProductDetailsPage(
                                        subscription: selectedSubscription,
                                        products: product,
                                        availableItemCount: availableItemCount,
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.ease;
                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));

                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );

                                  if (shouldRebuild != null && shouldRebuild) {
                                    refreshProductList();
                                  }
                                },
                                title: Text(
                                  product.getDesc,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                leading: const Icon(Icons.rice_bowl, size: 32),
                                trailing: const Icon(Icons.arrow_forward_ios),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
