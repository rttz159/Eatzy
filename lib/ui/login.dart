import 'package:assignment/services/userprovider.dart';
import 'package:assignment/ui/resetpassword.dart';
import 'package:assignment/ui/signup.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../services/auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? emailErrorText;
  String? passwordErrorText;
  bool passwordVisible = true;
  bool isLoading = false;

  Future<void> _handleLogin() async {
    setState(() {
      isLoading = true;
    });
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    final emailPattern = RegExp(r'[\w-\.]+@([\w-]+\.)+[\w-]{2,4}');
    final passwordPattern =
        RegExp(r'(?=(.*[a-zA-Z]))(?=(.*\d))(?=(.*[\W_]))[A-Za-z\d\W_]{7,}');

    if (!emailPattern.hasMatch(email) || email.isEmpty) {
      setState(() {
        emailErrorText = "Invalid Email";
      });
      Fluttertoast.showToast(msg: "Invalid Email");
    } else {
      setState(() {
        emailErrorText = null;
      });
    }

    if (!passwordPattern.hasMatch(password) || password.isEmpty) {
      setState(() {
        passwordErrorText = "Invalid Password";
      });
      Fluttertoast.showToast(
          msg:
              "Invalid Password (more than 6 characters with at least one digit, one character and one special character)");
    } else {
      setState(() {
        passwordErrorText = null;
      });
    }

    if (emailErrorText == null && passwordErrorText == null) {
      var user = await _authService.signIn(
        email: email,
        password: password,
        context: context,
      );

      setState(() {
        isLoading = false;
      });

      if (user != null) {
        final userprovider = Provider.of<UserProvider>(context, listen: false);
        userprovider.setCurrentUser = user;
        _authService.setCurrentUser = user;
        await userprovider.saveUserToLocalStorage();
        Fluttertoast.showToast(msg: "Login successful!");
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
                    Center(
                      child: Image.asset(
                        "assets/logo/eatzy.png",
                        width: 150,
                      ),
                    ),
                    const Center(
                      child: Text(
                        "Serving Solution, Ending Hunger",
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF81d855)),
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
                            Image.asset(
                              "assets/logo/logo_filled.png",
                              width: 150,
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              decoration: InputDecoration(
                                  labelText: "Email",
                                  errorText: emailErrorText),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: "Password",
                                errorText: passwordErrorText,
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.all(13),
                                      child: Icon(
                                          passwordVisible
                                              ? FontAwesomeIcons.eyeSlash
                                              : Icons.remove_red_eye_sharp,
                                          size: 20)),
                                ),
                              ),
                              obscureText: passwordVisible,
                            ),
                            const SizedBox(height: 20),
                            isLoading
                                ? LoadingAnimationWidget.staggeredDotsWave(
                                    color: Theme.of(context).primaryColor,
                                    size: 20)
                                : ElevatedButton(
                                    onPressed: _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 32),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      elevation: 5,
                                    ),
                                    child: const Text("Login"),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const ResetPasswordScreen(),
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
                                })),
                        child: const Text("Forgot Password?")),
                    const Text("or"),
                    TextButton(
                        onPressed: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const SignupScreen(),
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
                        child: const Text("Don't have an account?")),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
