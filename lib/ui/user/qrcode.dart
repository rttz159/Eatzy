import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:assignment/datamodel/voucher.dart';

class QRCodePage extends StatelessWidget {
  final Voucher voucher;

  const QRCodePage({required this.voucher, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qrData = '''
      ID: ${voucher.id}
      Description: ${voucher.desc}
      Start Date: ${voucher.startDate}
      End Date: ${voucher.endDate}
      Discount: ${voucher.percentage}%
      ''';

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
      ),
      body: Center(
        child: QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: 350.0,
          gapless: true,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
