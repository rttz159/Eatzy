import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/datamodel/subscription.dart';
import 'package:assignment/datamodel/vendingmachine.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:assignment/services/vendingmachineprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int selectedButtonIndex = 0;
  List<String> buttonText = ["All", "Active", "Past"];

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
            const SizedBox(
              height: 20,
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
            const SizedBox(
              height: 50,
            ),
            Consumer<UserProvider>(
              builder:
                  (BuildContext context, UserProvider value, Widget? child) {
                if ((value.getCurrentUser as Sellers)
                    .getSubscriptions
                    .isEmpty) {
                  return const Center(child: Text("There are no results"));
                }

                List<Subscription> tempSubscription =
                    (value.getCurrentUser as Sellers).getSubscriptions;
                List<Subscription> activeSubscription =
                    tempSubscription.where((n) {
                  return DateTime.parse(n.endDate).isAfter(DateTime.now());
                }).toList();
                List<Subscription> pastSubscription =
                    tempSubscription.where((n) {
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
                    break;
                }
                final vendingMachines =
                    Provider.of<VendingMachineProvider>(context, listen: false)
                        .vendingMachines;
                return Expanded(
                  child: usedSubscription.isEmpty
                      ? const Center(child: Text("There are no results"))
                      : ListView(
                          children: usedSubscription.map((subscription) {
                            String vendingMachineName = "";
                            for (var y in vendingMachines) {
                              if (subscription.getColumn.getVmId == y.getId!) {
                                vendingMachineName = y.getDesc;
                              }
                            }
                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.view_column_outlined),
                              ),
                              title: Text(
                                vendingMachineName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                subscription.getColumn.getId!,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                              ),
                              tileColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                  : Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              onTap: () {},
                            );
                          }).toList(),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
