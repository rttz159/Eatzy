import 'package:assignment/services/appcyclehandler.dart';
import 'package:assignment/services/connectivityprovider.dart';
import 'package:assignment/services/usercartdataprovider.dart';
import 'package:assignment/services/userprovider.dart';
import 'package:assignment/services/vendingmachineprovider.dart';
import 'package:assignment/ui/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final lifecycleHandler = AppLifecycleHandler();
  WidgetsBinding.instance.addObserver(lifecycleHandler);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(
        create: (_) => ConnectivityProvider(),
      ),
      ChangeNotifierProvider(create: (_) => VendingMachineProvider()),
      ChangeNotifierProvider(create: (_) => UserCartDataProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eatzy',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const Dashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
