import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:AnyDrop/utils/Utils.dart';
import 'package:AnyDrop/values/DataModels.dart';
import 'package:AnyDrop/values/Values.dart';
import 'package:AnyDrop/values/arguments/PingArgument.dart';
import 'package:AnyDrop/values/arguments/PortToPingArguments.dart';
import 'package:AnyDrop/values/models.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get, post, MultipartRequest, MultipartFile;
import 'package:http/http.dart' show get;
import 'package:path/path.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:wifi/wifi.dart';

class ConnectionManager {
  //TestValues
  var testResult =
      '{ "v": "2.0", "bn": 2, "force": true, "sv": "2.0", "sbn": 2, "sforce": true }';
  static final Duration _timeoutDuration = Duration(seconds: 10);
  static final ConnectionManager _instance = ConnectionManager._internal();

  factory ConnectionManager() => _instance;
  IOWebSocketChannel _webSocketChannel;
  Stream _broadcastSocketStream;
  String _baseUrl;
  String updateURL =
      "https://my-json-server.typicode.com/judeosbert/anydrop-server-update/info";
  static PortToPingArguments mArgument;

  ConnectionManager._internal();

  static setArgument(PortToPingArguments argument) {
    mArgument = argument;
  }

  static ConnectionManager _getInstanceWith(String domain, String port) {
    _instance._baseUrl = buildWebsocketUrl(domain, port);
    return _instance;
  }

  static ConnectionManager _getInstanceWithAddressObject(
      PortToPingArguments argument) {
    if (argument == null && mArgument == null) {
      return null;
    }
    if (mArgument == null) {
      mArgument = argument;
    }
    return _getInstanceWith(argument.ip, argument.port);
  }

  static ConnectionManager getInstance({PortToPingArguments argument}) {
    if (mArgument != null) {
      return _instance;
    }
    return _getInstanceWithAddressObject(argument);
  }

  static bool get isConnected => mArgument != null;

  Future<bool> sendString(String string) async {
    String _path = "string";
    String _finalUrl = _baseUrl + _path;
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    try {
      var body = jsonEncode(_StringBody(string));
      print("Request Body $body");
      var result = await post(_finalUrl, body: body, headers: headers);
      debugPrint(result.toString());
      return result.statusCode == 200;
    } catch (_) {
      return false;
    }
  }


  Future<TransactionStreams> sendFile(File file) async {
    TransactionStreams streams = TransactionStreams();
    StreamSubscription subscription;
    var chunkSize = 64 * 1024;

    var progressController = StreamController<double>();
    var fileReadStreamController = StreamController<List<int>>();
    Connectivity().onConnectivityChanged.listen((
        ConnectivityResult result) async {
      switch (result) {
        case ConnectivityResult.wifi:
          try {
            ConnectionManager.getInstance().connectWebsocket();
            await ping();
            subscription.resume();
          } catch (e) {
            debugPrint(e.toString());
          }
          break;
        default:
          subscription.pause();
          break;
      }
    });
    streams.progressStream = progressController.stream;
    streams.dataStreamController = fileReadStreamController;
    var totalFileSize = file.lengthSync();
    var totalParts = (totalFileSize.toDouble() / chunkSize.toDouble()).ceil();
    var currentPartNumber = 0;
    FileRequest request = FileRequest();
    request.totalParts = totalParts;
    request.extras["fileName"] = basename(file.path);

    subscription = file.openRead().listen((chunk) {
      if (!fileReadStreamController.isClosed) {
        fileReadStreamController.add(chunk);
      }
    }, onError: (e) {
      subscription.cancel();
      if (!fileReadStreamController.isClosed) {
        fileReadStreamController.addError(e);
      }
    }, onDone: () {
      subscription.cancel();
      if (!fileReadStreamController.isClosed) {
        fileReadStreamController.close();
      }
    }, cancelOnError: true);

    fileReadStreamController.stream.listen((chunk) async {
      debugPrint("File Read Stream listen");
      currentPartNumber++;
      request.currentPartNumber = currentPartNumber;
      request.data = chunk;


      _webSocketChannel.sink.add(request.toJson());
      progressController.sink.add((currentPartNumber / totalParts.toDouble()));
    }, onError: (e) {
      debugPrint("ConnectionManager SendFile ${e.toString()}");
      progressController.addError(e);
      progressController.close();
      fileReadStreamController.close();
    }, onDone: () {
      debugPrint("File Read Closed");
      progressController.close();
      fileReadStreamController.close();
    }, cancelOnError: true);
    return Future.value(streams);
  }

