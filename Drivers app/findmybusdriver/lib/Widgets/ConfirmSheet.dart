import 'package:findmybusdriver/Widgets/BusOutlineButton.dart';
import 'package:findmybusdriver/Widgets/fmbButton.dart';
import 'package:flutter/material.dart';

class ConfirmSheet extends StatelessWidget {

  final String title;
  final String subtitle;
  final Function onPressed;

  ConfirmSheet({this.title, this.subtitle, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
      height: 220,
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          children: <Widget>[

            SizedBox(height:  10,),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontFamily: 'Brand-Bold', color: Colors.black45),
            ),

            SizedBox(height: 20,),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 24,),

            Row(
              children: <Widget>[

                Expanded(
                  child: Container(
                    child: BusOutlineButton(
                      title: 'BACK',
                      color: Colors.amber,
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),

                SizedBox(width: 16,),

                Expanded(
                  child: Container(
                    child: fmbButton(
                      onPressed: onPressed,
                      color: (title == 'GO ONLINE') ? Colors.amber : Colors.black,
                      title: 'CONFIRM',
                    ),
                  ),
                ),



              ],
            )

          ],
        ),
      ),
    );
  }
}