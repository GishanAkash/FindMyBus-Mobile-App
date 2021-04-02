import 'package:flutter/material.dart';

class fmbButton extends StatelessWidget {

  final String title;
  final Color color;
  final Function onPressed;

  fmbButton({this.title, this.onPressed, this.color});


  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(20)
      ),
      color: color,
      textColor: Colors.black45,
      child: Container(
        height: 20,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontFamily: 'Brand-Bold'),
          ),
        ),
      ),

    );
  }
}
