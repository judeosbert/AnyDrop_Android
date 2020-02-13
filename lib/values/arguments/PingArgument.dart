import 'dart:convert';

import 'package:AnyDrop/values/arguments/PortToPingArguments.dart';
import 'package:flutter/material.dart';

class PingArgument extends PortToPingArguments{
  String _deviceNameKey = "deviceName";
  String _deviceTypeKey = "deviceType";
  bool isAlive;
  String deviceName, deviceType;

  PingArgument(this.isAlive, String ip, String port, String serverResponse)
      :super(ip, port) {
    if (serverResponse.length != 0) {
      var parsedJson = json.decode(serverResponse);
      deviceName = parsedJson[_deviceNameKey];
      deviceType = parsedJson[_deviceTypeKey];
    }
  }

  Icon getIcon() {
    switch (deviceType) {
      case "laptop":
        return Icon(Icons.laptop_mac);
        break;
    }
  }

}