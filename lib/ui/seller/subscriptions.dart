import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/datamodel/subscription.dart';
import 'package:assignment/datamodel/vendingmachine.dart';
import 'package:assignment/services/connectivityprovider.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:assignment/services/vendingmachineprovider.dart';
import 'package:assignment/ui/seller/stockmanagement.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int selectedButtonIndex = 0;
  List<String> buttonText = ["All", "Active", "Past"];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final provider =
        Provider.of<VendingMachineProvider>(context, listen: false);
    await provider.getVendingMachines();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
        child: Column(
          children: [
            const Center(
                child: Text(
              "Subscriptions",
              style: TextStyle(fontSize: 22),
            )),
            const SizedBox(height: 20),
            _buildButtonRow(),
            const SizedBox(height: 50),
            _isLoading ? _buildShimmerLoading() : _buildSubscriptionList(),
          ],
        ),
      ),
    );
  }

  Row _buildButtonRow() {
    return Row(
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

  Widget _buildSubscriptionList() {
    return Consumer3<UserProvider, VendingMachineProvider,
        ConnectivityProvider>(
      builder: (BuildContext context,
          UserProvider userProvider,
          VendingMachineProvider vendingMachineProvider,
          ConnectivityProvider connectivityProvider,
          Widget? child) {
        final currentUser = userProvider.getCurrentUser as Sellers;
        final tempSubscription = currentUser.getSubscriptions;
        bool isConnected = connectivityProvider.isConnected;

        if (tempSubscription.isEmpty) {
          return const Center(child: Text("There are no results"));
        }

        List<Subscription> activeSubscription = tempSubscription.where((n) {
          return DateTime.parse(n.endDate).isAfter(DateTime.now());
        }).toList();

        List<Subscription> pastSubscription = tempSubscription.where((n) {
          return DateTime.parse(n.endDate)
              .isBefore(DateTime.now().add(const Duration(days: 1)));
        }).toList();

        late List<Subscription> usedSubscription;

        switch (selectedButtonIndex) {
          case 0:
            usedSubscription = tempSubscription;
            break;
          case 1:
            usedSubscription = activeSubscription;
            break;
          case 2:
            usedSubscription = pastSubscription;
            break;
          default:
            usedSubscription = [];
            break;
        }

        if (usedSubscription.isEmpty) {
          return const Center(child: Text("There are no results"));
        }

        late Map<String, VendingMachine>? vendingMachineMap;
        if (isConnected) {
          final vendingMachines = vendingMachineProvider.vendingMachines;
          vendingMachineMap = {
            for (var vendingMachine in vendingMachines)
              vendingMachine.id!: vendingMachine
          };
        }

        return Expanded(
          child: ListView.separated(
            itemCount: usedSubscription.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final subscription = usedSubscription[index];
              String vendingMachineName = "Unnamed Vending Machine";
              VendingMachine? selectedVM;
              if (isConnected) {
                selectedVM = vendingMachineMap![subscription.column.getVmId]!;
                vendingMachineName = selectedVM.getDesc;
              }

              return ListTile(
                enabled: DateTime.parse(subscription.endDate)
                    .isAfter(DateTime.now()),
                leading:
                    const CircleAvatar(child: Icon(Icons.view_column_outlined)),
                title: Text(
                  vendingMachineName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  subscription.getColumn.getId!,
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                tileColor: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        StockManagementPage(
                      selectedSubscription: subscription,
                      selectedVendingMachine: selectedVM,
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
        );
      },
    );
  }
}
