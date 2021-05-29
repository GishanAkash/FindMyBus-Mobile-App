

import 'package:findmybusfinal/datamodels/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String serverKey = 'AAAAsj83lHM:APA91bHoYSnBEVevhqvm8Tz5Qhaar6adiKfCRguA8KdigKcdZ03rMJQy2mqJcov-0ERGdQiy76drBEY3mHoT8UaUbwCJPRoq9rFHufde3LMJd-_ExHuH8hJsn0UIzhdZ1CIdxVQWHcgI';

String mapKey = 'AIzaSyBE0vS53S0m3-f6hFoZsbmUJCjAaO9P-HU';

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

FirebaseUser currentFirebaseUser;

User currentUserInfo;