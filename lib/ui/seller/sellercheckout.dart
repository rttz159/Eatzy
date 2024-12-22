import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final void Function(String paymentMethod) onPaymentSelected;

  const PaymentPage({
    super.key,
    required this.items,
    required this.onPaymentSelected,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  double get totalAmount => widget.items.fold(
        0,
        (sum, item) => sum + (item['price'] * item['qty']),
      );

  bool _isLoading = false;

  void _handlePayment(String paymentMethod) {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      widget.onPaymentSelected(paymentMethod);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Theme.of(context).primaryColor, size: 20),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        return ListTile(
                          title: Text(item['name'] + " subscription"),
                          subtitle: Text('Price: RM ${item['price']}'),
                          trailing: Text('Qty: ${item['qty']}'),
                        );
                      },
                    ),
                  ),
                  const Divider(thickness: 1),
                  Text(
                    'Total: RM ${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Payment Method:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    children: [
                      ElevatedButton(
                        onPressed: () => _handlePayment('Credit Card'),
                        child: const Text('Pay with Credit Card'),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () => _handlePayment('PayPal'),
                        child: const Text('Pay with PayPal'),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () => _handlePayment('Bank Transfer'),
                        child: const Text('Pay with Bank Transfer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
