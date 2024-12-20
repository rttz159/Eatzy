import 'package:assignment/ui/userhomepage.dart';
import 'package:flutter/material.dart';

class PageProvider extends ChangeNotifier {
  final PageController _pageController = PageController();
  int _selectedTab = 0;
  final List<Widget> _pages = [
    const Center(
      child: UserHomePage(),
    ),
    const Center(
      child: Text("Orders"),
    ),
    const Center(
      child: Text("Voucher"),
    ),
    const Center(
      child: Text("Account"),
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
