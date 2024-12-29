import 'package:assignment/datamodel/purchasehistory.dart';
import 'package:assignment/ui/arguidance.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart' as intl;

class UserRedeemPage extends StatefulWidget {
  final PurchaseHistory purchase;
  const UserRedeemPage({super.key, required this.purchase});

  @override
  State<UserRedeemPage> createState() => _UserRedeemPageState();
}

class _UserRedeemPageState extends State<UserRedeemPage> {
  final dateFormatter = intl.DateFormat("dd/MM/yyyy hh:mm a");
  late PurchaseHistory purchase = widget.purchase;
  late double percentage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (purchase.voucher == null) {
      percentage = 0;
    } else {
      percentage = purchase.voucher!.getPercentage / 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help,
              size: 32,
            ),
            onPressed: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ArApp(),
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
            ),
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.progressiveDots(
                  color: Theme.of(context).primaryColor, size: 70),
            )
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Order Status:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  purchase.redeem
                                      ? "Completed"
                                      : "Pending Redeem",
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const Divider(
                                  thickness: 1,
                                ),
                                const Text(
                                  'Order Id:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(purchase.id!),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  'Order Date:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(dateFormatter.format(
                                    DateTime.parse(purchase.purchaseDate))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Products:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Scrollbar(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children:
                                          purchase.prodList.entries.map((item) {
                                        return ListTile(
                                          title: Text(item.key.getDesc),
                                          subtitle: Text(
                                              'Price: RM ${(item.key.getSellingPrice).toStringAsFixed(2)}'),
                                          trailing: Text('Qty: ${item.value}'),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Divider(thickness: 1),
                            const Text(
                              'Voucher Used:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            purchase.voucher == null
                                ? const Text(
                                    'None',
                                  )
                                : Text("${purchase.voucher!.getId}"),
                            const SizedBox(height: 20),
                            purchase.voucher == null
                                ? Text(
                                    'Total: RM ${purchase.getTotalAmount().toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total After Apply Voucher: RM ${(purchase.getTotalAmount() * (1.0 - percentage)).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                          "You saved RM${(purchase.getTotalAmount() * (percentage)).toStringAsFixed(2)} (${(percentage * 100).toStringAsFixed(0)}%)"),
                                    ],
                                  ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                DraggableScrollableSheet(
                  snap: true,
                  initialChildSize: 0.05,
                  minChildSize: 0.05,
                  maxChildSize: 1.0,
                  builder: (context, scrollController) {
                    List<Widget> children = [
                      Divider(
                        color: Colors.grey,
                        height: 0,
                        thickness: 4,
                        indent: MediaQuery.of(context).size.width / 3,
                        endIndent: MediaQuery.of(context).size.width / 3,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ];

                    if (!purchase.redeem) {
                      children.addAll([
                        const Text(
                          "This QR code should be shown at the vending machine.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Center(
                          child: QrImageView(
                            data: purchase.id!,
                            version: QrVersions.auto,
                            size: 320,
                            gapless: false,
                            backgroundColor: Colors.white,
                          ),
                        )
                      ]);
                    } else {
                      children.addAll([
                        const Text(
                          "You have redeemed the food!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Center(
                          child: Image.asset(
                            "assets/logo/logo_filled.png",
                            width: 320,
                          ),
                        )
                      ]);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Colors.black,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: children,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
