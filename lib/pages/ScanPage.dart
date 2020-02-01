import 'dart:typed_data';

import 'package:AnyDrop/utils/ConnectionManager.dart';
import 'package:AnyDrop/pages/HomeScreen.dart';
import 'package:AnyDrop/pages/UpdatePage.dart';
import 'package:flutter/material.dart';
import 'package:AnyDrop/pages/PingPage.dart';
import 'package:AnyDrop/values/DataModels.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'HomePage.dart';
import 'package:AnyDrop/utils/Utils.dart';

class ScanPage extends StatefulWidget {
  static final String routeName = "/";
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver{
  static const _channel = const MethodChannel("app.channel.share");
  Map<String,Uint8List> _incomingData = Map();
  TextEditingController controller = TextEditingController();
  bool _isButtonEnabled = false;


  @override
  void initState() {
    super.initState();
    _checkForUpdate();
    _handleSharedIntent();
   WidgetsBinding.instance.addObserver(this);
  }


  @override
  void dispose() {
    print("Dispose Listener");
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("App LifeCycle $state");
    if(state == AppLifecycleState.resumed){
      _handleSharedIntent();
    }
  }

  void _handleSharedIntent(){
    _getSharedData().then((d){
      print("Sizeinit ${d.length}");
      if(d.isEmpty) return;
      setState(() {
          _incomingData = d;
      });
      print("Received Shared Data");
    });
  }

  Future<Map<String,Uint8List>> _getSharedData() async => await _channel.invokeMapMethod<String,Uint8List>("getSharedData");

  void _checkForUpdate() {
    ConnectionManager().isUpdateAvailable().then((updateResult) {
      PhoneUpdateResponse response = updateResult.phoneUpdateResponse;
      if (response.isUpdateAvailable && response.isForceUpdate) {
          Navigator.of(context)
              .pushReplacementNamed(UpdatePage.routeName, arguments: response);
      }
    }).catchError((onError) {
      print("Update Error"+onError.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Size build ${_incomingData.length}");
    if(_incomingData.isNotEmpty){
      if(ConnectionManager.isConnected){
        Navigator.of(context).pushNamed(HomePage.routeName);
        return Container();
      }
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Scanning for Servers"),
      ),
      body: Stack(children: <Widget>[
        Align(
          alignment: Alignment(0, -0.9),
          child: Container(
            margin: EdgeInsets.only(left: 8),
            child: Text("How to use",
            style: Theme.of(context).textTheme.headline,),
          ),
        ),
        Align(
          alignment: Alignment(0, -0.8),
          child: InkWell(
            onTap: () async{
              const uri = 'mailto:judeosby@gmail.com?subject=Suggestion or Error';
              if (await canLaunch(uri)) {
              await launch(uri);
              } else {
              doSnackbar(context, "Could not find a browser in your device. Try googleing",type: SnackbarType.ERROR);
              }
            },
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                    "Start the server in your laptop. Type in the ip below. If you dont have a server download it from judeosbert.github.io/anydrop-desktop",
                style: TextStyle(color: Colors.blue,decoration: TextDecoration.underline),)),
          ),
        ),
        Align(
          alignment: Alignment(0, -0.3),
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(vertical: 16),
            child: TextFormField(
              controller: controller,
              onChanged: (value) {
                Pattern ipPattern = r'[0-9]{4}';
                RegExp ipExp = RegExp(ipPattern);
                if (!ipExp.hasMatch(value)) {
                  return "Enter proper port number";
                } else {
                  setState(() {
                    _isButtonEnabled = true;
                  });
                }
                return null;
              },
              autovalidate: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  hintText: "Enter port of your laptop eg 8080"),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: RaisedButton(
            onPressed: !_isButtonEnabled
                ? null
                : () {
                    discoverIps();
                  },
            child: Text("Start Scan"),
          ),
        )
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(HomePage.routeName);
        },
        label: Text("Try Manual Entry"),
      ),
    );
  }

  void discoverIps() async {
    scanForHosts(controller.text).then((result) {
      if (result.isAlive) {
        ConnectionManager.setArgument(result);
        Navigator.popAndPushNamed(context, HomeScreen.routeName,
            arguments: result);
      }
    }).catchError((error) {
      print(error.cause);
    });
  }
}
