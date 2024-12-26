import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/datamodel/voucher.dart';
import 'package:assignment/services/connectivityprovider.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/clouddatabase.dart';

class SellerVoucherPage extends StatefulWidget {
  const SellerVoucherPage({super.key});

  @override
  State<SellerVoucherPage> createState() => _SellerVoucherPageState();
}

class _SellerVoucherPageState extends State<SellerVoucherPage> {
  int selectedButtonIndex = 0;
  bool selection = true;
  List<String> buttonText = ["Generate", "List"];

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();

  String? idErrorText;
  String? descErrorText;
  String? startDateErrorText;
  String? endDateErrorText;
  String? percentageErrorText;

  final DateFormat _dateFormat = DateFormat("dd/MM/yyyy");
  DateTime? _endDate;
  DateTime? _startDate;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000, 1),
      lastDate: DateTime(2099, 12, 31),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = _dateFormat.format(_startDate!);
        startDateErrorText = null;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000, 1),
      lastDate: DateTime(2099, 12, 31),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endDateController.text = _dateFormat.format(_endDate!);
        endDateErrorText = null;
      });
    }
  }

  void _clearVoucher() {
    _idController.clear();
    _descController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _percentageController.clear();
    setState(() {
      idErrorText = null;
      descErrorText = null;
      startDateErrorText = null;
      endDateErrorText = null;
      percentageErrorText = null;
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _handleVoucher() async {
    String id = _idController.text.trim();
    String desc = _descController.text.trim();
    String percentageString = _percentageController.text.trim();
    double percentage = 0;

    final idPattern = RegExp(r'^[a-zA-Z0-9]+$');
    final percentagePattern = RegExp(r'^\d{1,2}$');

    if (_startDate == null) {
      setState(() {
        startDateErrorText = "Please choose a Start Date";
      });
    }

    if (_endDate == null) {
      setState(() {
        endDateErrorText = "Please choose an End Date";
      });
    } else if (_startDate != null && _endDate!.isBefore(_startDate!)) {
      setState(() {
        endDateErrorText = "End Date must be after Start Date";
      });
    }

    if (!idPattern.hasMatch(id) || id.isEmpty) {
      setState(() {
        idErrorText = "Invalid Voucher Code";
      });
      Fluttertoast.showToast(msg: "Invalid Voucher Code");
    } else {
      setState(() {
        idErrorText = null;
      });
    }

    if (!percentagePattern.hasMatch(percentageString) ||
        percentageString.isEmpty) {
      setState(() {
        percentageErrorText = "Invalid Discount Percentage (within 1 to 99)";
      });
      Fluttertoast.showToast(msg: "Invalid Discount Percentage");
    } else {
      setState(() {
        percentageErrorText = null;
        percentage = double.parse(percentageString);
      });
    }

    if (desc.isEmpty) {
      setState(() {
        descErrorText = "Invalid Description";
      });
      Fluttertoast.showToast(msg: "Invalid Description");
    } else {
      setState(() {
        descErrorText = null;
      });
    }

    if (idErrorText == null &&
        descErrorText == null &&
        startDateErrorText == null &&
        endDateErrorText == null &&
        percentageErrorText == null) {
      Voucher newVoucher = Voucher(
        id: id,
        desc: desc,
        endDate: _endDate!.toIso8601String(),
        startDate: _startDate!.toIso8601String(),
        percentage: percentage,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voucher successfully created!')),
      );
      final provider = Provider.of<UserProvider>(context, listen: false);
      CloudDatabase db = CloudDatabase();
      Sellers currentSeller = provider.getCurrentUser! as Sellers;

      currentSeller.getVouchers.add(newVoucher);
      db.save(CloudDatabase.seller, currentSeller.toJson(),
          docId: currentSeller.getId);
      provider.saveUserToLocalStorage();

      _clearVoucher();
      setState(() {
        selection = false;
        selectedButtonIndex = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
        child: Consumer<ConnectivityProvider>(
          builder: (context, connectivityProvider, child) {
            if (!connectivityProvider.isConnected) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No internet connection",
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                const Center(
                  child: Text(
                    "Vouchers",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(buttonText.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 40),
                          backgroundColor: selectedButtonIndex == index
                              ? Theme.of(context).colorScheme.inversePrimary
                              : Theme.of(context).dialogBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedButtonIndex = index;
                            selection = index == 0;
                          });
                        },
                        child: Text(buttonText[index]),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 50),
                Expanded(
                  child: SingleChildScrollView(
                    child: selection
                        ? Column(
                            children: [
                              TextField(
                                  controller: _idController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    labelText: "Voucher Code",
                                    hintText:
                                        "Alphabets and number without separators",
                                    errorText: idErrorText,
                                  ),
                                  onChanged: (value) {
                                    _idController.text = value.toUpperCase();
                                  }),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _descController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: "Description",
                                  hintText: "Eg. 50% for Christmas!",
                                  errorText: descErrorText,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                readOnly: true,
                                controller: _startDateController,
                                decoration: InputDecoration(
                                  labelText: "Start Date",
                                  errorText: startDateErrorText,
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      _selectStartDate(context);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(13),
                                      child: const Icon(
                                        Icons.calendar_month_outlined,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                readOnly: true,
                                controller: _endDateController,
                                decoration: InputDecoration(
                                  labelText: "End Date",
                                  errorText: endDateErrorText,
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      _selectEndDate(context);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(13),
                                      child: const Icon(
                                        Icons.calendar_month_outlined,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _percentageController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Discount Percentage",
                                  hintText: "Write number only",
                                  errorText: percentageErrorText,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: _clearVoucher,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 32),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: const Text("Clear"),
                                  ),
                                  const SizedBox(width: 20),
                                  ElevatedButton(
                                    onPressed: _handleVoucher,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 32),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: const Text("Create"),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Consumer<UserProvider>(
                            builder: (context, provider, child) {
                              Sellers currentSeller =
                                  provider.getCurrentUser! as Sellers;
                              List<Voucher> vouchers =
                                  currentSeller.getVouchers;

                              if (vouchers.isEmpty) {
                                return const Center(
                                  child: Text("No vouchers available"),
                                );
                              }

                              // Categorize vouchers
                              DateTime now = DateTime.now();
                              List<Voucher> activeVouchers = [];
                              List<Voucher> upcomingVouchers = [];
                              List<Voucher> expiredVouchers = [];

                              for (var voucher in vouchers) {
                                DateTime startDate =
                                    DateTime.parse(voucher.startDate);
                                DateTime endDate =
                                    DateTime.parse(voucher.endDate);

                                if (now.isAfter(
                                    endDate.add(const Duration(days: 1)))) {
                                  expiredVouchers.add(voucher);
                                } else if (now.isBefore(startDate)) {
                                  upcomingVouchers.add(voucher);
                                } else {
                                  activeVouchers.add(voucher);
                                }
                              }

                              Widget buildVoucherList(String title,
                                  List<Voucher> vouchers, Color color) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: vouchers.length,
                                      itemBuilder: (context, index) {
                                        Voucher voucher = vouchers[index];
                                        final startDate = voucher.startDate
                                                .contains('-')
                                            ? DateTime.parse(voucher.startDate)
                                            : DateFormat("dd/MM/yyyy")
                                                .parse(voucher.startDate);

                                        final endDate = voucher.endDate
                                                .contains('-')
                                            ? DateTime.parse(voucher.endDate)
                                            : DateFormat("dd/MM/yyyy")
                                                .parse(voucher.endDate);
                                        return Card(
                                          color: color,
                                          elevation: 4,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 16),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 16),
                                                child: Image.asset(
                                                  "assets/logo/logo_filled.png",
                                                  width: 70,
                                                  height: 70,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "${voucher.id}",
                                                      style: const TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${voucher.percentage.toInt()}% DISCOUNT",
                                                      style: const TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      voucher.desc,
                                                      style: const TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${DateFormat('dd/MM/yyyy').format(startDate)} to ${DateFormat('dd/MM/yyyy').format(endDate)}",
                                                      style: const TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black45,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (activeVouchers.isNotEmpty)
                                      buildVoucherList(
                                          "Active Vouchers",
                                          activeVouchers,
                                          Colors.green.shade100),
                                    if (upcomingVouchers.isNotEmpty)
                                      buildVoucherList(
                                          "Upcoming Vouchers",
                                          upcomingVouchers,
                                          Colors.green.shade300),
                                    if (expiredVouchers.isNotEmpty)
                                      buildVoucherList("Expired Vouchers",
                                          expiredVouchers, Colors.grey),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
