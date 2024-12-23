import 'package:assignment/datamodel/products.dart';
import 'package:assignment/datamodel/vendingmachine.dart';
import 'package:assignment/services/usercartdataprovider.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

class UserCart extends StatefulWidget {
  final void Function(String paymentMethod) onPaymentSelected;

  const UserCart({super.key, required this.onPaymentSelected});

  @override
  State<UserCart> createState() => _UserCartState();
}

class _UserCartState extends State<UserCart> {
  final numberFormat = intl.NumberFormat("#####0.0#");
  late VendingMachine selectedVendingMachine;
  late Map<Products, int> cart;
  late List<MapEntry<Products, int>> cartList;
  String? vendingMachineAddress;
  double totalAmount = 0;
  bool _isLoading = false;

  void _handlePayment(String paymentMethod) {
    setState(() {
      _isLoading = true;
    });

    widget.onPaymentSelected(paymentMethod);

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<void> _loadVendingMachineAddress() async {
    try {
      final placemarks = await placemarkFromCoordinates(
        double.parse(selectedVendingMachine.getLat),
        double.parse(selectedVendingMachine.getLong),
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        setState(() {
          vendingMachineAddress = '${placemark.street}, '
              '${placemark.locality}, '
              '${placemark.administrativeArea}, '
              '${placemark.country}';
        });
      } else {
        setState(() {
          vendingMachineAddress = 'No Address Found';
        });
      }
    } catch (e) {
      setState(() {
        vendingMachineAddress = 'Error retrieving address';
      });
      debugPrint('Error fetching address: $e');
    }
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    selectedVendingMachine =
        Provider.of<UserCartDataProvider>(context, listen: false)
            .selectedVendingMachine;
    cart = Provider.of<UserCartDataProvider>(context, listen: false).cart;
    cartList = cart.entries.toList();

    for (var x in cartList) {
      totalAmount += (x.key.getSellingPrice * x.value);
    }

    await _loadVendingMachineAddress();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Your Shopping Cart"),
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Theme.of(context).primaryColor, size: 20),
            )
          : Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(
                height: 10,
              ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedVendingMachine.getDesc,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            vendingMachineAddress == null
                                ? const Text("No Address found")
                                : Text(
                                    vendingMachineAddress!,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Products:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      cartList.isEmpty
                          ? const Expanded(
                              child: Center(
                                child: Text(
                                    "Your cart is empty, please add something."),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: cartList.length,
                                itemBuilder: (context, index) {
                                  final item = cartList[index];
                                  return ListTile(
                                    leading: GestureDetector(
                                      onTap: () {
                                        Provider.of<UserCartDataProvider>(
                                                context,
                                                listen: false)
                                            .removeFromCart(item.key);
                                        setState(() {
                                          cartList = cart.entries.toList();
                                          totalAmount = 0.0;
                                          for (var x in cartList) {
                                            totalAmount +=
                                                (x.key.getSellingPrice *
                                                    x.value);
                                          }
                                        });
                                      },
                                      child: const Icon(Icons.delete),
                                    ),
                                    title: Text(item.key.getDesc),
                                    subtitle: Text(
                                        'Price: RM ${numberFormat.format(item.key.getSellingPrice)}'),
                                    trailing: Text('Qty: ${item.value}'),
                                  );
                                },
                              ),
                            ),
                      const Divider(thickness: 1),
                      Text(
                        'Total: RM ${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Select Payment Method:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        children: [
                          ElevatedButton(
                            onPressed: () => _handlePayment('Credit Card'),
                            child: const Text('Pay with Credit Card'),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                            onPressed: () => _handlePayment('PayPal'),
                            child: const Text('Pay with PayPal'),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                            onPressed: () => _handlePayment('Bank Transfer'),
                            child: const Text('Pay with Bank Transfer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
    ));
  }
}
