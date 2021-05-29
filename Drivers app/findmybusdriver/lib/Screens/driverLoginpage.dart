import 'package:connectivity/connectivity.dart';
import 'package:findmybusdriver/Screens/mainpage.dart';
import 'package:findmybusdriver/Screens/registrationpage.dart';
import 'package:findmybusdriver/Widgets/fmbButton.dart';
import 'package:findmybusdriver/Widgets/progressDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {

  static const String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final mysnackbar = SnackBar(
      content:Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(mysnackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var passengerEmailController = TextEditingController();

  var passengerPasswordController = TextEditingController();

  void login() async {

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: "Logging you in",),
    );

    final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
      email: passengerEmailController.text,
      password: passengerPasswordController.text,
    ).catchError((ex){

      //check error and display message
      Navigator.pop(context);
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);

    })).user;

    Navigator.pop(context);
    if(user != null){
      // verify login
      DatabaseReference userReference = FirebaseDatabase.instance.reference().child('drivers/${user.uid}');
      userReference.once().then((DataSnapshot snapshot) {

        if(snapshot.value != null){
          //Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children:<Widget> [
              //SizedBox(height: 1,),
              Image(
                alignment: Alignment.center,
                height: 400.0,
                width: 400.0,
                image: AssetImage('images/logo.png'),
              ),

              Text("LOGIN AS A DRIVER",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontFamily: "myFont-Bold",color: Colors.black12.withOpacity(.6)),
              ),

              Padding(
                padding: EdgeInsets.all(35.0),
                child: Column(
                    children: <Widget>
                    [
                      TextField(
                        controller: passengerEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 15.0,
                            )
                        ),
                        style: TextStyle(fontSize: 15,),
                      ),

                      SizedBox(height: 10,),

                      TextField(
                        controller: passengerPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 15.0,
                            )
                        ),
                        style: TextStyle(fontSize: 15,),
                      ),

                      SizedBox(height: 10,),

                      fmbButton(
                        title: 'LOGIN',
                        color: Colors.amber,
                        onPressed: () async{

                          //check network availability
                          var connectivityResult = await Connectivity().checkConnectivity();
                          if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                            showSnackBar('No internet connection available');
                            return;
                          }

                          if(!passengerEmailController.text.contains('@')){
                            showSnackBar('Please enter a valid email address');
                            return;
                          }

                          if(passengerPasswordController.text.length < 8){
                            showSnackBar('Please enter a valid password');
                            return;
                          }
                          login();
                        },
                      )

                    ]
                ),
              ),

              TextButton(
                onPressed: (){
                  Navigator.pushNamedAndRemoveUntil(context, RegistrationPage.id, (route) => false);
                },
                child: Text("Don't have a drivers account?"+" Register here",
                    style: TextStyle(fontSize: 15, fontFamily: 'myFont-Regular',color: Colors.black12.withOpacity(.6))),
              )

            ],
          ),
        ),
      ),
    );
  }
}


