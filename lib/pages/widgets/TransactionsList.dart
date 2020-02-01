import 'dart:io';

import 'package:flutter/material.dart';
import 'package:AnyDrop/pages/widgets/RetryButton.dart';
import 'package:AnyDrop/utils/Utils.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:timeago/timeago.dart' as timeago;
class TransactionsList extends StatefulWidget {
  final Key key;
  TransactionsList({this.key}):super(key:key);

  @override
  TransactionsListState createState() => TransactionsListState();
}

class TransactionsListState extends State<TransactionsList> {
  List<Transaction> transactions = [];

  void addStringTransaction(String value,bool isSuccess){
    StringTransaction t = StringTransaction(value: value, isSuccess: isSuccess);
    setState(() {
      transactions.insert(0,t);
    });
  }

  void addFileTransaction(File file,bool isSuccess){
    FileTransaction t = FileTransaction(file: file,isSuccess: isSuccess);
    setState(() {
      transactions.insert(0,t);
    });

  }
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: _getListOrEmptyScreen()
    );
  }

  Widget _getListOrEmptyScreen(){
    if (transactions.length == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.child_care,
            size: 200,
            color: Colors.grey[350],),
          Text("You have not transferred anything yet !!")
        ],
      );
    }
    else{
      return ListView.builder(itemBuilder: (context,index){
        Transaction currentTransaction = transactions[index];
        bool isFileTransaction() => currentTransaction.type == TransactionTypes.FILE;
        return InkWell(
          onTap: (){
            if(isFileTransaction()){
              _openFileViewer(currentTransaction);
            }else{
              _copyToClipboard(context,currentTransaction.getTitle());
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 16,horizontal: 8),
            child: ListTile(
              leading: _getIconForTransaction(currentTransaction),
              title: Text(currentTransaction.getTitle()),
              subtitle: Text(timeago.format(currentTransaction.timestamp)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _getSpecificAction(context,currentTransaction,index),
                  IconButton(icon: Icon(Icons.delete), onPressed: (){
                    setState(() {
                      transactions.removeAt(index);
                    });
                  })
                ],
              ),
            ) ,
          ),
        );
        },
      itemCount: transactions.length,);

    }
  }

  Widget _getSpecificAction(BuildContext context,Transaction t,int index){
    if(t.isSuccess) {
      switch (t.type) {
        case TransactionTypes.STRING:
          StringTransaction stringTransaction = t as StringTransaction;
          return IconButton(icon: Icon(Icons.content_copy),
            onPressed: () {
              _copyToClipboard(context,stringTransaction.value);
            },
          );
          break;
        case TransactionTypes.FILE:
          return IconButton(icon: Icon(Icons.open_in_browser),
            onPressed: () {
              _openFileViewer(t);
            },
          );
          break;
        default:
          return IconButton(icon: Icon(Icons.device_unknown), onPressed: null);
      }
    }else{
      return RetryButton(
        transaction: t,
        onSuccess: (){
          t.isSuccess = true;
          t.refreshTimestamp();
          setState(() {
            transactions.replaceRange(index, index+1, [t]);
          });
        },
      );
    }


  }

  Icon _getIconForTransaction(Transaction t){
    switch(t.type){
      case TransactionTypes.STRING:
        return Icon(Icons.font_download);
        break;
      case TransactionTypes.FILE:
        return Icon(Icons.attach_file);
        break;
    }
    return Icon(Icons.device_unknown);

  }

  void _openFileViewer(FileTransaction t) async{
    OpenFile.open(t.file.path);
  }

  void _copyToClipboard(BuildContext context,String value){
    copyToClipboard(value).then((_){
      doSnackbar(context, "$value copied to clipboard");
    }).catchError((onError){
      doSnackbar(context, "Error copying text to clipboard");
    });
  }
}

abstract class Transaction{
  TransactionTypes type;
  bool isSuccess;
  DateTime timestamp;
  Transaction({@required this.type, @required this.isSuccess}){
    refreshTimestamp();
  }

  void refreshTimestamp(){
    timestamp = DateTime.now();
  }
  String getTitle();
}

class StringTransaction extends Transaction{
  String value;
  StringTransaction({@required this.value,bool isSuccess}):super(type:TransactionTypes.STRING,isSuccess:isSuccess);

  @override
  String getTitle()=>value;
}

class FileTransaction extends Transaction{
  File file;
  FileTransaction({@required this.file,bool isSuccess}):super(type:TransactionTypes.FILE,isSuccess:isSuccess);

  @override
  String getTitle()=>basename(file.path);
}

enum TransactionTypes{
  STRING,FILE
}