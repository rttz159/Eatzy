import 'package:assignment/datamodel/normalusers.dart';
import 'package:assignment/datamodel/products.dart';
import 'package:assignment/datamodel/purchasehistory.dart';
import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/datamodel/vendingmachine.dart';
import 'package:assignment/datamodel/voucher.dart';
import 'package:assignment/services/clouddatabase.dart';
import 'package:assignment/services/usercartdataprovider.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

class UserCart extends StatefulWidget {
  const UserCart({super.key});

  @override
  State<UserCart> createState() => _UserCartState();
}

class _UserCartState extends State<UserCart> {
  final numberFormat = intl.NumberFormat("#####0.0#");
  late VendingMachine selectedVendingMachine;
  late Map<Products, int> cart;
  late List<MapEntry<Products, int>> cartList;
  Voucher zhvoucher = Voucher(
    id: "ZEROHUNGER",
    desc: "ENJOY YOUR MEALS",
    endDate: DateTime(2099, 12, 31).toIso8601String(),
    startDate: DateTime(2000, 1, 1).toIso8601String(),
    percentage: 90,
  );
  String? vendingMachineAddress;
  String? voucherErrorText;
  double totalAmount = 0;
  bool _isLoading = false;
  Set<Sellers> sellerUpdated = {};
  Voucher? voucher;

  final TextEditingController _voucherController = TextEditingController();

  Future<bool> onPaymentSelected(String paymentMethod) async {
    bool change = false;
    if (cartList.isEmpty) {
      Fluttertoast.showToast(msg: "Your Cart is Empty");
      return change;
    }

    final cart = Provider.of<UserCartDataProvider>(context, listen: false).cart;

    if (voucherErrorText == null) {
      final CloudDatabase db = CloudDatabase();
      for (var seller in sellerUpdated) {
        db.save(CloudDatabase.seller, seller.toJson(), docId: seller.getId);
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      PurchaseHistory purchaseHistory = PurchaseHistory(
          userId: userProvider.getCurrentUser!.getId!,
          prodList: cart,
          purchaseDate: DateTime.now().toIso8601String(),
          redeem: false,
          voucher: voucher);
      db.save(CloudDatabase.purchaseHistory, purchaseHistory.toJson());
      change = true;
      Provider.of<UserCartDataProvider>(context, listen: false).cart = {};
    }
    return change;
  }

  void _validateVoucher() {
    if (cartList.isEmpty) {
      Fluttertoast.showToast(msg: "Your Cart is Empty");
      return;
    }

    final voucherCode = _voucherController.text.trim();
    if (voucherCode.isEmpty) {
      voucherErrorText = null;
      return;
    }

    final currentUser =
        Provider.of<UserProvider>(context, listen: false).getCurrentUser;
    if ((currentUser as NormalUser).isSpecial &&
        voucherCode == zhvoucher.getId) {
      setState(() {
        voucher = zhvoucher;
        voucherErrorText = null;
      });
      return;
    }

    if (sellerUpdated.length > 1) {
      setState(() {
        voucherErrorText = "Voucher can only applied to one seller's product";
      });
      return;
    } else {
      setState(() {
        voucherErrorText = null;
      });
    }

    Voucher? voucherfound;
    for (var v in sellerUpdated.first.getVouchers) {
      if (v.id == voucherCode) {
        voucherfound = v;
        break;
      }
    }

    if (voucherfound == null) {
      setState(() {
        voucherErrorText = "Invalid Voucher";
      });
      return;
    } else {
      setState(() {
        voucherErrorText = null;
        voucher = voucherfound;
      });
    }
  }

  void _handlePayment(String paymentMethod) async {
    setState(() {
      _isLoading = true;
    });

    bool change = await onPaymentSelected(paymentMethod);

    setState(() {
      _isLoading = false;
    });
    if (change) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Fluttertoast.showToast(msg: "Order Placed!");
    }
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
    final sellerList =
        Provider.of<UserCartDataProvider>(context, listen: false).sellerList;

    cartList = cart.entries.toList();

    for (var x in cartList) {
      totalAmount += (x.key.getSellingPrice * x.value);
    }

    bool found = false;
    for (var x in cart.entries) {
      found = false;
      for (var seller in sellerList) {
        for (var subscription in seller.getSubscriptions) {
          if (subscription.getProducts.contains(x.key)) {
            sellerUpdated.add(seller);
            found = true;
            break;
          }
        }
        if (found) {
          break;
        }
      }
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
  void dispose() {
    _voucherController.dispose();
    super.dispose();
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
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedVendingMachine.getDesc,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      vendingMachineAddress == null
                                          ? const Text("No Address found")
                                          : Text(
                                              vendingMachineAddress!,
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              style:
                                                  const TextStyle(fontSize: 14),
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
                        Padding(
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
                                  ? const Center(
                                      child: Text(
                                          "Your cart is empty, please add something."),
                                    )
                                  : Column(
                                      children: cartList.map((item) {
                                        return ListTile(
                                          leading: GestureDetector(
                                            onTap: () {
                                              Provider.of<UserCartDataProvider>(
                                                      context,
                                                      listen: false)
                                                  .removeFromCart(item.key);
                                              final sellerList = Provider.of<
                                                          UserCartDataProvider>(
                                                      context,
                                                      listen: false)
                                                  .sellerList;
                                              sellerUpdated.clear();
                                              bool found = false;
                                              for (var x in cart.entries) {
                                                found = false;
                                                for (var seller in sellerList) {
                                                  for (var subscription
                                                      in seller
                                                          .getSubscriptions) {
                                                    if (subscription.getProducts
                                                        .contains(x.key)) {
                                                      sellerUpdated.add(seller);
                                                      found = true;
                                                      break;
                                                    }
                                                  }
                                                  if (found) {
                                                    break;
                                                  }
                                                }
                                              }
                                              setState(() {
                                                cartList =
                                                    cart.entries.toList();
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
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(thickness: 1),
                      voucher == null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total: RM ${totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Enter Voucher (Optional):',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _voucherController,
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        voucherErrorText = null;
                                      });
                                    } else {
                                      _voucherController.text =
                                          value.toUpperCase();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    hintText: 'Enter Voucher Code (if any)',
                                    errorText: voucherErrorText,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _validateVoucher,
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: const Text("Apply"),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total After Discount: RM ${(totalAmount * (1 - voucher!.getPercentage / 100)).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                    "You saved RM${(totalAmount * (voucher!.getPercentage / 100)).toStringAsFixed(2)} (${voucher!.getPercentage.toStringAsFixed(0)}%)"),
                                const SizedBox(
                                  height: 10,
                                ),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.discount_outlined),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(child: Text(voucher!.getId!)),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              voucher = null;
                                              voucherErrorText = null;
                                            });
                                          },
                                          icon: const Icon(Icons
                                              .remove_circle_outline_outlined),
                                          color: Colors.red,
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
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
                )
              ],
            ),
    ));
  }
}
