import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:AnyDrop/pages/widgets/RetryButton.dart';
import 'package:AnyDrop/utils/Utils.dart';
import 'package:flutter/material.dart';
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

  void addStringTransaction(StringTransaction t) {
    setState(() {
      insertOrUpdate(t);
    });
  }

  void addFileTransaction(FileTransaction t) {
    setState(() {
      insertOrUpdate(t);
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
            child: Wrap(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      ListTile(
                        leading: _getIconForTransaction(currentTransaction),
                        title: Text(currentTransaction.getTitle()),
                        subtitle: Text(timeago.format(currentTransaction
                            .timestamp)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _getSpecificAction(
                                context, currentTransaction, index),
                            IconButton(icon: Icon(Icons.delete), onPressed: () {
                              setState(() {
                                transactions.removeAt(index);
                              });
                            })
                          ],
                        ),
                      ),
                      checkAndShowProgressbar(currentTransaction),
                    ],
                  ),
                ]),
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

  void insertOrUpdate(Transaction t) {
    for (int i = 0; i < transactions.length; i++) {
      if (transactions[i].id == t.id) {
        transactions[i] = t;
        return;
      }
    }

    transactions.insert(0, t);
  }

  Widget checkAndShowProgressbar(Transaction currentTransaction) {
    return currentTransaction.isInProgress ?
    SizedBox(
        height: 2,
        child: LinearProgressIndicator()
    )
        : Container();
  }
}

abstract class Transaction{
  String id;
  TransactionTypes type;
  bool isSuccess;
  bool isInProgress;
  DateTime timestamp;

  Transaction(
      {@required this.type, @required this.isSuccess, @required this.isInProgress}) {
    id = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString() + _getRandomKey();
    refreshTimestamp();
  }

  String _getRandomKey() {
    Random _random = Random.secure();
    var values = List<int>.generate(10, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }

  void refreshTimestamp(){
    timestamp = DateTime.now();
  }

  String getTitle();
}

class StringTransaction extends Transaction{
  String value;

  StringTransaction({@required this.value, bool isSuccess, bool isInProgress})
      :super(type: TransactionTypes.STRING,
      isSuccess: isSuccess,
      isInProgress: isInProgress);

  @override
  String getTitle()=>value;
}

class FileTransaction extends Transaction{
  File file;

  FileTransaction(
      {@required this.file, bool isSuccess, @required bool isInProgress})
      :super(type: TransactionTypes.FILE,
      isSuccess: isSuccess,
      isInProgress: isInProgress);

  @override
  String getTitle()=>basename(file.path);
}

enum TransactionTypes{
  STRING,FILE
}