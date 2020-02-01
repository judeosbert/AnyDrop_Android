import 'dart:io';

import 'package:AnyDrop/pages/widgets/ActionsItem.dart';
import 'package:AnyDrop/pages/widgets/ConnectionStatusBar.dart';
import 'package:AnyDrop/pages/widgets/TransactionsList.dart';
import 'package:AnyDrop/values/Values.dart';
import 'package:AnyDrop/values/arguments/PortToPingArguments.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static final String routeName = "/home-screen";
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<TransactionsListState> transactionsListStateKey = GlobalKey<TransactionsListState>();

  @override
  Widget build(BuildContext context) {
    PortToPingArguments argument = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(Strings.appName,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold
          ),),
        centerTitle: true,
      ),
      body:Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ConnectionStatusBar(argument: argument,),
          ActionsMenu(argument: argument,onStringSend: onStringSend,onFileSend: onFileSend),
          Container(
              margin: EdgeInsets.only(left: 16,right:16,top: 8),
              child: Text("History",
              style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 30),
              ),
          ),
          TransactionsList(
            key:transactionsListStateKey
          ),
        ],
      ),
//      floatingActionButton: FloatingActionButton.extended(onPressed: (){
//
//      },
//        icon: Icon(Icons.autorenew),
//        label: Text("New Connection"),
//      ),
    );
  }

  void onStringSend(bool isSuccess,String data){
    transactionsListStateKey.currentState.addStringTransaction(data,isSuccess);
  }

  void onFileSend(bool isSuccess,File file){
    transactionsListStateKey.currentState.addFileTransaction(file, isSuccess);
  }


}