  Future<SystemUpdateResponse> isUpdateAvailable() async {
    SystemUpdateResponse isUpdateAvailable = SystemUpdateResponse();
    try {
      var result = await get(_instance.updateURL);
      Map<String, dynamic> updateValues = jsonDecode(result.body);

      PhoneUpdateResponse phoneUpdateResponse = PhoneUpdateResponse();
      phoneUpdateResponse.isForceUpdate = updateValues['force'];
      phoneUpdateResponse.newBuildNumber = updateValues['bn'];
      phoneUpdateResponse.isUpdateAvailable =
          _findIfUpdateAvailable(phoneUpdateResponse.newBuildNumber);
      phoneUpdateResponse.newVersionName = updateValues['v'];
      isUpdateAvailable.phoneUpdateResponse = phoneUpdateResponse;
    } on Exception catch (e) {
      Future.error(e);
    }
    return Future.value(isUpdateAvailable);
  }

  bool _findIfUpdateAvailable(int newBuildNumber) =>
      newBuildNumber > ReleaseValues.buildNumber;

  Future<bool> ping({String url}) async {
    if (url == null) {
      url = buildWebsocketUrl(mArgument.ip, mArgument.port);
    }
    try {
      var socket = await WebSocket.connect(url);
      return Future.value(true).whenComplete(() =>
          socket.close(status.normalClosure));
    } catch (_) {
      return Future.value(false);
    }
  }


  void connectWebsocket() {
    var url = buildWebsocketUrl(mArgument.ip, mArgument.port);
    _webSocketChannel =
        IOWebSocketChannel.connect(url, pingInterval: Duration(seconds: 3));
    _broadcastSocketStream = _webSocketChannel.stream.asBroadcastStream();
  }

  Stream<dynamic> getChannel() => _broadcastSocketStream;


}

Future<bool> ping(String domain, String port) async {
  String pingUri = buildWebsocketUrl(domain, port);
  print("Pinging url $pingUri");
  return ConnectionManager().ping(url: pingUri);
}

Future<bool> pingWithUrl(String url) {
  return ConnectionManager().ping(url: url);
}

Future<PingArgument> pingForHosts(String domain, String port) async {
  String pingUrl = buildWebsocketUrl(domain, port);
  print("Pinging url $pingUrl");
  try {
    WebSocket socket = await WebSocket.connect(pingUrl);
    socket.add(PingRequest().toJson());
    return Future.value(PingArgument(true, domain, port, await socket.first))
        .whenComplete(() =>
        socket.close()
    );
  } catch (e) {
    print("Ping Error catch${e.toString()}");
    return Future.value(PingArgument(false, domain, port, ""));
  }
}

Stream<PingArgument> discoverHost() {
  final controller = StreamController<PingArgument>();
  Wifi.ip.then((ip) {
    final String subnet = ip.substring(0, ip.lastIndexOf("."));
    var futures = <Future<PingArgument>>[];
    for (int i = 1; i <= 255; i++) {
      final host = "$subnet.$i";
      final Future<PingArgument> f = pingForHosts(host, portNumber.toString());
      futures.add(f);
      f.then((argument) {
        debugPrint("Ping Future Argument" +
            argument.deviceName +
            argument.isAlive.toString());
        if (argument.isAlive) {
          debugPrint("Sending host info");
          controller.sink.add(argument);
        }
      }).catchError((error) {
        debugPrint("Connection Error ${error.toString()}");
//        controller.addError(error);
      });
    }
    Future.wait(futures).catchError((error) {
      controller.addError(error);
    }).whenComplete(() => controller.close());
  });

  return controller.stream;
}

class _StringBody {
  String value;

  _StringBody(this.value);

  Map<String, dynamic> toJson() => {'value': value};
}
