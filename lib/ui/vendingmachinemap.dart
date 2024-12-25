import 'package:assignment/datamodel/sellers.dart';
import 'package:assignment/datamodel/vendingmachine.dart';
import 'package:assignment/services/clouddatabase.dart';
import 'package:assignment/services/connnectivity.dart';
import 'package:assignment/services/usercartdataprovider.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:assignment/services/vendingmachineprovider.dart';
import 'package:assignment/ui/seller/sellersubscribepage.dart';
import 'package:assignment/ui/user/userpurchasingpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class VendingMachineMap extends StatefulWidget {
  const VendingMachineMap({super.key});

  @override
  State<VendingMachineMap> createState() => _VendingMachineMapState();
}

class _VendingMachineMapState extends State<VendingMachineMap> {
  final MyConnectivityChecker _connectivityChecker = MyConnectivityChecker();
  final MapController _mapController = MapController();
  final CloudDatabase db = CloudDatabase();
  List<VendingMachine> _vendingMachine = [];
  List<Marker> _userMarker = [];
  List<Marker> _vendingMachineMarkers = [];
  List<VendingMachine> _filteredVendingMachine = [];
  bool _isLoading = true;
  LatLng? selectedLatLng;

  void _filterVendingMachines(String query) {
    if (mounted) {
      if (query.isEmpty) {
        setState(() {
          _filteredVendingMachine = _vendingMachine;
        });
      } else {
        setState(() {
          _filteredVendingMachine = _vendingMachine
              .where((machine) =>
                  machine.getDesc.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      }
      _sortVendingMachinesByDistance();
    }
  }

  void _sortVendingMachinesByDistance() {
    if (selectedLatLng != null && mounted) {
      setState(() {
        _filteredVendingMachine.sort((a, b) {
          final distanceA = _calculateDistance(
            selectedLatLng!.latitude,
            selectedLatLng!.longitude,
            double.parse(a.getLat),
            double.parse(a.getLong),
          );
          final distanceB = _calculateDistance(
            selectedLatLng!.latitude,
            selectedLatLng!.longitude,
            double.parse(b.getLat),
            double.parse(b.getLong),
          );
          return distanceA.compareTo(distanceB);
        });

        _vendingMachine.sort((a, b) {
          final distanceA = _calculateDistance(
            selectedLatLng!.latitude,
            selectedLatLng!.longitude,
            double.parse(a.getLat),
            double.parse(a.getLong),
          );
          final distanceB = _calculateDistance(
            selectedLatLng!.latitude,
            selectedLatLng!.longitude,
            double.parse(b.getLat),
            double.parse(b.getLong),
          );
          return distanceA.compareTo(distanceB);
        });
      });
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const Distance distance = Distance();
    return distance.as(
        LengthUnit.Meter, LatLng(lat1, lon1), LatLng(lat2, lon2));
  }

  void _addUserMarker(LatLng position) {
    if (mounted) {
      setState(() {
        _userMarker.clear();
        _userMarker.add(
          Marker(
            alignment: Alignment.topCenter,
            width: 120.0,
            height: 70.0,
            point: position,
            child: Column(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      return Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "You are here.",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      });
    }
  }

  void _addVendingMachineMarker(VendingMachine vm) {
    if (mounted) {
      setState(() {
        _vendingMachineMarkers.add(
          Marker(
            width: 150.0,
            height: 100.0,
            alignment: Alignment.topCenter,
            point: LatLng(double.parse(vm.getLat), double.parse(vm.getLong)),
            child: Column(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        elevation: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  vm.getDesc,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Icon(
                  Icons.location_pin,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        );
      });
    }
  }

  Future<void> getUserPosition() async {
    Position? userPosition;
    if (_userMarker.isEmpty) {
      userPosition = await getPosition();
    } else {
      userPosition = await Geolocator.getLastKnownPosition();
      if (userPosition != null) {
        _mapController.move(
            LatLng(userPosition.latitude, userPosition.longitude), 16.0);
        Fluttertoast.showToast(msg: "Last Known Location Used.");
        return;
      }
    }

    if (userPosition == null) {
      Fluttertoast.showToast(msg: "Fail to locate the user.");
    } else {
      if (mounted) {
        setState(() {
          _addUserMarker(
              LatLng(userPosition!.latitude, userPosition.longitude));
          selectedLatLng =
              LatLng(userPosition.latitude, userPosition.longitude);
        });
        _sortVendingMachinesByDistance();
        Fluttertoast.showToast(msg: "User Location Fetched.");
      }
    }
  }

  Future<Position?> getPosition() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    bool internetConnection =
        await _connectivityChecker.checkConnectivityOnce();

    try {
      if (internetConnection) {
        final permission = await Geolocator.requestPermission();

        Position? newPosition;

        if (permission == LocationPermission.denied) {
          newPosition = await Geolocator.getLastKnownPosition();
          Fluttertoast.showToast(msg: "Last Known Location Used.");
        } else {
          try {
            newPosition = await Geolocator.getCurrentPosition().timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                Fluttertoast.showToast(msg: "Location request timed out.");
                // ignore: null_argument_to_non_null_type
                return Future.value(null);
              },
            );
          } catch (e) {
            Fluttertoast.showToast(msg: "Error fetching location: $e");
            newPosition = null;
          }
        }

        if (newPosition != null) {
          if (mounted) {
            _mapController.move(
                LatLng(newPosition.latitude, newPosition.longitude), 16.0);
            selectedLatLng =
                LatLng(newPosition.latitude, newPosition.longitude);
          }
        }

        return newPosition;
      }
      return null;
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching location: $e");
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> getVendingMachines() async {
    final provider =
        Provider.of<VendingMachineProvider>(context, listen: false);
    await provider.getVendingMachines();
    for (var x in provider.vendingMachines) {
      _addVendingMachineMarker(x);
    }
    if (mounted) {
      setState(() {
        _vendingMachine = provider.vendingMachines;
        _filteredVendingMachine = _vendingMachine;
      });
      _sortVendingMachinesByDistance();
      Fluttertoast.showToast(msg: "Vending Machines' data fetched.");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([
      getUserPosition(),
      getVendingMachines(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Vending Machines"),
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialZoom: 16.0,
                  interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
                ),
                children: [
                  TileLayer(
                    urlTemplate: (Theme.of(context).brightness ==
                            Brightness.dark)
                        ? "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png"
                        : "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
                  ),
                  MarkerLayer(
                    markers: _userMarker,
                  ),
                  MarkerLayer(
                    markers: _vendingMachineMarkers,
                  ),
                ],
              ),
              Positioned(
                  top: 10,
                  left: 5,
                  right: 5,
                  child: SearchBar(
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onChanged: (String query) {
                      _filterVendingMachines(query);
                    },
                    hintText: "Search...",
                    leading: Icon(
                      Icons.search,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.grey,
                    ),
                    trailing: [
                      IconButton(
                          onPressed: getUserPosition,
                          icon: Icon(
                            Icons.location_searching,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.grey,
                          ))
                    ],
                  )),
              Positioned(
                bottom: -10,
                left: 0,
                right: 0,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3,
                      color: Colors.transparent,
                      child: Card(
                          elevation: 15,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                            child: Scrollbar(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: ListView(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        "Results",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 16),
                                      child: Text(
                                        "We found ${_filteredVendingMachine.length} vending machines for you.",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (_filteredVendingMachine.isEmpty)
                                      SizedBox(
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: Image.asset(
                                                    "assets/logo/logo_cry_filled.png",
                                                    height: 80,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                const Center(
                                                    child: Text("No result..")),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      ...List.generate(
                                          _filteredVendingMachine.length,
                                          (idx) {
                                        return SizedBox(
                                          child: Card(
                                            elevation: 10,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    flex: 1,
                                                    child: Center(
                                                      child: Image.network(
                                                        _filteredVendingMachine[
                                                                idx]
                                                            .getImageUrl!,
                                                        height: 80,
                                                        width: 100,
                                                        fit: BoxFit.contain,
                                                        loadingBuilder:
                                                            (BuildContext
                                                                    context,
                                                                Widget child,
                                                                ImageChunkEvent?
                                                                    loadingProgress) {
                                                          if (loadingProgress ==
                                                              null) {
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
                                                                        (loadingProgress.expectedTotalBytes ??
                                                                            1)
                                                                    : null,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Flexible(
                                                    flex: 1,
                                                    child: Center(
                                                      child: SizedBox(
                                                        width: 120,
                                                        child: Text(
                                                          _filteredVendingMachine[
                                                                  idx]
                                                              .getDesc,
                                                          textAlign:
                                                              TextAlign.start,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 3,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    flex: 1,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        final provider = Provider
                                                            .of<UserProvider>(
                                                                context,
                                                                listen: false);
                                                        if (provider
                                                                .getCurrentUser
                                                            is Sellers) {
                                                          Navigator.push(
                                                            context,
                                                            PageRouteBuilder(
                                                              pageBuilder: (context,
                                                                      animation,
                                                                      secondaryAnimation) =>
                                                                  SellersSubscribePage(
                                                                vendingMachine:
                                                                    _filteredVendingMachine[
                                                                        idx],
                                                              ),
                                                              transitionsBuilder:
                                                                  (context,
                                                                      animation,
                                                                      secondaryAnimation,
                                                                      child) {
                                                                const begin =
                                                                    Offset(1.0,
                                                                        0.0);
                                                                const end =
                                                                    Offset.zero;
                                                                const curve =
                                                                    Curves.ease;

                                                                var tween = Tween(
                                                                        begin:
                                                                            begin,
                                                                        end:
                                                                            end)
                                                                    .chain(CurveTween(
                                                                        curve:
                                                                            curve));

                                                                return SlideTransition(
                                                                  position: animation
                                                                      .drive(
                                                                          tween),
                                                                  child: child,
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        } else {
                                                          Navigator.push(
                                                            context,
                                                            PageRouteBuilder(
                                                              pageBuilder: (context,
                                                                  animation,
                                                                  secondaryAnimation) {
                                                                return const UserPurchasingPage();
                                                              },
                                                              transitionsBuilder:
                                                                  (context,
                                                                      animation,
                                                                      secondaryAnimation,
                                                                      child) {
                                                                const begin =
                                                                    Offset(1.0,
                                                                        0.0);
                                                                const end =
                                                                    Offset.zero;
                                                                const curve =
                                                                    Curves.ease;

                                                                var tween = Tween(
                                                                        begin:
                                                                            begin,
                                                                        end:
                                                                            end)
                                                                    .chain(CurveTween(
                                                                        curve:
                                                                            curve));

                                                                return SlideTransition(
                                                                  position: animation
                                                                      .drive(
                                                                          tween),
                                                                  child: child,
                                                                );
                                                              },
                                                            ),
                                                          );

                                                          WidgetsBinding
                                                              .instance
                                                              .addPostFrameCallback(
                                                                  (_) {
                                                            final provider =
                                                                Provider.of<
                                                                        UserCartDataProvider>(
                                                                    context,
                                                                    listen:
                                                                        false);
                                                            provider.cart = {};
                                                            provider.selectedVendingMachine =
                                                                _filteredVendingMachine[
                                                                    idx];
                                                          });
                                                        }
                                                      },
                                                      child:
                                                          const Text("Select"),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                          )),
                    )),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: LoadingAnimationWidget.progressiveDots(
                        color: Theme.of(context).primaryColor, size: 70),
                  ),
                ),
            ],
          )),
    );
  }
}
