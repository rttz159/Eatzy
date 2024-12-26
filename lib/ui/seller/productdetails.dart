// ignore_for_file: must_be_immutable

import 'package:assignment/datamodel/products.dart';
import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/datamodel/subscription.dart';
import 'package:assignment/services/clouddatabase.dart';
import 'package:assignment/services/connectivityprovider.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

class ProductDetailsPage extends StatefulWidget {
  Products? products;
  final Subscription subscription;
  late int availableItemCount;
  ProductDetailsPage(
      {super.key,
      this.products,
      required this.subscription,
      required this.availableItemCount});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  DateTime? selectedDate;
  late Products? products = widget.products;
  late Subscription subscription = widget.subscription;
  late int availableItemCount = widget.availableItemCount;
  final _nameController = TextEditingController();
  final _costpriceController = TextEditingController();
  final _sellingpriceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _bestbeforeController = TextEditingController();
  final numberformat = intl.NumberFormat("#####0.0#");
  final format = DateFormat("dd/MM/yyyy");
  String? nameErrorStr;
  String? costpriceErrorStr;
  String? sellingpriceErrorStr;
  String? qtyErrorStr;
  String? bestbeforeErrorStr;
  String? _selectedImageUrl;
  bool isLoading = false;
  bool isEditing = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365 * 2)));

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _bestbeforeController.text = format.format(selectedDate!);
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
                Navigator.of(context).pop(true);
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

  void _resetEditing() {
    _nameController.text = (products == null ? "" : products!.getDesc);
    _costpriceController.text =
        (products == null) ? "" : numberformat.format(products!.getCostPrice);
    _sellingpriceController.text = (products == null)
        ? ""
        : numberformat.format(products!.getSellingPrice);
    _qtyController.text = (products == null) ? "" : products!.getQty.toString();
    _bestbeforeController.text = (products == null)
        ? ""
        : format.format(DateTime.parse(products!.bestBefore));

    setState(() {
      isEditing = false;
    });
  }

  void createProduct() {
    if (!isEditing) {
      return;
    }

    String name = _nameController.text.trim();
    double? costprice = double.tryParse(_costpriceController.text.trim());
    double? sellingprice = double.tryParse(_sellingpriceController.text.trim());
    int? qty = int.tryParse(_qtyController.text.trim());
    String date = _bestbeforeController.text.trim();

    setState(() {
      isLoading = true;
    });

    if (name.isEmpty) {
      setState(() {
        nameErrorStr = "Invalid Name";
      });
    } else {
      setState(() {
        nameErrorStr = null;
      });
    }

    if (costprice == null || costprice <= 0) {
      setState(() {
        costpriceErrorStr = "Invalid Price";
      });
    } else {
      setState(() {
        costpriceErrorStr = null;
      });
    }

    if (sellingprice == null || sellingprice <= 0) {
      setState(() {
        sellingpriceErrorStr = "Invalid Price";
      });
    } else {
      setState(() {
        sellingpriceErrorStr = null;
      });
    }

    if (qty == null || qty <= 0 || qty > availableItemCount) {
      setState(() {
        qtyErrorStr = "Invalid Qty, $availableItemCount item space left.";
      });
    } else {
      setState(() {
        qtyErrorStr = null;
      });
    }

    if (date.isEmpty) {
      setState(() {
        bestbeforeErrorStr = "Invalid Date";
      });
    } else {
      setState(() {
        bestbeforeErrorStr = null;
      });
    }

    if (nameErrorStr == null &&
        costpriceErrorStr == null &&
        sellingpriceErrorStr == null &&
        qtyErrorStr == null &&
        bestbeforeErrorStr == null) {
      final provider = Provider.of<UserProvider>(context, listen: false);
      Sellers currentSeller = provider.getCurrentUser as Sellers;

      Products tempProd = Products(
          id: null,
          desc: name,
          sellingPrice: sellingprice!,
          costPrice: costprice!,
          qty: qty!,
          subId: subscription.getId!,
          bestBefore: selectedDate!.toIso8601String(),
          imageUrl: _selectedImageUrl,
          sellerId: currentSeller.getId!);
      CloudDatabase db = CloudDatabase();
      subscription.getProducts.add(tempProd);
      db.save(CloudDatabase.seller, currentSeller.toJson(),
          docId: currentSeller.getId);
      provider.saveUserToLocalStorage();
      provider.refreshNotificationforSeller();

      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Product Created.");
      Navigator.of(context).pop(true);
    }

    setState(() {
      isLoading = false;
    });
  }

  void updateProduct() {
    if (!isEditing) {
      return;
    }

    String name = _nameController.text.trim();
    double? costprice = double.tryParse(_costpriceController.text.trim());
    double? sellingprice = double.tryParse(_sellingpriceController.text.trim());
    int? qty = int.tryParse(_qtyController.text.trim());
    String date = _bestbeforeController.text.trim();

    setState(() {
      isLoading = true;
    });

    if (name.isEmpty) {
      setState(() {
        nameErrorStr = "Invalid Name";
      });
    } else {
      setState(() {
        nameErrorStr = null;
      });
    }

    if (costprice == null || costprice <= 0) {
      setState(() {
        costpriceErrorStr = "Invalid Price";
      });
    } else {
      setState(() {
        costpriceErrorStr = null;
      });
    }

    if (sellingprice == null || sellingprice <= 0) {
      setState(() {
        sellingpriceErrorStr = "Invalid Price";
      });
    } else {
      setState(() {
        sellingpriceErrorStr = null;
      });
    }

    if (qty == null ||
        qty <= 0 ||
        qty > (availableItemCount + products!.getQty)) {
      setState(() {
        qtyErrorStr =
            "Invalid Qty, ${(availableItemCount + products!.getQty)} item space left.";
      });
    } else {
      setState(() {
        qtyErrorStr = null;
      });
    }

    if (date.isEmpty) {
      setState(() {
        bestbeforeErrorStr = "Invalid Date";
      });
    } else {
      setState(() {
        bestbeforeErrorStr = null;
      });
    }

    if (nameErrorStr == null &&
        costpriceErrorStr == null &&
        sellingpriceErrorStr == null &&
        qtyErrorStr == null &&
        bestbeforeErrorStr == null) {
      final provider = Provider.of<UserProvider>(context, listen: false);
      Sellers currentSeller = provider.getCurrentUser as Sellers;

      products!.setBestBefore = selectedDate!.toIso8601String();
      products!.setDesc = name;
      products!.setSellingPrice = sellingprice!;
      products!.setCostPrice = costprice!;
      products!.setQty = qty!;
      products!.setImageUrl = _selectedImageUrl ?? products!.getImageUrl;

      CloudDatabase db = CloudDatabase();
      db.save(CloudDatabase.seller, currentSeller.toJson(),
          docId: currentSeller.getId);

      provider.saveUserToLocalStorage();
      provider.refreshNotificationforSeller();

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Product Updated.");
      Navigator.of(context).pop(true);
    }

    setState(() {
      isLoading = false;
    });
  }

  void deleteProduct() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    Sellers currentSeller = provider.getCurrentUser as Sellers;

    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmDelete == true) {
      subscription.getProducts.remove(products);
      CloudDatabase db = CloudDatabase();
      db.save(CloudDatabase.seller, currentSeller.toJson(),
          docId: currentSeller.getId);

      provider.saveUserToLocalStorage();
      Fluttertoast.showToast(msg: "Product Removed.");
      Navigator.of(context).pop(true);
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = (products == null ? "" : products!.getDesc);
    _costpriceController.text =
        (products == null ? "" : numberformat.format(products!.getCostPrice));
    _sellingpriceController.text = (products == null
        ? ""
        : numberformat.format(products!.getSellingPrice));
    _qtyController.text = (products == null ? "" : products!.getQty.toString());
    _bestbeforeController.text = (products == null
        ? ""
        : format.format(DateTime.parse(products!.getBestBefore)));
    if (DateTime.parse(products!.getBestBefore).isBefore(DateTime.now())) {
      bestbeforeErrorStr =
          "The product has expired and will not shown to the user.";
    }
    selectedDate = (products == null
        ? null
        : (DateTime.parse(products!.getBestBefore).isAfter(DateTime.now()))
            ? DateTime.parse(products!.getBestBefore)
            : null);
    isEditing = products == null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costpriceController.dispose();
    _sellingpriceController.dispose();
    _qtyController.dispose();
    _bestbeforeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: products == null
            ? const Text("Create Product")
            : const Text("Product Details"),
        actions: [
          IconButton(
              onPressed: deleteProduct,
              icon: Icon(
                Icons.remove_circle_outline,
                size: 28,
                color: Theme.of(context).colorScheme.error,
              )),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<ConnectivityProvider>(
                builder: (context, connectivity, child) {
                  return Container(
                    width: 150,
                    height: 150,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).cardColor,
                      border: Border.all(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Builder(
                        builder: (context) {
                          Widget networkImage(String url) {
                            return Image.network(
                              url,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            );
                          }

                          Widget getImage() {
                            if (!connectivity.isConnected) {
                              return Image.asset("assets/logo/logo_filled.png");
                            }

                            if (products == null) {
                              if (isEditing) {
                                return _selectedImageUrl == null
                                    ? Image.asset("assets/logo/logo_filled.png")
                                    : networkImage(_selectedImageUrl!);
                              } else {
                                return Image.asset(
                                    "assets/logo/logo_filled.png");
                              }
                            } else {
                              if (isEditing) {
                                return _selectedImageUrl == null
                                    ? (products!.imageUrl == null
                                        ? Image.asset(
                                            "assets/logo/logo_filled.png")
                                        : networkImage(products!.imageUrl!))
                                    : networkImage(_selectedImageUrl!);
                              } else {
                                return products!.imageUrl == null
                                    ? Image.asset("assets/logo/logo_filled.png")
                                    : networkImage(products!.imageUrl!);
                              }
                            }
                          }

                          return getImage();
                        },
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: isEditing ? _pickImageFromUrl : null,
                icon: Icon(isEditing
                    ? Icons.link
                    : Icons.disabled_by_default_outlined),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _nameController,
                enabled: isEditing,
                decoration: InputDecoration(
                  labelText: "Name",
                  errorText: nameErrorStr,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _costpriceController,
                enabled: isEditing,
                decoration: InputDecoration(
                  labelText: "Cost Price (RM)",
                  errorText: costpriceErrorStr,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _sellingpriceController,
                enabled: isEditing,
                decoration: InputDecoration(
                    labelText: "Selling Price (RM)",
                    errorText: sellingpriceErrorStr),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _qtyController,
                enabled: isEditing,
                decoration: InputDecoration(
                  labelText: "Qty",
                  errorText: qtyErrorStr,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                readOnly: true,
                controller: _bestbeforeController,
                enabled: isEditing,
                decoration: InputDecoration(
                  labelText: "Best Before",
                  errorText: bestbeforeErrorStr,
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
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  isLoading
                      ? LoadingAnimationWidget.staggeredDotsWave(
                          color: Theme.of(context).primaryColor, size: 20)
                      : Consumer<ConnectivityProvider>(
                          builder: (context, connectivity, child) {
                            return ElevatedButton(
                              onPressed: connectivity.isConnected
                                  ? (products == null
                                      ? createProduct
                                      : updateProduct)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 32),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 5,
                              ),
                              child: products == null
                                  ? const Text("Create")
                                  : const Text("Update"),
                            );
                          },
                        ),
                  Consumer<ConnectivityProvider>(
                      builder: (context, connectivity, child) {
                    return ElevatedButton(
                      onPressed: connectivity.isConnected
                          ? () {
                              setState(() {
                                isEditing = true;
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 32),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: const Text("Edit"),
                    );
                  }),
                  ElevatedButton(
                    onPressed: () {
                      _resetEditing();
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
      )),
    );
  }
}
