
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:AnyDrop/values/DataModels.dart';
import 'package:AnyDrop/values/Values.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get,post,MultipartRequest,MultipartFile;
import 'package:AnyDrop/utils/Utils.dart';
import 'package:AnyDrop/values/arguments/PortToPingArguments.dart';
import 'package:AnyDrop/values/arguments/PingArgument.dart';
import 'package:http/http.dart' show get;
import 'package:wifi/wifi.dart';

class ConnectionManager{
  //TestValues
  var testResult = '{ "v": "2.0", "bn": 2, "force": true, "sv": "2.0", "sbn": 2, "sforce": true }';

  static final ConnectionManager _instance = ConnectionManager . _internal();
  factory ConnectionManager() => _instance;
  String _baseUrl;
  String updateURL = "https://my-json-server.typicode.com/judeosbert/anydrop-server-update/info";
  static PortToPingArguments mArgument;
  ConnectionManager ._internal();
  static setArgument(PortToPingArguments argument){
    mArgument  = argument;
  }
 static ConnectionManager getInstanceWith(String domain,String port){
   _instance._baseUrl = buildUrl(domain, port,"");
   return _instance;
 }
 static ConnectionManager getInstanceWithAddressObject(PortToPingArguments argument){
    if(argument == null){
      return null;
    }
    return getInstanceWith(argument.ip, argument.port);
 }
 static ConnectionManager getInstance()=> getInstanceWithAddressObject(mArgument);

  static bool get isConnected => mArgument!= null;
  Future<bool> sendString(String string) async  {
    String _path = "string";
    String _finalUrl = _baseUrl+_path;
    Map<String,String> headers = {
      'Content-type' : 'application/json', 
      'Accept': 'application/json',
    };
    try{
      var body = jsonEncode(_StringBody(string));
      print("Request Body $body");
      var result = await post(_finalUrl,body:body,headers: headers);
      debugPrint(result.toString());
      return result.statusCode == 200;
    } catch(_){
      return false;
    }
  }

  Future<bool> sendFile(File file) async{
    String _path = "file";
    String _finalUrl = _baseUrl+_path;
    try{
      var uri = Uri.parse(_finalUrl);
      var request = MultipartRequest('POST', uri)
      ..files.add(await MultipartFile.fromPath('file', file.path));
      var response = await request.send();
      return response.statusCode == 200;
    }
    catch(_){
      return false;
    }
  }

 Future<SystemUpdateResponse> isUpdateAvailable() async{
   SystemUpdateResponse isUpdateAvailable = SystemUpdateResponse();
   try{
     var result = await get(_instance.updateURL);
     Map<String,dynamic> updateValues = jsonDecode(result.body);

     PhoneUpdateResponse phoneUpdateResponse = PhoneUpdateResponse();
     phoneUpdateResponse.isForceUpdate = updateValues['force'];
     phoneUpdateResponse.newBuildNumber = updateValues['bn'];
     phoneUpdateResponse.isUpdateAvailable =  _findIfUpdateAvailable(phoneUpdateResponse.newBuildNumber);
     phoneUpdateResponse.newVersionName = updateValues['v'];
     isUpdateAvailable.phoneUpdateResponse = phoneUpdateResponse;

   }on Exception
   catch(e){
     Future.error(e);
   }
   return Future.value(isUpdateAvailable);
 }

 bool _findIfUpdateAvailable(int newBuildNumber) =>
   newBuildNumber > ReleaseValues.buildNumber;

}

Future<bool> ping(String domain,String port) async {

  String pingUri = buildUrl(domain, port, "ping");
  print("Pinging url $pingUri");
  try{
    var result = await get(pingUri);
    return result.statusCode == 200;
  }
  catch(_){
    return false;
  }

}
Future<PingArgument> pingForHosts(String domain,String port) async{
  String pingUrl = buildUrl(domain, port, "ping");
  print("Pinging url $pingUrl");
  try{
    var result = await get(pingUrl);
    var isAlive = result.statusCode == 200;
    print ("Ping $isAlive");
    return PingArgument(isAlive,domain,port);
  }
  catch(_){
    print ("Ping Error");
    return PingArgument(false,domain,port);
  }
}

Future<PingArgument> scanForHosts(String port) async{
  final String ip = await Wifi.ip;
  var data = await _discoverHost(ip, port).handleError((error){
    return Future.error(error);
  }).firstWhere((argument)=> argument.isAlive == true,orElse:(){
    return PingArgument(false,"","");
  });

  return Future.value(data);
}

Stream<PingArgument> _discoverHost(String ip,String port){
  final controller = StreamController<PingArgument>();
  final String subnet = ip.substring(0,ip.lastIndexOf("."));
  var futures = <Future<PingArgument>>[];
  for(int i = 1; i <= 255;i++){
    final host = "$subnet.$i";
    final Future<PingArgument> f = pingForHosts(host,port);
    futures.add(f);
    f.then((argument){
      controller.sink.add(argument);
    }).catchError((error){
      controller.addError(error);
      controller.close();
    });
  }
  Future.wait(futures).then((_){
    controller.close();
  }).catchError((error){
    controller.addError(error);
    controller.close();
  });
  return controller.stream;

}

class _StringBody{
  String value;
  _StringBody(this.value);

  Map<String,dynamic> toJson() =>{
    'value':value
  };
}