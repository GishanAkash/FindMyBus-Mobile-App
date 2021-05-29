
import 'package:connectivity/connectivity.dart';
import 'package:findmybusfinal/Widgets/fmbButton.dart';
import 'package:findmybusfinal/Widgets/progressDialog.dart';
import 'package:findmybusfinal/screens/loginpage.dart';
import 'package:findmybusfinal/screens/mainpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationPage extends StatefulWidget {

  static const String id = 'register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content:Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var fullNameController = TextEditingController();
  var phoneController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  void registerUser() async{

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: "Logging you in",),
    );

    final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    ).catchError((ex){

      //check error and display message
      Navigator.pop(context);
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);

    })).user;

    if(user != null)
    {
      DatabaseReference newUserRef = FirebaseDatabase.instance.reference().child('users/${user.uid}');

      Map userMap = {
        'fullname': fullNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      };

      newUserRef.set(userMap);

      Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
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

              Image(
                alignment: Alignment.center,
                height: 200.0,
                width: 400.0,
                image: AssetImage('images/create account.png'),
              ),

              Text("CREATE ACCOUNT",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontFamily: "myFont-Bold",color: Colors.black12.withOpacity(.6)),
              ),

              Padding(
                padding: EdgeInsets.all(35.0),
                child: Column(
                    children: <Widget>
                    [
                      //fullname
                      TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: "Full Name",
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 15.0,
                            )
                        ),
                        style: TextStyle(fontSize: 15,),
                      ),

                      SizedBox(height: 10,),
                      //email
                      TextField(
                        controller: emailController,
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

                      //phone
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: "Phone Number",
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 15.0,
                            )
                        ),
                        style: TextStyle(fontSize: 15,),
                      ),

                      SizedBox(height: 10,),

                      //password
                      TextField(
                        controller: passwordController,
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

                      SizedBox(height: 30,),

                      fmbButton(
                        title: 'REGISTER',
                        color: Colors.amber,
                        onPressed: () async{

                          //check network availability
                          var connectivityResult = await Connectivity().checkConnectivity();
                          if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                            showSnackBar('No internet connectivity');
                            return;
                          }

                          if(fullNameController.text.length<3)
                          {
                            showSnackBar("Please provide a valid Full name");
                            return;
                          }

                          if(!emailController.text.contains('@'))
                          {
                            showSnackBar("Please provide a valid email address");
                            return;
                          }

                          if(phoneController.text.length<10 || phoneController.text.length>10)
                          {
                            showSnackBar("Please provide a valid Phone number");
                            return;
                          }

                          if(passwordController.text.length<8)
                          {
                            showSnackBar("Password must be at least 8 characters");
                            return;
                          }


                          registerUser();
                        },
                      )
                    ]
                ),
              ),

              FlatButton(
                onPressed: (){
                  Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
                },
                child: Text("Already have an account? Click to login",
                    style: TextStyle(fontSize: 15, fontFamily: 'myFont-Regular',color: Colors.black12.withOpacity(.6))),
              )

            ],
          ),
        ),
      ),
    );
  }
}
