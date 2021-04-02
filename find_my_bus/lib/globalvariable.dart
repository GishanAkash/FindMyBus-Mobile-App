
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'datamodels/user.dart';

String mapKey = 'AIzaSyDaMvby39xOdtrwHBLpsbBRx4_-QvpykzM';

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

FirebaseUser currentFirebaseUser;

User currentUserInfo;