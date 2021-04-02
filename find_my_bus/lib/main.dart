import 'package:find_my_bus/Screen/loginpage.dart';
import 'package:find_my_bus/Screen/mainpage.dart';
import 'package:find_my_bus/Screen/registrationpage.dart';
import 'package:find_my_bus/dataprovider/appdata.dart';
import 'package:find_my_bus/globalvariable.dart';
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
      googleAppID: '1:169450788828:ios:94b60468db3510b6f9a119',
      gcmSenderID: '169450788828',
      databaseURL: 'https://findmybus-e845a-default-rtdb.firebaseio.com',
    )
        : const FirebaseOptions(
      googleAppID: '1:126489092552:android:88ba7c01b64a20ff6920fd',
      apiKey: 'AIzaSyDaMvby39xOdtrwHBLpsbBRx4_-QvpykzM',
      databaseURL: 'https://findmybus-e845a-default-rtdb.firebaseio.com',
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
        theme: ThemeData(
          fontFamily: 'Brand-Regular',
          primarySwatch: Colors.blue,
        ),
        initialRoute: (currentFirebaseUser == null) ? LoginPage.id : MainPage.id,
        routes: {
          RegistrationPage.id: (context) => RegistrationPage(),
          LoginPage.id: (context) => LoginPage(),
          MainPage.id: (context) => MainPage(),
        },
      ),
    );
  }
}
