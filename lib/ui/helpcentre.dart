import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});
  final List<Map<String, String>> qnaList = const [
    {
      'question': 'How do I use the vending machine?',
      'answer':
          'Simply open the app, select the item, and make a payment through the app.'
    },
    {
      'question': 'What payment methods are supported?',
      'answer': 'We support credit/debit cards and online banking options.'
    },
    {
      'question': 'Can I get a refund for a failed transaction?',
      'answer':
          'Yes, you can request a refund through contacting to our customer service if the item is not dispensed.'
    },
    {
      'question': 'Is there a way to view my past purchases?',
      'answer':
          'Yes, you can view your transaction history in the "My Orders" section of the app. This will show you details of all previous transactions.'
    },
    {
      'question': 'How do I find the nearest vending machine?',
      'answer':
          'The app will display a map of nearby vending machines. You can filter the search by machine name. Simply enable location services to see machines near you.'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Centre"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
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
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: qnaList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        title: Text(
                          qnaList[index]['question']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(12.0),
                              ),
                            ),
                            child: Text(
                              qnaList[index]['answer']!,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Center(
                child: Text(
                  "For further information or assistance, please contact +(60)103605169.",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
