import 'package:assignment/services/sellerpageprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SellerStructure extends StatefulWidget {
  const SellerStructure({super.key});

  @override
  State<SellerStructure> createState() => _SellerStructureState();
}

class _SellerStructureState extends State<SellerStructure> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SellerPageProvider>(
      builder: (BuildContext context, SellerPageProvider value, Widget? child) {
        return Scaffold(
          body: PageView(
            controller: value.pageController,
            children: value.pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: value.selectedTab,
            onTap: (index) => value.changeTab(index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.menu_sharp), label: "Subscriptions"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_outlined), label: "Analytics"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle_rounded), label: "Account"),
            ],
          ),
        );
      },
    );
  }
}
