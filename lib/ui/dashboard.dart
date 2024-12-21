import 'package:assignment/services/sellerpageprovider.dart';
import 'package:assignment/services/userpageprovider.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:assignment/ui/login.dart';
import 'package:assignment/ui/seller/sellerstructure.dart';
import 'package:assignment/ui/user/userstructure.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  void signOut() {
    final userprovider = Provider.of<UserProvider>(context, listen: false);
    userprovider.signOutUser();
  }

  @override
  Widget build(BuildContext context) {
    final userprovider = Provider.of<UserProvider>(context);

    if (userprovider.getCurrentUser == null) {
      return const LoginScreen();
    } else {
      Widget tempWidget = Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                  "An error has occurred, please contact the development team."),
              ElevatedButton(onPressed: signOut, child: const Text("Sign Out"))
            ],
          ),
        ),
      );
      bool? tempSeller = userprovider.isSeller;
      if (tempSeller != null) {
        if (tempSeller) {
          tempWidget = ChangeNotifierProvider(
              create: (BuildContext context) {
                return SellerPageProvider();
              },
              child: const SellerStructure());
        } else {
          tempWidget = ChangeNotifierProvider(
              create: (BuildContext context) {
                return UserPageProvider();
              },
              child: const UserStructure());
        }
      }
      return tempWidget;
    }
  }
}
