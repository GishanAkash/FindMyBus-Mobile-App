
import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:findmybusdriver/datamodels/driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String mapKey = 'AIzaSyBE0vS53S0m3-f6hFoZsbmUJCjAaO9P-HU';

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);


FirebaseUser currentFirebaseUser;

StreamSubscription <Position> homeTabPositionStream;

StreamSubscription<Position> ridePositionStream;

final assetAudioPlayer = AssetsAudioPlayer();

Position currentPosition;

DatabaseReference rideRef;

Driver currentDriverInfo;