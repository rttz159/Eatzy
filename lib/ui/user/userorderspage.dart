import 'package:assignment/datamodel/normalusers.dart';
import 'package:assignment/datamodel/purchasehistory.dart';
import 'package:assignment/services/connectivityprovider.dart';
import 'package:assignment/services/purchasehistoryprovider.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:assignment/ui/user/redeempage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class UserOrderPage extends StatefulWidget {
  const UserOrderPage({super.key});

  @override
  State<UserOrderPage> createState() => _UserOrderPageState();
}

class _UserOrderPageState extends State<UserOrderPage> {
  int selectedButtonIndex = 0;
  bool _isLoading = false;
  List<String> buttonText = ["All", "Active", "Past"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 30,
          ),
          const Center(
              child: Text(
            "Orders",
            style: TextStyle(fontSize: 22),
          )),
          SizedBox(
            height: MediaQuery.of(context).size.height / 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(buttonText.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                    backgroundColor: selectedButtonIndex == index
                        ? Theme.of(context).colorScheme.inversePrimary
                        : Theme.of(context).dialogBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedButtonIndex = index;
                    });
                  },
                  child: Text(buttonText[index]),
                ),
              );
            }),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 40,
          ),
          _isLoading ? _buildShimmerLoading() : _buildSubscriptionList(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionList() {
    final dateFormatter = intl.DateFormat("dd/MM/yyyy hh:mm a");
    return Consumer3<UserProvider, ConnectivityProvider,
        PurchaseHistoryProvider>(
      builder: (BuildContext context,
          UserProvider userProvider,
          ConnectivityProvider connectivityProvider,
          PurchaseHistoryProvider purchaseHistoryProvider,
          Widget? child) {
        final currentUser = userProvider.getCurrentUser as NormalUser;
        final purchaseHistoryList =
            purchaseHistoryProvider.purchaseHistoryList.where((purchase) {
          return purchase.userId == currentUser.getId;
        }).toList();

        if (purchaseHistoryList.isEmpty) {
          return const Center(child: Text("There are no order"));
        }

        List<PurchaseHistory> activePurchaseHistory =
            purchaseHistoryList.where((n) {
          return !(n.redeem);
        }).toList();

        List<PurchaseHistory> pastPurchaseHistory =
            purchaseHistoryList.where((n) {
          return (n.redeem);
        }).toList();

        late List<PurchaseHistory> userPurchaseHistory;

        switch (selectedButtonIndex) {
          case 0:
            userPurchaseHistory = purchaseHistoryList;
            break;
          case 1:
            userPurchaseHistory = activePurchaseHistory;
            break;
          case 2:
            userPurchaseHistory = pastPurchaseHistory;
            break;
          default:
            userPurchaseHistory = [];
            break;
        }

        if (userPurchaseHistory.isEmpty) {
          return const Center(child: Text("There are no order"));
        }

        return Expanded(
          child: Scrollbar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.separated(
                itemCount: userPurchaseHistory.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final purchaseHistory = userPurchaseHistory[index];

                  return ListTile(
                    isThreeLine: true,
                    leading: const CircleAvatar(
                        child: Icon(Icons.receipt_long_outlined)),
                    title: Text(
                      dateFormatter
                          .format(DateTime.parse(purchaseHistory.purchaseDate)),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: purchaseHistory.redeem
                        ? Text(
                            "RM ${purchaseHistory.getTotalAmount().toStringAsFixed(2)}\nStatus: Redeemed",
                            style: const TextStyle(fontSize: 14),
                          )
                        : Text(
                            "RM ${purchaseHistory.getTotalAmount().toStringAsFixed(2)}\nStatus: Waiting for Redeem",
                            style: const TextStyle(fontSize: 14),
                          ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    tileColor: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    onTap: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            UserRedeemPage(
                          purchase: purchaseHistory,
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          return SlideTransition(
                              position: animation.drive(tween), child: child);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Expanded(
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        highlightColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
                title: Container(
                  height: 10,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
                subtitle: Container(
                  height: 10,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
