import 'dart:async';

import 'package:AnyDrop/AssetManager.dart';
import 'package:AnyDrop/pages/HomePage.dart';
import 'package:AnyDrop/pages/HomeScreen.dart';
import 'package:AnyDrop/utils/ConnectionManager.dart';
import 'package:AnyDrop/values/arguments/PingArgument.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
class PingPage extends StatefulWidget {
  static final String  routeName = "/ping";
  @override
  _PingPageState createState() => _PingPageState();
}
enum PingState{
  PINGING,SUCCESS,FAILED
}

class _PingPageState extends State<PingPage> {
  PingState _pingState = PingState.PINGING;
  Timer timer;

  FlareControls controls = FlareControls();


  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,(){
      _ping(context);
    });
    timer = Timer.periodic(Duration(seconds: 5),_playAnimation);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: _getTitleText(),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: FlareActor(
              Animations.loadingStates,
              animation:getAnimationState(),
              fit: BoxFit.contain,
              controller: controls,),

          )
        ],
      ),
    );
  }

  void _playAnimation(Timer timer){
    controls.play(getAnimationState());
  }

  String getAnimationState(){
    switch(_pingState){
      case PingState.PINGING:
        return "Loading";

      case PingState.SUCCESS:
        return "Success";

      case PingState.FAILED:
        return "Error";
    }
  }

  Widget _getTitleText(){
    String text;
    switch (_pingState){
      case PingState.PINGING:
        text = "Connecting ...";
        break;
      case PingState.SUCCESS:
        text = "Success";
        break;
      case PingState.FAILED:
        text = "Failed to find Laptop !!";
        break;
    }
    return Text(text,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _pingState == PingState.FAILED?Colors.red:Colors.black
      ),
    );

  }
  void _ping(BuildContext context) async {
    PingArgument argument = ModalRoute
        .of(context)
        .settings
        .arguments;


    var isPingSuccess = await ping(argument.ip, argument.port);
    if (isPingSuccess) {
      setState(() {
        _pingState = PingState.SUCCESS;
      });
      _establishSocketConnection(argument);
      navigateToDashboard(argument);
    }
    else {
      setFailedState();
    }
  }

  void setFailedState(){
    setState(() {
      _pingState = PingState.FAILED;
    });
    navigateToIpPage();
  }
  void navigateToIpPage(){
    Future.delayed(Duration(seconds: 1),(){
      Navigator.popUntil(context,
          ModalRoute.withName(HomePage.routeName));
    });

  }

  void navigateToDashboard(PingArgument arguments) {
    Future.delayed(Duration(seconds: 1),(){
      Navigator.pushNamedAndRemoveUntil(context,
          HomeScreen.routeName,
          ModalRoute.withName(HomePage.routeName),arguments: arguments);
    });
  }

  void _establishSocketConnection(PingArgument arguments) {
    ConnectionManager.getInstance(argument: arguments).connectWebsocket();
  }
}

