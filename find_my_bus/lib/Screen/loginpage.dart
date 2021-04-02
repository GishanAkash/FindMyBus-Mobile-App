import 'package:connectivity/connectivity.dart';
import 'package:find_my_bus/Screen/mainpage.dart';
import 'package:find_my_bus/Screen/registrationpage.dart';
import 'package:find_my_bus/Widgets/ProgressDialog.dart';
import 'package:find_my_bus/Widgets/fmbButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
      DatabaseReference userReference = FirebaseDatabase.instance.reference().child('users/${user.uid}');
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

              Text("LOGIN",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30, fontFamily: "Brand-Bold",color: Colors.black12.withOpacity(.6)),
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
                child: Text("Don't have an account?"+" SIGN UP",
                style: TextStyle(fontSize: 15, fontFamily: 'Brand-Regular',color: Colors.black12.withOpacity(.6))),
              )

            ],
          ),
        ),
      ),
    );
  }
}


