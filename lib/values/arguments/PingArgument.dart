import 'package:AnyDrop/values/arguments/PortToPingArguments.dart';

class PingArgument extends PortToPingArguments{
  bool isAlive;
  PingArgument(this.isAlive,String ip,String port):super(ip,port);
}