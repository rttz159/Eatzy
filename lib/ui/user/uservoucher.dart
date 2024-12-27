import 'dart:convert';
import 'dart:io';
import 'package:assignment/datamodel/normalusers.dart';
import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/datamodel/voucher.dart';
import 'package:assignment/services/clouddatabase.dart';
import 'package:assignment/services/connectivityprovider.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'qrcode.dart';

class UserVoucherPage extends StatefulWidget {
  const UserVoucherPage({super.key});

  @override
  State<UserVoucherPage> createState() => _UserVoucherPageState();
}

class _UserVoucherPageState extends State<UserVoucherPage> {
  Voucher zhvoucher = Voucher(
    id: "ZEROHUNGER",
    desc: "ENJOY YOUR MEALS",
    endDate: DateTime(2099, 12, 31).toIso8601String(),
    startDate: DateTime(2000, 1, 1).toIso8601String(),
    percentage: 90,
  );

  late Future<List<Sellers>> sellersFuture;
  final String _localFileName = "sellers_data.json";
  final CloudDatabase _db = CloudDatabase();

  @override
  void initState() {
    super.initState();
    sellersFuture = _fetchSellers();
  }

  Future<List<Sellers>> _fetchSellers() async {
    final connectivity =
        Provider.of<ConnectivityProvider>(context, listen: false);
    if (!connectivity.isConnected) {
      return await _loadDocumentsFromLocal();
    }
    try {
      var sellerList = await _db.read(CloudDatabase.seller);
      var sellers = sellerList.map((doc) => Sellers.fromJson(doc)).toList();
      await _saveDocumentsLocally(sellers);
      return sellers;
    } catch (e) {
      print("Error fetching sellers from cloud: $e");
      return await _loadDocumentsFromLocal();
    }
  }

  Future<void> _saveDocumentsLocally(List<Sellers> sellers) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_localFileName');
      final data =
          jsonEncode(sellers.map((seller) => seller.toJson()).toList());
      await file.writeAsString(data);
    } catch (e) {
      debugPrint("Failed to save sellers locally: $e");
    }
  }

  Future<List<Sellers>> _loadDocumentsFromLocal() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_localFileName');
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final jsonList = jsonDecode(contents) as List<dynamic>;
      return jsonList
          .map((json) => Sellers.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Failed to load sellers from local storage: $e");
      return [];
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
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
            child: Consumer<ConnectivityProvider>(
              builder: (context, connectivityProvider, child) {
                return Column(
                  children: [
                    const Center(
                      child: Text(
                        "Vouchers",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if ((value.getCurrentUser as NormalUser).getIsSpecial)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  QRCodePage(voucher: zhvoucher),
                            ),
                          );
                        },
                        child: _buildSpecialVoucherTile(),
                      ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: FutureBuilder<List<Sellers>>(
                        future: sellersFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}"));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text("No sellers found."));
                          }

                          final sellers = snapshot.data!;
                          return _buildSellersList(sellers);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecialVoucherTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.greenAccent.shade400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              "assets/logo/logo_filled.png",
              width: 70,
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${zhvoucher.id}",
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "${zhvoucher.percentage.toInt()}% DISCOUNT",
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  zhvoucher.desc,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellersList(List<Sellers> sellers) {
    return ListView.builder(
      itemCount: sellers.length,
      itemBuilder: (context, index) {
        final seller = sellers[index];
        final activeVouchers = seller.getVouchers.where((voucher) {
          final now = DateTime.now();
          final startDate = DateTime.parse(voucher.startDate);
          final endDate = DateTime.parse(voucher.endDate);
          return startDate.isBefore(now) &&
              endDate.add(const Duration(days: 1)).isAfter(now);
        }).toList();

        if (activeVouchers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          color: Colors.green.shade700,
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.name,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                ...activeVouchers
                    .map((voucher) => _buildVoucherTile(voucher))
                    .toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoucherTile(Voucher voucher) {
    final startDate = DateTime.parse(voucher.startDate);
    final endDate = DateTime.parse(voucher.endDate);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRCodePage(voucher: voucher),
          ),
        );
      },
      child: Container(
        width: 355,
        height: 125,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.lightGreen.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Colors.black12, width: 1),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Image.asset(
                "assets/logo/logo_filled.png",
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${voucher.id}",
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "${voucher.percentage.toInt()}% DISCOUNT",
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
