import 'package:findmybusdriver/Screens/mainpage.dart';
import 'package:findmybusdriver/Widgets/fmbButton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../global variables.dart';

class VehicleInfoPage extends StatelessWidget {

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  static const String id = 'vehicleinfo';

  var carModelController = TextEditingController();
  var carColorController = TextEditingController();
  var vehicleNumberController = TextEditingController();

  void updateProfile(context){

    String id = currentFirebaseUser.uid;
    DatabaseReference driverRef =
    FirebaseDatabase.instance.reference().child('drivers/$id/vehicle_details');

    Map map = {
      'car_color': carColorController.text,
      'car_model': carModelController.text,
      'vehicle_number': vehicleNumberController.text,
    };

    driverRef.set(map);

    Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(

            children: <Widget>[

              SizedBox(height: 20,),

              Image.asset('images/logo.png', height: 400, width: 400,),

              Padding(
                padding: EdgeInsets.fromLTRB(30,20,30,30),
                child: Column(
                  children: <Widget>[

                    SizedBox(height: 10,),

                    Text('ENTER VEHICLE DETAILS', style: TextStyle(fontSize: 22, fontFamily: 'myFont-Bold', color: Colors.black45),),

                    SizedBox(height: 20,),

                    TextField(
                      controller: carModelController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Car Brand and Model',
                        hintStyle: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 10.0,
                        )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),

                    SizedBox(height: 10,),

                    TextField(
                      controller: carColorController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Car color',
                          hintStyle: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 10.0,
                          )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),

                    SizedBox(height: 10,),

                    TextField(
                      controller: vehicleNumberController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Vehicle number',
                          hintStyle: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 10.0,
                          )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),

                    SizedBox(height: 40,),

                    fmbButton(
                      color: Colors.amber,
                      title: 'Proceed',
                      onPressed: (){

                        if(carModelController.text.length < 3){
                          showSnackBar('Please provide a valid car model');
                          return;
                        }

                        if(carColorController.text.length < 3){
                          showSnackBar('Please provide a valid car color');
                          return;
                        }

                        if(vehicleNumberController.text.length < 3){
                          showSnackBar('Please provide a valid vehicle number');
                          return;
                        }

                        updateProfile(context);

                      },
                    )
                  ],
                ),
              )

            ],

          ),
        ),
      ),
    );
  }
}
