import 'dart:async';
import 'dart:convert';

import 'package:AnyDrop/values/DataModels.dart';

class RequestMethods extends Enum<String> {
  RequestMethods(String value) : super(value);
  static const PING = "ping";
  static const FILE = "file";

  @override
  String fromValue(String value) {
    switch (value.toLowerCase()) {
      case PING:
        return PING;
      case FILE:
        return FILE;
      default:
        return null;
    }
  }
}

class PingRequest extends WebsocketRequest {
  PingRequest() {
    method = RequestMethods.PING.toString();
    data = List();
    totalParts = 1;
    currentPartNumber = 1;
  }
}

class FileRequest extends WebsocketRequest {
  FileRequest() {
    method = RequestMethods.FILE.toString();
  }
}

class TransactionStreams {
  Stream<double> progressStream;
  StreamController<List<int>> dataStreamController;
}

class WebsocketRequest {
  String method;
  List<int> data;
  int totalParts, currentPartNumber, partSize;
  Map<String, dynamic> extras = Map();

  WebsocketRequest() {
    partSize = 64 * 1024; //bytes
  }

  String toJson() {
    var map = {
      "method": method,
      "data": data,
      "totalParts": totalParts,
      "partSize": partSize,
      "currentPartNumber": currentPartNumber,
      "extras": jsonEncode(extras)
    };
    return jsonEncode(map);
  }

  factory WebsocketRequest.fromJson(dynamic data) {
    WebsocketRequest request = WebsocketRequest();
    request.method = data["method"];
    request.data = data["data"];
    request.totalParts = data["totalParts"];
    request.partSize = data["partSize"];
    request.currentPartNumber = data["partNumber"];
    return request;
  }
}
