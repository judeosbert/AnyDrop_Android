import 'dart:typed_data';

import 'package:AnyDrop/pages/UpdatePage.dart';
import 'package:AnyDrop/pages/widgets/ConnectionHelpWidget.dart';
import 'package:AnyDrop/pages/widgets/DiscoveredHostList.dart';
import 'package:AnyDrop/utils/ConnectionManager.dart';
import 'package:AnyDrop/utils/Utils.dart';
import 'package:AnyDrop/values/DataModels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'HomePage.dart';

class ScanPage extends StatefulWidget {
  static final String routeName = "/";
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver{
  static const _channel = const MethodChannel("app.channel.share");
  Map<String,Uint8List> _incomingData = Map();
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
    _handleSharedIntent();
    checkAndShowHelpWindow();
   WidgetsBinding.instance.addObserver(this);
  }

  void checkAndShowHelpWindow() {
    Future.delayed(Duration(milliseconds: 200), () async {
      var isShown = await isHelpWindowShown();
      debugPrint("Shared Pref is Help Window Shown $isShown");
      if (!isShown) {
        showHelpWindow(context);
      }
    });
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
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
        return Container();
      }
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Anydrop"),
        centerTitle: true,
        actions: <Widget>[
          FlatButton.icon(onPressed: () {
            showHelpWindow(context);
          },
              icon: Icon(Icons.help), label: Text("Help"))
        ],
      ),
      body: Column(children: <Widget>[
        Expanded(
          child: Container(
              margin: EdgeInsets.only(top: 30),
              child: DiscoveredHostList()),
        ),
      ]),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(HomePage.routeName);
        },
        label: Text("Advanced Connection"),
      ),
    );
  }

  void showHelpWindow(BuildContext buildContext) async {
    await showDialog(context: buildContext, builder: (_) {
      return ConnectionHelpWidget();
    }).whenComplete(() {
      setHelpWindowShown();
    });
  }
}
