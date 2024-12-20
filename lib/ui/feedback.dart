import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _emailBodyController = TextEditingController();
  Future<void> sendEmail(String body) async {
    final Email email = Email(
      body: body,
      subject: 'Feedback',
      recipients: ['raintaroteng@gmail.com'],
      attachmentPaths: [],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      Fluttertoast.showToast(msg: 'feedback sent successfully!');
      ;
    } catch (error) {
      print('Error: $error');
      Fluttertoast.showToast(msg: 'Error sending feedback');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).colorScheme.tertiaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo/logo_filled.png",
                  height: 200,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Enter your feedback below:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailBodyController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Write your feedback here...',
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      String emailBody = _emailBodyController.text;
                      if (emailBody.isNotEmpty) {
                        sendEmail(emailBody);
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Please enter your feedback');
                      }
                    },
                    child: const Text('Send Feedback'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
