import 'package:findmybusfinal/Widgets/CollectPayment.dart';
import 'package:findmybusfinal/Widgets/NoDriverDialog.dart';
import 'package:findmybusfinal/Widgets/brandDivider.dart';
import 'package:findmybusfinal/Widgets/fmbButton.dart';
import 'package:findmybusfinal/Widgets/progressDialog.dart';
import 'package:findmybusfinal/busVariables.dart';
import 'package:findmybusfinal/datamodels/NearbyDriver.dart';
import 'package:findmybusfinal/datamodels/directionDetails.dart';
import 'package:findmybusfinal/dataproviders/appData.dart';
import 'package:findmybusfinal/globalVariables.dart';
import 'package:findmybusfinal/helpers/firehelper.dart';
import 'package:findmybusfinal/helpers/helpermethods.dart';
import 'package:findmybusfinal/screens/searchpage.dart';
import 'package:findmybusfinal/styles/styles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class MainPage extends StatefulWidget {

  static const String id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin{

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;
  double rideDetailsSheetHeight = 0;
  double requestingSheetHeight = 0;
  double tripSheetHeight = 0; // (Platform.isAndroid) ? 275 : 300

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottomPadding = 0;

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  BitmapDescriptor nearbyIcon;

  var geoLocator = Geolocator();
  Position currentPosition;
  DirectionDetails tripDirectionDetails;

  String appState = 'NORMAL';

  bool drawerCanOpen = true;

  DatabaseReference rideRef;

  StreamSubscription<Event> rideSubscription;

  List<NearbyDriver> availableDrivers;

  bool nearbyDriversKeysLoaded;

  bool isRequestingLocationDetails = false;

  void setupPositionLocator() async {
    Position position = await geoLocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 16);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

    await HelperMethods.findCordinateAddress(position, context);

    startGeofireListener();

  }

  void showDetailSheet () async {
    await getDirections();

    setState(() {
      searchSheetHeight = 0;
      mapBottomPadding = (Platform.isAndroid) ? 240 : 230;
      rideDetailsSheetHeight = (Platform.isAndroid) ? 235 : 260;
      drawerCanOpen = false;
    });
  }

  void showRequestingSheetHeight(){
    setState(() {
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = (Platform.isAndroid) ? 195 : 220;
      mapBottomPadding = (Platform.isAndroid) ? 200 : 190;

      drawerCanOpen = true;

    });
    createRideRequest();
  }

  showTripSheet(){

    setState(() {
      requestingSheetHeight = 0;
      tripSheetHeight = (Platform.isAndroid) ? 275 : 300;
      mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
    });
  }

  void createMarker(){
    if(nearbyIcon == null){

      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(1,1));
      BitmapDescriptor.fromAssetImage(
          imageConfiguration, (Platform.isIOS)
          ? 'images/bus_ios.png'
          : 'images/busicon.png'
      ).then((icon){
        nearbyIcon = icon;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    HelperMethods.getCurrentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        width: 250,
        color: Colors.white,
        child: Drawer(

          child: ListView(
            padding: EdgeInsets.all(0),
            children: <Widget>[

              Container(
                color: Colors.amber,
                height: 160,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                      color: Colors.amber
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset('images/User Icon.png', height: 60, width: 60,),
                      SizedBox(width: 15,),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Gishan', style: TextStyle(fontSize: 20, fontFamily: 'myFont-Bold'),),
                          SizedBox(height: 5,),
                          Text('View Profile'),
                        ],
                      )

                    ],
                  ),
                ),
              ),
              BrandDivider(),

              SizedBox(height: 10,),

              ListTile(
                leading: Icon(OMIcons.directionsBus),
                title: Text('Bus Routes', style: kDrawerItemStyle,),
              ),

              ListTile(
                leading: Icon(OMIcons.creditCard),
                title: Text('Ticket Prices', style: kDrawerItemStyle,),
              ),

              ListTile(
                leading: Icon(OMIcons.history),
                title: Text('Travel History', style: kDrawerItemStyle,),
              ),

              ListTile(
                leading: Icon(OMIcons.contactSupport),
                title: Text('Support', style: kDrawerItemStyle,),
              ),

              ListTile(
                leading: Icon(OMIcons.info),
                title: Text('About', style: kDrawerItemStyle,),
              ),

            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            padding: EdgeInsets.only(bottom:mapBottomPadding),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: googlePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: _polylines,
            markers: _markers,
            circles: _circles,
            onMapCreated: (GoogleMapController controller){
              _controller.complete(controller);
              mapController = controller;

              setState(() {
                mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
              });

              setupPositionLocator();

            },

          ),

          ///RoundMenuButton
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: (){
                if(drawerCanOpen)
                  {
                    scaffoldKey.currentState.openDrawer();
                  }
                else
                  {
                    resetApp();
                  }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      )
                    )
                  ]
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.amber,
                  radius: 25,
                  child: Icon((drawerCanOpen) ? Icons.menu : Icons.arrow_back, color: Colors.white,),
                ),
              ),
            ),
          ),

          ///searchArea
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: searchSheetHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7,
                            0.7,
                          )
                      )
                    ]
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 5,),
                      Text('Welcome to FindMyBus!', style: TextStyle(fontSize: 10),),
                      Text('Where are you going?', style: TextStyle(fontSize: 18, fontFamily: 'myFont-Bold'),),

                      SizedBox(height: 20,),

                      GestureDetector(
                        onTap: () async {

                          var response = await Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchPage()));
                          if(response == 'getDirection'){
                            showDetailSheet();
                          }

                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5.0,
                                    spreadRadius: 0.5,
                                    offset: Offset(
                                      0.7,
                                      0.7,
                                    )
                                )
                              ]
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.search, color: Colors.amberAccent,),
                                SizedBox(width: 10,),
                                Text('Search Destination'),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 22,),

                      Row(
                        children: <Widget>[
                          Icon(OMIcons.home, color: Colors.amber,),
                          SizedBox(width: 12,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Add Home'),
                              SizedBox(height: 3,),
                              Text('Your residential address',
                                style: TextStyle(fontSize: 11, color: Colors.black45,),
                              )
                            ],
                          )
                        ],
                      ),

                      SizedBox(height: 10,),

                      BrandDivider(),

                      SizedBox(height: 16,),

                      Row(
                        children: <Widget>[
                          Icon(OMIcons.workOutline, color: Colors.amber,),
                          SizedBox(width: 12,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Add Work'),
                              SizedBox(height: 3,),
                              Text('Your work address',
                                style: TextStyle(fontSize: 11, color: Colors.black45,),
                              )
                            ],
                          )
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),

          ///busDetails
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      )
                    )
                  ]
                ),
                height: rideDetailsSheetHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        color: Colors.amber,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: <Widget>[
                              Image.asset('images/Bus.png', height: 70, width: 70,),
                              SizedBox(width: 16,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Bus', style: TextStyle(fontSize: 18, fontFamily: 'myFont-Bold'),),
                                  Text('Distance - '+((tripDirectionDetails != null) ? tripDirectionDetails.distanceText : ''), style: TextStyle(fontSize: 15, color: Colors.black45),)
                                ]
                              ),
                              Expanded(child: Container()),
                              Text((tripDirectionDetails != null) ? '\ Rs.${HelperMethods.estimateFares(tripDirectionDetails)}.00' : '', style: TextStyle(fontSize: 18, fontFamily: 'myFont-Bold'),)
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 22,),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(

                          children: <Widget>[
                            Icon(FontAwesomeIcons.moneyBillAlt, size: 18, color: Colors.black45,),
                            SizedBox(width: 16,),
                            Text('Cash'),
                            SizedBox(width: 5,),
                            Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black45,),
                          ],

                        ),
                      ),

                      SizedBox(height: 22,),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: fmbButton(
                          title: 'FIND NEARBY BUSES',
                          color: Colors.amber,
                          onPressed: (){

                            setState(() {
                              appState = 'REQUESTING';
                            });

                            showRequestingSheetHeight();

                            availableDrivers = FireHelper.nearbyDriverList;

                            findDriver();
                          },
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
          ),

          ///findNearbyBuses
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                  boxShadow: [BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    )
                  )]
                ),
                height: requestingSheetHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 10,),

                      SizedBox(
                        width: double.infinity,
                        child: TextLiquidFill(
                          text: 'Finding Nearby Buses...',
                          waveColor: Colors.black45,
                          boxBackgroundColor: Colors.white,
                          textStyle: TextStyle(
                              color: Colors.amber,
                              fontSize: 22.0,
                              fontFamily: 'myFont-Bold'
                          ),
                          boxHeight: 40.0,
                        ),
                      ),

                      SizedBox(height: 20,),

                      GestureDetector(
                        onTap: (){
                          cancelRequest();
                          resetApp();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(width: 1.0, color: Colors.black38),

                          ),
                          child: Icon(Icons.close, size: 25,),
                        ),
                      ),

                      SizedBox(height: 10,),

                      Container(
                        width: double.infinity,
                        child: Text(
                          'Cancel Search',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Trip Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0, // soften the shadow
                      spreadRadius: 0.5, //extend the shadow
                      offset: Offset(
                        0.7, // Move to right 10  horizontally
                        0.7, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                ),
                height: tripSheetHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      SizedBox(height: 5,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(tripStatusDisplay,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
                          ),
                        ],
                      ),

                      SizedBox(height: 20,),

                      BrandDivider(),

                      SizedBox(height: 20,),

                      Text(driverCarDetails, style: TextStyle(color: Colors.black26),),

                      Text(driverFullName, style: TextStyle(fontSize: 20),),

                      SizedBox(height: 20,),

                      BrandDivider(),

                      SizedBox(height: 20,),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular((25))),
                                  border: Border.all(width: 1.0, color: Colors.black26),
                                ),
                                child: Icon(Icons.call),
                              ),

                              SizedBox(height: 10,),

                              Text('Call'),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular((25))),
                                  border: Border.all(width: 1.0, color: Colors.black26),
                                ),
                                child: Icon(Icons.list),
                              ),

                              SizedBox(height: 10,),

                              Text('Details'),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular((25))),
                                  border: Border.all(width: 1.0, color: Colors.black26),
                                ),
                                child: Icon(OMIcons.clear),
                              ),

                              SizedBox(height: 10,),

                              Text('Cancel'),
                            ],
                          ),

                        ],
                      )

                    ],
                  ),
                ),
              ),
            ),
          )


        ],
      ),
    );
  }

  Future<void> getDirections() async{

    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);
    
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(status: 'Please wait...',)
    );

    var thisDetails = await HelperMethods.getDirectionDetails(pickLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodedPoints);

    polylineCoordinates.clear();
    if(results.isNotEmpty){
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    _polylines.clear();

    setState(() {

      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 59, 54, 54),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyline);

    });

    // fitting polylines into the map

    LatLngBounds bounds;

    if(pickLatLng.latitude > destinationLatLng.latitude && pickLatLng.longitude > destinationLatLng.longitude){
      bounds = LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
    }
    else if(pickLatLng.longitude > destinationLatLng.longitude){
      bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickLatLng.longitude)
      );
    }
    else if(pickLatLng.latitude > destinationLatLng.latitude){
      bounds = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
        northeast: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else{
      bounds = LatLngBounds(southwest: pickLatLng, northeast: destinationLatLng);
    }

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My Location'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: destination.placeName, snippet: 'Destination'),
    );

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.amber,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: Colors.amberAccent,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: Colors.amberAccent,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: Colors.black45,
    );



    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });

  }


  void startGeofireListener() {

    Geofire.initialize('driversAvailable');
    Geofire.queryAtLocation(currentPosition.latitude, currentPosition.longitude, 20).listen((map) {

      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:

            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];
            FireHelper.nearbyDriverList.add(nearbyDriver);

            if(nearbyDriversKeysLoaded){
              updateDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromList(map['key']);
            updateDriversOnMap();
            break;

          case Geofire.onKeyMoved:
          // Update your key's location

            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];

            FireHelper.updateNearbyLocation(nearbyDriver);
            updateDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:

            nearbyDriversKeysLoaded = true;
            updateDriversOnMap();
            break;
        }
      }
    });
  }

  void updateDriversOnMap(){
    setState(() {
      _markers.clear();
    });

    Set<Marker> tempMarkers = Set<Marker>();

    for (NearbyDriver driver in FireHelper.nearbyDriverList){

      LatLng driverPosition = LatLng(driver.latitude, driver.longitude);
      Marker thisMarker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverPosition,
        icon: nearbyIcon,
        rotation: HelperMethods.generateRandomNumber(360),
      );

      tempMarkers.add(thisMarker);
    }

    setState(() {
      _markers = tempMarkers;
    });

  }

  void createRideRequest(){

    rideRef = FirebaseDatabase.instance.reference().child('rideRequest').push();

    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context, listen: false).destinationAddress;

    Map pickupMap = {
      'latitude': pickup.latitude.toString(),
      'longitude': pickup.longitude.toString(),
    };

    Map destinationMap = {
      'latitude': destination.latitude.toString(),
      'longitude': destination.longitude.toString(),
    };

    Map rideMap = {
      'created_at': DateTime.now().toString(),
      'rider_name': currentUserInfo.fullName,
      'rider_phone': currentUserInfo.phone,
      'pickup_address' : pickup.placeName,
      'destination_address': destination.placeName,
      'location': pickupMap,
      'destination': destinationMap,
      'payment_method': 'card',
      'driver_id': 'waiting',
    };

    rideRef.set(rideMap);
    rideSubscription = rideRef.onValue.listen((event) async {

      //check for null snapshot
      if(event.snapshot.value == null){
        return;
      }

      //get car details
      if(event.snapshot.value['car_details'] != null){
        setState(() {
          driverCarDetails = event.snapshot.value['car_details'].toString();
        });
      }

      // get driver name
      if(event.snapshot.value['driver_name'] != null){
        setState(() {
          driverFullName = event.snapshot.value['driver_name'].toString();
        });
      }

      // get driver phone number
      if(event.snapshot.value['driver_phone'] != null){
        setState(() {
          driverPhoneNumber = event.snapshot.value['driver_phone'].toString();
        });
      }


      //get and use driver location updates
      if(event.snapshot.value['driver_location'] != null){

        double driverLat = double.parse(event.snapshot.value['driver_location']['latitude'].toString());
        double driverLng = double.parse(event.snapshot.value['driver_location']['longitude'].toString());
        LatLng driverLocation = LatLng(driverLat, driverLng);

        if(status == 'accepted'){
          updateToPickup(driverLocation);
        }
        else if(status == 'ontrip'){
          updateToDestination(driverLocation);
        }
        else if(status == 'arrived'){
          setState(() {
            tripStatusDisplay = 'Driver has arrived';
          });
        }

      }


      if(event.snapshot.value['status'] != null){
        status = event.snapshot.value['status'].toString();
      }

      if(status == 'accepted'){
        showTripSheet();
        Geofire.stopListener();
        removeGeofireMarkers();
      }

      if(status == 'ended'){

        if(event.snapshot.value['fares'] != null) {

          int fares = int.parse(event.snapshot.value['fares'].toString());

          var response = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => CollectPayment(paymentMethod: 'cash', fares: fares,),
          );

          if(response == 'close'){
            rideRef.onDisconnect();
            rideRef = null;
            rideSubscription.cancel();
            rideSubscription = null;
            resetApp();
          }

        }
      }

    });



    }



