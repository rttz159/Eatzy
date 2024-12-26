import 'package:assignment/ui/user/useraccmanager.dart';
import 'package:assignment/ui/user/userhomepage.dart';
import 'package:assignment/ui/user/userorderspage.dart';
import 'package:assignment/ui/user/uservoucher.dart';
import 'package:flutter/material.dart';

class UserPageProvider extends ChangeNotifier {
  final PageController _pageController = PageController();
  int _selectedTab = 0;
  final List<Widget> _pages = [
    const Center(
      child: UserHomePage(),
    ),
    const Center(
      child: UserOrderPage(),
    ),
    const Center(
      child: UserVoucherPage(),
    ),
    const Center(
      child: UserAccManager(),
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

  void onChange(int idx) {
    _selectedTab = idx;
    notifyListeners();
  }
}
