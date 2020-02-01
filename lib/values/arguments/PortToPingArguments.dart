import 'package:AnyDrop/utils/Utils.dart';
import 'package:AnyDrop/values/arguments/IpToPortArguments.dart';

class PortToPingArguments extends IpToPortArguments{

  String port;

  PortToPingArguments(String ip,this.port):super(ip);

  String constructUrl(){
    return buildUrl(ip, port,"");
  }
}