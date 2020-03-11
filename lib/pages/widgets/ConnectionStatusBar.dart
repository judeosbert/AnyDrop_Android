import 'dart:async';

import 'package:AnyDrop/pages/PingPage.dart';
import 'package:AnyDrop/utils/ConnectionManager.dart';
import 'package:AnyDrop/values/arguments/PingArgument.dart';
import 'package:flutter/material.dart';

class ConnectionStatusBar extends StatefulWidget {
  final PingArgument argument;

  ConnectionStatusBar({@required this.argument});

  @override
  _ConnectionStatusBarState createState() => _ConnectionStatusBarState();
}

class _ConnectionStatusBarState extends State<ConnectionStatusBar> {
  PingState _currentState = PingState.SUCCESS;
  Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentState = PingState.SUCCESS;
    Future.delayed(Duration.zero, () {
      ConnectionManager.getInstance().getChannel().listen((event) {

      }, onError: (e) {
        debugPrint("ConnectionStatusBar ${e.toString()}");
        setState(() {
          _currentState = PingState.FAILED;
        });
      },
          onDone: () {
            setState(() {
              _startRetryTimer();
              _currentState = PingState.FAILED;
            });
          });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: getBarColor(),
      child: Row(children: <Widget>[
        Expanded(
          flex: 9,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 0, 8),
            child: Text(
              getBarText(),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox.fromSize(
              size: Size.square(20),
              child: _currentState == PingState.PINGING
                  ? CircularProgressIndicator()
                  : null),
        )
      ]),
    );
  }

  Color getBarColor() {
    switch (_currentState) {
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

  String getBarText() {
    switch (_currentState) {
      case PingState.SUCCESS:
        return "Connected to " + widget.argument.deviceName;
        break;
      case PingState.FAILED:
        return "Disconnected!! Retrying...";
        break;
      default:
        return "Pinging";
        break;
    }
  }

  void _startRetryTimer() {
    if (_timer != null) {
      return;
    }
    _timer = Timer.periodic(Duration(seconds: 5), (t) async {
      setState(() {
        _currentState = PingState.PINGING;
      });
      var isServerAlive = await ConnectionManager.getInstance().ping();
      if (isServerAlive) {
        ConnectionManager.getInstance().connectWebsocket();
        t.cancel();
        setState(() {
          _currentState = PingState.SUCCESS;
        });
      } else {
        setState(() {
          _currentState = PingState.FAILED;
        });
      }
    });
  }

  void _stopRetryTimer() {

  }
}
