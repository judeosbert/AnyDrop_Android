import 'package:AnyDrop/pages/PingPage.dart';
import 'package:AnyDrop/values/Values.dart';
import 'package:AnyDrop/values/arguments/IpToPortArguments.dart';
import 'package:AnyDrop/values/arguments/PortToPingArguments.dart';
import 'package:flutter/material.dart';
class PortPage extends StatefulWidget {
  static final routeName = "/port";
  @override
  _PortPageState createState() => _PortPageState();
}

class _PortPageState extends State<PortPage> {
  final _formKey = GlobalKey<FormState>();
  String _port = "22562";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(Strings.appName,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color:Colors.black87),
        ),
        centerTitle: true,
      ) ,
      body:Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(0, -0.2),
            child: Text("Laptop Port",
              style: TextStyle(fontSize: 20.0,
                  fontWeight: FontWeight.bold
              ),),
          ),
          Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    readOnly: true,
                    initialValue: _port,
                    validator: (value){
                      Pattern ipPattern = r'[0-9]{4}';
                      RegExp ipExp = RegExp(ipPattern);
                      if(!ipExp.hasMatch(value)){
                        return "Enter proper port number";
                      }
                      return null;
                    },
                    onSaved: (value){
                      _port = value;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: "Enter port of your laptop eg 8080"
                    ),
                  ),
                ),
              )
          ),
          Align(
            alignment: Alignment(0.8, 0.9),
            child: FloatingActionButton(onPressed: (){
              if(_formKey.currentState.validate()){
                _formKey.currentState.save();
                IpToPortArguments prevArgument = ModalRoute.of(context).settings.arguments;
                PortToPingArguments pingArgument = PortToPingArguments(prevArgument.ip,_port);

                Navigator.pushNamed(context,
                    PingPage.routeName,
                    arguments:pingArgument);
              }
            },
              child: Icon(Icons.chevron_right),),
          )
        ],
      ),
    );
  }
}
