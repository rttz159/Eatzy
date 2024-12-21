import 'dart:async';

import 'package:assignment/datamodel/normalusers.dart';
import 'package:assignment/services/clouddatabase.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ZeroHungerPage extends StatefulWidget {
  const ZeroHungerPage({super.key});

  @override
  State<ZeroHungerPage> createState() => _ZeroHungerPageState();
}

class _ZeroHungerPageState extends State<ZeroHungerPage> {
  bool isLoading = false;

  Future<void> _updateUserData() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = provider.getCurrentUser;
    CloudDatabase db = CloudDatabase();

    if (currentUser == null) {
      Fluttertoast.showToast(msg: "No user found to update.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    (currentUser as NormalUser).setIsSpecial = true;
    Timer(const Duration(seconds: 2), () {});

    try {
      await db.save(
          CloudDatabase.normalUsers, (currentUser as NormalUser).toJson(),
          docId: currentUser.getId);

      Fluttertoast.showToast(msg: "Application Success!!!");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Profile Update"),
            content: const Text(
                "Your application has been processed successfully. You will need to Sign In again."),
            actions: [
              TextButton(
                onPressed: () {
                  provider.signOutUser();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to apply: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
        builder: (BuildContext context, UserProvider value, Widget? child) {
      if (value.getCurrentUser == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
        return const Center(child: CircularProgressIndicator());
      }
      return Scaffold(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          appBar: AppBar(
            title: const Text(
              "Zero Hunger Member Application",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).appBarTheme.backgroundColor!,
                  Theme.of(context).colorScheme.tertiaryContainer
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/logo/logo_filled.png",
                        width: 150,
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          "Zero Hunger Member can redeem vouchers to purchase food at the lowest prices or even get meals for free, helping them to alleviating financial strain.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                          child: Column(
                            children: [
                              ((value.getCurrentUser as NormalUser)
                                      .getIsSpecial)
                                  ? const Center(child: Text("Applied"))
                                  : (isLoading
                                      ? LoadingAnimationWidget
                                          .staggeredDotsWave(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: 20)
                                      : ElevatedButton(
                                          onPressed: () {
                                            _updateUserData();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 32),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            elevation: 5,
                                          ),
                                          child: const Text("Apply"),
                                        ))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ));
    });
  }
}
