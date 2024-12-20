import 'package:assignment/services/pageprovider.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:assignment/ui/vendingmachinemap.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  String determineGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 0 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else if (hour >= 17 && hour <= 23) {
      return "Good Evening";
    } else {
      return "Hello";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 64, 16, 0),
      child: Column(
        children: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${determineGreeting()}, ${userProvider.getCurrentUser?.getName}",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w500),
                ),
              );
            },
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.list,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const VendingMachineMap(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        }),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFFABB17)
                            : Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    side: const BorderSide(
                      color: Color(0xFFFABB17),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  label: const Text(
                    "Make Order",
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.receipt_long,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Provider.of<PageProvider>(context, listen: false)
                        .changeTab(1);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF42B955)
                            : Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    side: const BorderSide(
                      color: Color(0xFF42B955),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  label: const Text(
                    "My Order",
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          CarouselSlider(
            options: CarouselOptions(height: 450.0, autoPlay: true),
            items: ["assets/poster/poster.png", "assets/poster/poster2.png"]
                .map((url) {
              return Builder(
                builder: (BuildContext context) {
                  return Image.asset(
                    url,
                    width: MediaQuery.of(context).size.width,
                  );
                },
              );
            }).toList(),
          ),
          ElevatedButton(
              onPressed: () {
                final provider =
                    Provider.of<UserProvider>(context, listen: false);
                provider.signOutUser();
              },
              child: const Text("log out")),
        ],
      ),
    );
  }
}
