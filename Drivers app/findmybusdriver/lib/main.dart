import 'package:findmybusdriver/Screens/VehicleInfo.dart';
import 'package:findmybusdriver/Screens/driverLoginpage.dart';
import 'package:findmybusdriver/Screens/mainpage.dart';
import 'package:findmybusdriver/Screens/registrationpage.dart';
import 'package:findmybusdriver/dataprovider.dart';
import 'package:findmybusdriver/global%20variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: '1:297855924061:ios:c6de2b69b03a5be8',
      gcmSenderID: '297855924061',
      databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
    )
        : const FirebaseOptions(
      googleAppID: '1:765564785779:android:f2a3bafd0d9ea964ab0606',
      apiKey: 'AIzaSyBE0vS53S0m3-f6hFoZsbmUJCjAaO9P-HU',
      databaseURL: 'https://myapp-e76fc-default-rtdb.firebaseio.com',
    ),
  );

  currentFirebaseUser = await FirebaseAuth.instance.currentUser();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: 'myFont-Regular',
          primarySwatch: Colors.amber,
        ),
        initialRoute: (currentFirebaseUser == null) ? LoginPage.id : MainPage.id,
        routes: {
          MainPage.id: (context) => MainPage(),
          RegistrationPage.id: (context) => RegistrationPage(),
          VehicleInfoPage.id: (context) => VehicleInfoPage(),
          LoginPage.id: (context) => LoginPage(),
        },
      ),
    );
  }
}
