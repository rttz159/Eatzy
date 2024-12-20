import 'package:assignment/ui/selleraccmanager.dart';
import 'package:assignment/ui/sellerhomepage.dart';
import 'package:flutter/material.dart';

class SellerPageProvider extends ChangeNotifier {
  final PageController _pageController = PageController();
  int _selectedTab = 0;
  final List<Widget> _pages = [
    const Center(
      child: SellerHomePage(),
    ),
    const Center(
      child: Text("Orders"),
    ),
    const Center(
      child: Text("Voucher"),
    ),
    const Center(
      child: SellerAccManager(),
    ),
  ];

  PageController get pageController => _pageController;
  List<Widget> get pages => _pages;
  int get selectedTab => _selectedTab;

  void changeTab(int index) {
    _selectedTab = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }
}
