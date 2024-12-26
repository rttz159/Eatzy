import 'package:assignment/services/userpageprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserStructure extends StatefulWidget {
  const UserStructure({super.key});

  @override
  State<UserStructure> createState() => _UserStructureState();
}

class _UserStructureState extends State<UserStructure> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserPageProvider>(
      builder: (BuildContext context, UserPageProvider value, Widget? child) {
        return Scaffold(
          body: PageView(
            controller: value.pageController,
            onPageChanged: (idx) => value.onChange(idx),
            children: value.pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: value.selectedTab,
            onTap: (index) => value.changeTab(index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.list_rounded), label: "Order"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.discount_outlined), label: "Voucher"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle_rounded), label: "Account"),
            ],
          ),
        );
      },
    );
  }
}
