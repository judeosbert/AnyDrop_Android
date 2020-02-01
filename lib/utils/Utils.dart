
import 'dart:async';

import 'package:AnyDrop/values/DataModels.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


String buildUrl(String domain,String port,String path){
  return "http://"+domain+":"+port+"/"+path;
}



Future<void> copyToClipboard(String data) =>
   Clipboard.setData(ClipboardData(text: data));

void doSnackbar(BuildContext context,String message,{SnackbarType type = SnackbarType.INFO,int durationInMilli = 1000}){
  bool isTypeNotification() => type == SnackbarType.INFO;
  Flushbar(
    title: isTypeNotification()?"Heads up":"Oops",
    message: message,
    flushbarPosition: FlushbarPosition.BOTTOM,
    borderColor: isTypeNotification()?Colors.blue:Colors.red,
    margin: EdgeInsets.symmetric(horizontal: 10),
    leftBarIndicatorColor: isTypeNotification()?Colors.blue:Colors.red,
    icon: isTypeNotification()?Icon(Icons.info,
      color: Colors.blue,
    ):Icon(Icons.error,
      color: Colors.red,
    ),
    duration:Duration(milliseconds: durationInMilli),
  )..show(context);
}