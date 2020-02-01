import 'dart:async';

import 'package:AnyDrop/utils/ConnectionManager.dart';
import 'package:flutter/material.dart';
import 'package:AnyDrop/pages/PingPage.dart';
import 'package:AnyDrop/utils/Utils.dart';
import 'package:AnyDrop/values/arguments/PortToPingArguments.dart';

class ConnectionStatusBar extends StatefulWidget {
  final PortToPingArguments argument;
  ConnectionStatusBar({@required this.argument});
  @override
  _ConnectionStatusBarState createState() => _ConnectionStatusBarState();
}

class _ConnectionStatusBarState extends State<ConnectionStatusBar> {

  PingState _currentState = PingState.SUCCESS;
  Timer timer;


  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 10), (Timer timer){
      setState(() {
        _currentState = PingState.PINGING;
      });
      ping(widget.argument.ip, widget.argument.port).then((bool success){
        setState(() {
          _currentState = success?PingState.SUCCESS:PingState.FAILED;
        });
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color:getBarColor(),
      child: Row(
          children:<Widget>[
            Expanded(
              flex: 9,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 0, 8),
                child: Text(getBarText(),
                  style: TextStyle(color: Colors.white),),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox.fromSize(
                  size: Size.square(20),
                  child: _currentState == PingState.PINGING?CircularProgressIndicator():null),
            )
          ]
      ),
    );
  }

  Color getBarColor(){
    switch(_currentState){
      case PingState.SUCCESS:
        return Colors.green;
        break;
      case PingState.FAILED:
        return Colors.red;
        break;
      default:
        return Colors.blue;
        break;
    }
  }
  String getBarText(){
    switch(_currentState){
      case PingState.SUCCESS:
        return "Connected to "+widget.argument.constructUrl();
        break;
      case PingState.FAILED:
        return "Disconnected!! Retrying...";
        break;
      default:
        return "Pinging";
        break;
    }
  }
}
