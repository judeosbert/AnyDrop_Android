import 'package:flutter/material.dart';
import 'package:AnyDrop/pages/PortPage.dart';
import 'package:AnyDrop/values/Values.dart';
import 'package:AnyDrop/values/arguments/IpToPortArguments.dart';

class HomePage extends StatefulWidget {
  static final routeName = "/ip";
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  String _ip = "192.168.0.101";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          Strings.appName,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(0, -0.2),
            child: Text(
              "Laptop Ip",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    validator: (value) {
                      Pattern ipPattern =
                          r'[0-9]{3}.[0-9]{3}.[0-9]{1,3}.[0-9]{1,3}';
                      RegExp ipExp = RegExp(ipPattern);
                      if (!ipExp.hasMatch(value)) {
                        return "Enter proper ip";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _ip = value;
                    },
                    initialValue: _ip,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                        hintText: "Enter ip of your laptop eg 192.168.0.1"),
                  ),
                ),
              )),
          Align(
            alignment: Alignment(0.8, 0.9),
            child: FloatingActionButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  Navigator.pushNamed(context, PortPage.routeName,
                      arguments: IpToPortArguments(_ip));
                }
              },
              child: Icon(Icons.chevron_right),
            ),
          )
        ],
      ),
    );
  }
}
