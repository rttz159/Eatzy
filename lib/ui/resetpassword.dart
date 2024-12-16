import 'package:assignment/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPasswordScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  String? emailErrorText;

  Future<void> _handleResetPassword() async {
    String email = _emailController.text.trim();
    final emailPattern = RegExp(r'[\w-\.]+@([\w-]+\.)+[\w-]{2,4}');

    if (!emailPattern.hasMatch(email) || email.isEmpty) {
      setState(() {
        emailErrorText = "Invalid Email";
      });
      Fluttertoast.showToast(msg: "Please Enter a Valid Email");
      return;
    } else {
      setState(() {
        emailErrorText = null;
      });
    }
    if (emailErrorText == null) {
      _authService.resetPassword(email);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        appBar: AppBar(
          title: const Text(
            "Reset Password",
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
                      "assets/logo/logo_cry_filled.png",
                      width: 150,
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "Enter your email, and we'll send you a link to change a new password",
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
                            const SizedBox(height: 20),
                            TextField(
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              decoration: InputDecoration(
                                  labelText: "Email",
                                  errorText: emailErrorText),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _handleResetPassword,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 32),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 5,
                              ),
                              child: const Text("Reset Password"),
                            ),
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
  }
}
