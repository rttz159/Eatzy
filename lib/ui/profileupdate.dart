import 'package:assignment/datamodel/normalusers.dart';
import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/services/clouddatabase.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DateTime? selectedDate;
  String? _selectedImageUrl;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _icController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final format = DateFormat("dd/MM/yyyy");
  String? nameErrorText;
  String? icErrorText;
  String? birthDateErrorText;
  bool? selectedType;
  bool passwordVisible = true;
  bool isLoading = false;
  bool isEditing = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900, 1),
        lastDate: DateTime.now());

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _birthDateController.text = format.format(selectedDate!);
    }
  }

  Future<void> _pickImageFromUrl() async {
    final TextEditingController urlController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Image URL"),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: "Paste the image URL here",
            ),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(urlController.text.trim());
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    final imageUrl = urlController.text.trim();

    if (imageUrl.isNotEmpty) {
      try {
        setState(() {
          _selectedImageUrl = imageUrl;
        });

        Fluttertoast.showToast(msg: "Image URL selected successfully.");
      } catch (e) {
        Fluttertoast.showToast(msg: "Invalid image URL.");
      }
    } else {
      Fluttertoast.showToast(msg: "No URL provided.");
    }
  }

  void _resetEditing(UserProvider provider) {
    _nameController.text = provider.getCurrentUser?.getName ?? '';
    _icController.text = provider.getCurrentUser?.getIc ?? '';
    _birthDateController.text = provider.getCurrentUser != null
        ? format.format(DateTime.parse(provider.getCurrentUser!.getBirthDate))
        : '';
    setState(() {
      isEditing = false;
    });
  }

  Future<void> _updateUserData() async {
    if (!isEditing) {
      return;
    }
    final provider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = provider.getCurrentUser;
    CloudDatabase db = CloudDatabase();

    if (currentUser == null) {
      Fluttertoast.showToast(msg: "No user found to update.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final icPattern = RegExp(r'\d{12}');
    String name = _nameController.text.trim();
    String ic = _icController.text.trim();

    if (!icPattern.hasMatch(ic) || ic.isEmpty || ic.length > 12) {
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

    if (nameErrorText == null && icErrorText == null) {
      try {
        currentUser.setName = name;
        currentUser.setIc = ic;
        if (selectedDate != null) {
          currentUser.setBirthDate = selectedDate!.toIso8601String();
        }
        if (_selectedImageUrl != null) {
          currentUser.setImageUrl = _selectedImageUrl;
        }

        if (currentUser is NormalUser) {
          await db.save(
              CloudDatabase.normalUsers, (currentUser as NormalUser).toJson(),
              docId: currentUser.getId);
        } else {
          print("current user's id = ${currentUser.getId}");
          await db.save(CloudDatabase.seller, (currentUser as Sellers).toJson(),
              docId: currentUser.getId);
        }

        Fluttertoast.showToast(msg: "Profile updated successfully.");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Profile Update"),
              content: const Text(
                  "Your profile has been updated successfully. You will need to Sign In again."),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                    });
                    provider.signOutUser();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } catch (e) {
        Fluttertoast.showToast(msg: "Failed to update profile: $e");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = provider.getCurrentUser!.getName;
    _icController.text = provider.getCurrentUser!.getIc;
    _birthDateController.text =
        format.format(DateTime.parse(provider.getCurrentUser!.getBirthDate));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _icController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.getCurrentUser == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          });
          return const Center(child: CircularProgressIndicator());
        }

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
                          "Update Profile",
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
                        "Please Click Edit to Start Editing Profile",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 100,
                        height: 100,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).cardColor,
                          border: Border.all(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: isEditing
                              ? (_selectedImageUrl == null
                                  ? (userProvider.getCurrentUser!.getImageUrl ==
                                          null
                                      ? Image.asset(
                                          "assets/logo/logo.png",
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          userProvider
                                              .getCurrentUser!.getImageUrl!,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          (loadingProgress
                                                                  .expectedTotalBytes ??
                                                              1)
                                                      : null,
                                                ),
                                              );
                                            }
                                          },
                                        ))
                                  : Image.network(
                                      _selectedImageUrl!,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          );
                                        }
                                      },
                                    ))
                              : (userProvider.getCurrentUser!.getImageUrl ==
                                      null
                                  ? Image.asset(
                                      "assets/logo/logo.png",
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      userProvider.getCurrentUser!.getImageUrl!,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          );
                                        }
                                      },
                                    )),
                        ),
                      ),
                      IconButton(
                        onPressed: isEditing ? _pickImageFromUrl : null,
                        icon: Icon(isEditing
                            ? Icons.link
                            : Icons.disabled_by_default_outlined),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _nameController,
                        enabled: isEditing,
                        decoration: InputDecoration(
                            labelText: "Name", errorText: nameErrorText),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _icController,
                        keyboardType: TextInputType.number,
                        enabled: isEditing,
                        decoration: InputDecoration(
                            labelText: "IC",
                            hintText: "12 digits without separators",
                            errorText: icErrorText),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        readOnly: true,
                        controller: _birthDateController,
                        enabled: isEditing,
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          isLoading
                              ? LoadingAnimationWidget.staggeredDotsWave(
                                  color: Theme.of(context).primaryColor,
                                  size: 20)
                              : ElevatedButton(
                                  onPressed: _updateUserData,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 32),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 5,
                                  ),
                                  child: const Text("Update"),
                                ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isEditing = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 5,
                            ),
                            child: const Text("Edit"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _resetEditing(userProvider);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 5,
                            ),
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
