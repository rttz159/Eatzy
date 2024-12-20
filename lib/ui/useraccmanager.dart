import 'package:assignment/services/userprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserAccManager extends StatefulWidget {
  const UserAccManager({super.key});

  @override
  State<UserAccManager> createState() => _UserAccManagerState();
}

class _UserAccManagerState extends State<UserAccManager> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Consumer<UserProvider>(
                builder:
                    (BuildContext context, UserProvider value, Widget? child) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).cardColor,
                          border: Border.all(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: value.getCurrentUser!.getImageUrl == null
                              ? Image.asset(
                                  "assets/logo/logo.png",
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  value.getCurrentUser!.getImageUrl!),
                        ),
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value.getCurrentUser!.getName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            value.getCurrentUser!.getEmail,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Place an Order",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                          bottom: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {},
                        title: const Text(
                          "Orders",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        leading: const Icon(
                          Icons.list_alt_outlined,
                          size: 32,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                          bottom: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {},
                        title: const Text(
                          "Zero Hunger Mini Program",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        leading: const Icon(
                          Icons.food_bank_outlined,
                          size: 32,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Utilities",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                          bottom: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {},
                        title: const Text(
                          "Help Centre",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        leading: const Icon(
                          Icons.help_outline_sharp,
                          size: 32,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                          bottom: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {},
                        title: const Text(
                          "Feedback",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        leading: const Icon(
                          Icons.feedback_outlined,
                          size: 32,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                          bottom: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {},
                        title: const Text(
                          "Settings",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        leading: const Icon(
                          Icons.settings,
                          size: 32,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                          bottom: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          Provider.of<UserProvider>(context, listen: false)
                              .signOutUser();
                        },
                        title: const Text(
                          "Log Out",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        leading: const Icon(
                          Icons.logout,
                          size: 32,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
