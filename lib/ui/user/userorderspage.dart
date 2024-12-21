import 'package:flutter/material.dart';

class UserOrderPage extends StatefulWidget {
  const UserOrderPage({super.key});

  @override
  State<UserOrderPage> createState() => _UserOrderPageState();
}

class _UserOrderPageState extends State<UserOrderPage> {
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
              "Orders",
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
          ],
        ),
      ),
    );
  }
}
