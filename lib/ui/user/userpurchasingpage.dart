import 'package:assignment/datamodel/products.dart';
import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/datamodel/subscription.dart';
import 'package:assignment/datamodel/vendingmachine.dart';
import 'package:assignment/services/clouddatabase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UserPurchasingPage extends StatefulWidget {
  final VendingMachine selectedVendingMachine;
  const UserPurchasingPage({super.key, required this.selectedVendingMachine});

  @override
  State<UserPurchasingPage> createState() => _UserPurchasingPageState();
}

class _UserPurchasingPageState extends State<UserPurchasingPage> {
  late VendingMachine selectedVendingMachine = widget.selectedVendingMachine;
  CloudDatabase db = CloudDatabase();
  late List<Sellers> sellerList;
  List<Subscription> subscriptionList = [];
  List<Products> prodList = [];
  final _searchController = TextEditingController();
  bool isLoading = false;

  void getSellerList() async {
    setState(() {
      isLoading = true;
    });

    sellerList = (await db.read(CloudDatabase.seller)).map((seller) {
      return Sellers.fromJson(seller);
    }).toList();
    for (Sellers seller in sellerList) {
      subscriptionList.addAll(seller.getSubscriptions);
    }
    subscriptionList = subscriptionList.where((subscription) {
      return DateTime.parse(subscription.endDate).isAfter(DateTime.now());
    }).toList();
    subscriptionList = subscriptionList.where((subscription) {
      return subscription.getColumn.getVmId == selectedVendingMachine.getId;
    }).toList();
    for (var x in subscriptionList) {
      prodList.addAll(x.getProducts);
    }

    setState(() {
      isLoading = false;
    });
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
    return GridView.builder(
      itemCount: 8,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getSellerList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
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
              controller: _searchController,
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: isLoading ? _buildShimmerLoading() : _buildProductCard(),
            )
          ],
        ),
      ),
    ));
  }
}