void removeGeofireMarkers(){
  setState(() {
    _markers.removeWhere((m) => m.markerId.value.contains('driver'));
  });
}

void updateToPickup(LatLng driverLocation) async {

  if(!isRequestingLocationDetails){

    isRequestingLocationDetails = true;

    var positionLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);

    var thisDetails = await HelperMethods.getDirectionDetails(driverLocation, positionLatLng);

    if(thisDetails == null){
      return;
    }

    setState(() {
      tripStatusDisplay = 'Bus is Arriving - ${thisDetails.durationText}';
    });

    isRequestingLocationDetails = false;

  }


}

void updateToDestination(LatLng driverLocation) async {

  if(!isRequestingLocationDetails){

    isRequestingLocationDetails = true;

    var destination = Provider.of<AppData>(context, listen: false).destinationAddress;

    var destinationLatLng = LatLng(destination.latitude, destination.longitude);

    var thisDetails = await HelperMethods.getDirectionDetails(driverLocation, destinationLatLng);

    if(thisDetails == null){
      return;
    }

    setState(() {
      tripStatusDisplay = 'On the way to Destination - ${thisDetails.durationText}';
    });

    isRequestingLocationDetails = false;

  }


}

  void cancelRequest(){
    rideRef.remove();
    setState(() {
      appState = 'NORMAL';
    });
  }

  void noDriverFound(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoDriverDialog()
    );
  }

  void findDriver (){

    if(availableDrivers.length == 0){
      cancelRequest();
      resetApp();
      noDriverFound();
      return;
    }

    var driver = availableDrivers[0];

    notifyDriver(driver);

    availableDrivers.removeAt(0);

    print(driver.key);

  }

  void notifyDriver(NearbyDriver driver){

    DatabaseReference driverTripRef = FirebaseDatabase.instance.reference().child('drivers/${driver.key}/newtrip');
    driverTripRef.set(rideRef.key);

    // Get and notify driver using token
    DatabaseReference tokenRef = FirebaseDatabase.instance.reference().child('drivers/${driver.key}/token');

    tokenRef.once().then((DataSnapshot snapshot){

      if(snapshot.value != null){

        String token = snapshot.value.toString();

        // send notification to selected driver
        HelperMethods.sendNotification(token, context, rideRef.key);
      }
      else{

        return;
      }

      const oneSecTick = Duration(seconds: 1);

      var timer = Timer.periodic(oneSecTick, (timer) {

        // stop timer when ride request is cancelled;
        if(appState != 'REQUESTING'){
          driverTripRef.set('cancelled');
          driverTripRef.onDisconnect();
          timer.cancel();
          driverRequestTimeout = 30;
        }


        driverRequestTimeout --;

        // a value event listener for driver accepting trip request
        driverTripRef.onValue.listen((event) {

          // confirms that driver has clicked accepted for the new trip request
          if(event.snapshot.value.toString() == 'accepted'){
            driverTripRef.onDisconnect();
            timer.cancel();
            driverRequestTimeout = 30;
          }
        });


        if(driverRequestTimeout == 0){

          //informs driver that ride has timed out
          driverTripRef.set('timeout');
          driverTripRef.onDisconnect();
          driverRequestTimeout = 30;
          timer.cancel();

          //select the next closest driver
          findDriver();
        }


      });


    });

  }
  resetApp(){

    setState(() {

      polylineCoordinates.clear();
      _polylines.clear();
      _markers.clear();
      _circles.clear();
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = 0;
      tripSheetHeight = 0;
      searchSheetHeight = (Platform.isAndroid) ? 275 : 300;
      mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
      drawerCanOpen = true;

      //status = '';
      //driverFullName = '';
      //driverPhoneNumber = '';
      //driverCarDetails = '';
      //tripStatusDisplay = 'Driver is Arriving';

    });

    setupPositionLocator();

  }
}
