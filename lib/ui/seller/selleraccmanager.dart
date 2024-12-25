import 'package:assignment/services/connectivityprovider.dart';
import 'package:assignment/services/sellerpageprovider.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:assignment/ui/feedback.dart';
import 'package:assignment/ui/helpcentre.dart';
import 'package:assignment/ui/setting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SellerAccManager extends StatefulWidget {
  const SellerAccManager({super.key});

  @override
  State<SellerAccManager> createState() => _SellerAccManagerState();
}

class _SellerAccManagerState extends State<SellerAccManager> {
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
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Consumer<UserProvider>(
                builder:
                    (BuildContext context, UserProvider value, Widget? child) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Consumer<ConnectivityProvider>(
                        builder: (context, connectivity, child) {
                          return Container(
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
                              child: (value.getCurrentUser!.getImageUrl ==
                                          null ||
                                      !connectivity.isConnected)
                                  ? Image.asset(
                                      "assets/logo/logo.png",
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      value.getCurrentUser!.getImageUrl!,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                            ),
                          );
                        },
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Manage Your Business",
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
                                color: Theme.of(context).dividerColor,
                                width: 1),
                            bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1),
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            final provider = Provider.of<SellerPageProvider>(
                                context,
                                listen: false);
                            provider.changeTab(1);
                          },
                          title: const Text(
                            "Your Subscriptions",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          leading: const Icon(
                            Icons.menu,
                            size: 32,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1),
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            final provider = Provider.of<SellerPageProvider>(
                                context,
                                listen: false);
                            provider.changeTab(2);
                          },
                          title: const Text(
                            "Your Vouchers",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          leading: const Icon(
                            Icons.discount_outlined,
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
                            "Need Help?",
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
                                color: Theme.of(context).dividerColor,
                                width: 1),
                            bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1),
                          ),
                        ),
                        child: ListTile(
                          onTap: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const HelpCenterPage(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
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
                            bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1),
                          ),
                        ),
                        child: Consumer<ConnectivityProvider>(
                          builder: (context, connectivity, child) {
                            return ListTile(
                              enabled: connectivity.isConnected,
                              onTap: () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const FeedbackPage(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
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
                            );
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1),
                          ),
                        ),
                        child: Consumer<ConnectivityProvider>(
                          builder: (context, connectivity, child) {
                            return ListTile(
                              enabled: connectivity.isConnected,
                              onTap: () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const SettingPage(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
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
                            );
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1),
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
            ),
          ],
        ),
      ),
    );
  }
}
