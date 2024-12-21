import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/services/userprovider.dart';
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
                  return const Center(
                      child: Text("There are no subscriptions"));
                }

                return const Text("Testing");
              },
            ),
          ],
        ),
      ),
    );
  }
}
