import 'package:assignment/datamodel/column.dart';
import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/datamodel/subscription.dart';
import 'package:assignment/datamodel/vendingmachine.dart';
import 'package:assignment/services/clouddatabase.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:assignment/ui/arguidance.dart';
import 'package:assignment/ui/seller/sellercheckout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

class SellersSubscribePage extends StatefulWidget {
  final VendingMachine vendingMachine;
  const SellersSubscribePage({super.key, required this.vendingMachine});

  @override
  State<SellersSubscribePage> createState() => _SellersSubscribePageState();
}

class _SellersSubscribePageState extends State<SellersSubscribePage> {
  late VendingMachine _vendingMachine;
  late List<VendingMachineColumn> columns;
  late TextEditingController _monthController;
  final ScrollController _scrollController = ScrollController();
  final format = intl.NumberFormat("######0.0#");
  double _rental = 800.0;
  String? _monthErrorString;
  int? indexSelected;

  @override
  void initState() {
    super.initState();
    _vendingMachine = widget.vendingMachine;
    columns = _vendingMachine.getColumns;
    _monthController = TextEditingController();
    _monthController.text = "1";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _navigateToPaymentPage() {
    if (indexSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a column.')),
      );
      return;
    }

    final int? months = int.tryParse(_monthController.text);
    if (months == null || months <= 0) {
      setState(() {
        _monthErrorString = "Invalid Integer";
      });
      return;
    }

    setState(() {
      _monthErrorString = null;
    });

    final selectedColumn = {
      'name': columns[indexSelected!].getId,
      'price': 800,
      'qty': months,
    };

    Navigator.push(
      context,
      PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => PaymentPage(
                items: [selectedColumn],
                onPaymentSelected: (paymentMethod) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Payment Method: $paymentMethod success!')),
                  );
                  final provider =
                      Provider.of<UserProvider>(context, listen: false);
                  Sellers currentSeller = provider.getCurrentUser! as Sellers;
                  final today = DateTime.now();
                  CloudDatabase db = CloudDatabase();

                  columns[indexSelected!].setIsAvailable = false;
                  currentSeller.getSubscriptions.add(Subscription(
                      id: currentSeller.getSubscriptions.length.toString(),
                      sellerId: currentSeller.getId!,
                      startDate: today.toIso8601String(),
                      endDate: today
                          .add(Duration(days: (months * 30)))
                          .toIso8601String(),
                      column: columns[indexSelected!],
                      products: []));
                  db.save(CloudDatabase.seller, currentSeller.toJson(),
                      docId: currentSeller.getId);
                  db.save(
                      CloudDatabase.vendingMachine, _vendingMachine.toJson(),
                      docId: _vendingMachine.getId);
                  provider.saveUserToLocalStorage();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            _vendingMachine.getDesc,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.help,
                size: 32,
              ),
              onPressed: () => Navigator.push(
                context,
                PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const ArApp(),
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
            )
          ],
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Center(
                    child: Text(
                  "Please select an available column.",
                  style: TextStyle(fontSize: 16),
                )),
                const SizedBox(height: 10),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 1.25,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          "assets/vendingmachine.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width / 6.5,
                        top: MediaQuery.of(context).size.height / 3.75,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.25,
                            height: MediaQuery.of(context).size.height / 3,
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: columns.length,
                                  itemBuilder: (context, index) {
                                    final bool isSelected =
                                        indexSelected == index;
                                    return ElevatedButton(
                                      onPressed: columns[index].isAvailable
                                          ? () {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Selected: ${columns[index].getId}')),
                                              );
                                              setState(() {
                                                indexSelected = index;
                                              });
                                              _scrollToBottom();
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(40, 40),
                                        backgroundColor: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                            : (columns[index].isAvailable
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer
                                                : (Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey.shade700
                                                    : Colors.grey.shade300)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                          child: Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                        .brightness ==
                                                    Brightness.dark
                                                ? (isSelected
                                                    ? Colors.black
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onTertiaryContainer)
                                                : (isSelected
                                                    ? Colors.white
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onTertiaryContainer)),
                                      )),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "Column Details",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          indexSelected == null
                              ? const Text("Column chose: [None]")
                              : Text(
                                  "Column chose: ${columns[indexSelected!].getId}"),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              const Text("Number of Month: "),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _monthController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Month",
                                    errorText: _monthErrorString,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      int? validInt = int.tryParse(value);
                                      if (validInt == null || validInt == 0) {
                                        _monthErrorString = "Invalid Integer";
                                      } else {
                                        _monthErrorString = null;
                                        _rental = validInt * 800;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text("Rental Amount: RM ${format.format(_rental)}"),
                          const SizedBox(
                            height: 30,
                          ),
                          Center(
                            child: ElevatedButton(
                                onPressed: _navigateToPaymentPage,
                                child: const Text("Checkout")),
                          )
                        ]),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
