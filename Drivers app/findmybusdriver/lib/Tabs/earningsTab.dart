import 'package:findmybusdriver/Screens/historyPage.dart';
import 'package:findmybusdriver/Widgets/brandDivider.dart';
import 'package:findmybusdriver/dataprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EarningsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Container(
          color: Colors.amber,
          width: double.infinity,
          child: Padding(
            padding:  EdgeInsets.symmetric(vertical: 70),
            child: Column(
              children: [

                Text('EARNINGS', style: TextStyle(color: Colors.white),),
                Text('\LKR.${Provider.of<AppData>(context).earnings}', style: TextStyle(color: Colors.white, fontSize: 40, fontFamily: 'Brand-Bold'),)
              ],
            ),
          ),
        ),

        // ignore: deprecated_member_use
        FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> HistoryPage()));
          },

          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            child: Row(
              children: [
                Image.asset('images/Bus.png', width: 70,),
                SizedBox(width: 16,),
                Text('Trip 1', style: TextStyle(fontSize: 16),),
                Expanded(child: Container(child: Text(Provider.of<AppData>(context).tripCount.toString(), textAlign: TextAlign.end, style: TextStyle(fontSize: 18),))),
              ],
            ),
          ),

        ),

        BrandDivider(),

      ],
    );
  }
}