import 'dart:async';
import 'package:findmybusdriver/Widgets/AvailabilityButton.dart';
import 'package:findmybusdriver/Widgets/ConfirmSheet.dart';
import 'package:findmybusdriver/datamodels/driver.dart';
import 'package:findmybusdriver/global%20variables.dart';
import 'package:findmybusdriver/helpers/HelperMethods.dart';
import 'package:findmybusdriver/helpers/pushNotificationService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget {

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();



  var geoLocator = Geolocator();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);

  DatabaseReference tripRequestRef;

  String availabilityTitle = 'GO ONLINE';
  Color availabilityColor = Colors.amber;

  bool isAvailable = false;

  void getCurrentPosition() async {

    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    mapController.animateCamera(CameraUpdate.newLatLng(pos));

  }

  void getCurrentDriverInfo () async {
    currentFirebaseUser = await FirebaseAuth.instance.currentUser();

    DatabaseReference driverRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}');
    driverRef.once().then((DataSnapshot snapshot){

      if(snapshot.value != null){
        currentDriverInfo = Driver.fromSnapshot(snapshot);
        print(currentDriverInfo.fullName);
      }

    });

    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initialize();
    pushNotificationService.getToken();

    HelperMethods.getHistoryInfo(context);
     }

    @override
    void initState() {
      // TODO: implement initState
      super.initState();
      getCurrentDriverInfo();
    }


    @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          padding: EdgeInsets.only(top: 135),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
            mapController = controller;

            getCurrentPosition();
          },
        ),

        Container(
          height: 120,
          width: double.infinity,
          color: Colors.black38,
        ),

        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AvailabilityButton(
                title: availabilityTitle,
                color: availabilityColor,
                onPressed: (){


                  showModalBottomSheet(
                    isDismissible: false,
                    context: context,
                    builder: (BuildContext context) => ConfirmSheet(
                      title: (!isAvailable) ? 'GO ONLINE' : 'GO OFFLINE',
                      subtitle: (!isAvailable) ? 'You are about to start a new trip': 'End trip ?',

                      onPressed: (){

                        if(!isAvailable){
                          goOnline();
                          getLocationUpdates();
                          Navigator.pop(context);

                          setState(() {
                            availabilityColor = Colors.black54;
                            availabilityTitle = 'GO OFFLINE';
                            isAvailable = true;
                          });

                        }
                        else{

                          goOffline();
                          Navigator.pop(context);
                          setState(() {
                            availabilityColor = Colors.amber;
                            availabilityTitle = 'GO ONLINE';
                            isAvailable = false;
                          });
                        }

                      },
                    ),
                  );

                },
              ),
            ],
          ),
        )
      ],
    );
  }

  void goOnline(){
    Geofire.initialize('driversAvailable');
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);

    tripRequestRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/newtrip');
    tripRequestRef.set('waiting');

    tripRequestRef.onValue.listen((event) {

    });
  }

  void goOffline (){

    Geofire.removeLocation(currentFirebaseUser.uid);
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
    tripRequestRef = null;

  }

  void getLocationUpdates(){


    homeTabPositionStream = geoLocator.getPositionStream(locationOptions).listen((Position position) {
      currentPosition = position;

      if(isAvailable){
        Geofire.setLocation(currentFirebaseUser.uid, position.latitude, position.longitude);
      }

      LatLng pos = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(pos));

    });

  }

}

