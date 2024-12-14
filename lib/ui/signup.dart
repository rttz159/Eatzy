import 'package:assignment/datamodel/sellers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth.dart';
import '../datamodel/normalusers.dart';
import 'package:intl/intl.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  DateTime? selectedDate;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _icController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  String? emailErrorText;
  String? passwordErrorText;
  String? nameErrorText;
  String? icErrorText;
  String? birthDateErrorText;
  bool? selectedType;
  bool passwordVisible = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900, 1),
        lastDate: DateTime.now());

    final format = DateFormat("dd/MM/yyyy");
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _birthDateController.text = format.format(selectedDate!);
    }
  }

  Future<void> _handleSignupNormalUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    String ic = _icController.text.trim();

    final emailPattern = RegExp(r'[\w-\.]+@([\w-]+\.)+[\w-]{2,4}');
    final passwordPattern =
        RegExp(r'(?=(.*[a-zA-Z]))(?=(.*\d))(?=(.*[\W_]))[A-Za-z\d\W_]{7,}');
    final icPattern = RegExp(r'\d{12}');

    if (selectedDate == null) {
      birthDateErrorText = "Please choose a date";
    } else {
      birthDateErrorText = null;
    }

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

    if (!icPattern.hasMatch(ic) || ic.isEmpty) {
      setState(() {
        icErrorText = "Invalid IC";
      });
      Fluttertoast.showToast(msg: "Invalid IC (12 digits without separator)");
    } else {
      setState(() {
        icErrorText = null;
      });
    }

    if (!name.isNotEmpty) {
      setState(() {
        nameErrorText = "Invalid Name";
      });
      Fluttertoast.showToast(msg: "Invalid Name");
    } else {
      setState(() {
        nameErrorText = null;
      });
    }

    if (emailErrorText == null &&
        passwordErrorText == null &&
        nameErrorText == null &&
        icErrorText == null &&
        birthDateErrorText == null) {
      NormalUser newUser = NormalUser(
        id: null,
        uid: null,
        name: name,
        email: email,
        ic: ic,
        birthDate: selectedDate!.toIso8601String(),
        isSpecial: false,
      );

      bool success = await _authService.signUpWithDetails(
        email: email,
        password: password,
        tempUser: newUser,
        context: context,
      );

      if (success) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleSignupSeller() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    String ic = _icController.text.trim();

    final emailPattern = RegExp(r'[\w-\.]+@([\w-]+\.)+[\w-]{2,4}');
    final passwordPattern =
        RegExp(r'(?=(.*[a-zA-Z]))(?=(.*\d))(?=(.*[\W_]))[A-Za-z\d\W_]{7,}');
    final icPattern = RegExp(r'\d{12}');

    if (selectedDate == null) {
      birthDateErrorText = "Please choose a date";
    } else {
      birthDateErrorText = null;
    }

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

    if (!icPattern.hasMatch(ic) || ic.isEmpty) {
      setState(() {
        icErrorText = "Invalid IC";
      });
      Fluttertoast.showToast(msg: "Invalid IC (12 digits without separator)");
    } else {
      setState(() {
        icErrorText = null;
      });
    }

    if (!name.isNotEmpty) {
      setState(() {
        nameErrorText = "Invalid Name";
      });
      Fluttertoast.showToast(msg: "Invalid Name");
    } else {
      setState(() {
        nameErrorText = null;
      });
    }

    if (emailErrorText == null &&
        passwordErrorText == null &&
        nameErrorText == null &&
        icErrorText == null &&
        birthDateErrorText == null) {
      Sellers newUser = Sellers(
        id: null,
        uid: null,
        name: name,
        email: email,
        ic: ic,
        birthDate: selectedDate!.toIso8601String(),
      );

      bool success = await _authService.signUpWithDetails(
        email: email,
        password: password,
        tempUser: newUser,
        context: context,
      );

      if (success) {
        Navigator.pop(context);
      }
    }
  }

  Widget selectLayout() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Scaffold(
        appBar: AppBar(
            title: const Text("Select Type for Signing Up"),
            backgroundColor: Colors.transparent),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedType = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0)),
                  elevation: 5,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/logo/buyer.png",
                        height: 250,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Normal User",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedType = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.tertiaryContainer,
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0)),
                  elevation: 5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/logo/partner.png",
                        height: 250,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Seller Registration",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget signUpUser() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 5,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/logo/eatzy.png",
                      width: 180,
                    ),
                    const Text(
                      "Sign Up for Normal User",
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Fill in your details",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        labelText: "Email", errorText: emailErrorText),
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
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        labelText: "Name", errorText: nameErrorText),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _icController,
                    decoration: InputDecoration(
                        labelText: "IC",
                        hintText: "12 digits without separators",
                        errorText: icErrorText),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    readOnly: true,
                    controller: _birthDateController,
                    decoration: InputDecoration(
                      labelText: "Birth Date",
                      errorText: birthDateErrorText,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          _selectDate(context);
                        },
                        child: Container(
                            margin: const EdgeInsets.all(13),
                            child: const Icon(Icons.calendar_month_outlined,
                                size: 20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _handleSignupNormalUser,
                    child: Text("Sign Up"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
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

  Widget signUpSeller() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 5,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/logo/eatzy.png",
                      width: 180,
                    ),
                    const Text(
                      "Sign Up for Sellers",
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Fill in your details",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        labelText: "Email", errorText: emailErrorText),
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
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        labelText: "Name", errorText: nameErrorText),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _icController,
                    decoration: InputDecoration(
                        labelText: "IC",
                        hintText: "12 digits without separators",
                        errorText: icErrorText),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    readOnly: true,
                    controller: _birthDateController,
                    decoration: InputDecoration(
                      labelText: "Birth Date",
                      errorText: birthDateErrorText,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          _selectDate(context);
                        },
                        child: Container(
                            margin: const EdgeInsets.all(13),
                            child: const Icon(Icons.calendar_month_outlined,
                                size: 20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _handleSignupSeller,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    child: const Text("Sign Up"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: selectedType == null
            ? selectLayout()
            : (selectedType! ? signUpUser() : signUpSeller()),
      ),
    );
  }
}
