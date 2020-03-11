import 'dart:io';

import 'package:AnyDrop/pages/widgets/TextInputWidget.dart';
import 'package:AnyDrop/pages/widgets/TransactionsList.dart';
import 'package:AnyDrop/utils/ConnectionManager.dart';
import 'package:AnyDrop/utils/Utils.dart';
import 'package:AnyDrop/values/DataModels.dart';
import 'package:AnyDrop/values/arguments/PortToPingArguments.dart';
import 'package:advertising_id/advertising_id.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ActionsMenu extends StatefulWidget {
  final Function(StringTransaction) onStringSend;
  final PortToPingArguments argument;
  final Function(FileTransaction) onFileSend;

  ActionsMenu({@required this.argument,
    @required this.onStringSend,
    @required this.onFileSend});

  @override
  _ActionsMenuState createState() => _ActionsMenuState();
}

class _ActionsMenuState extends State<ActionsMenu> {
  final actionItems = [
    ActionItem(name: "Text", icon: Icon(Icons.font_download)),
    ActionItem(name: "File", icon: Icon(Icons.attach_file)),
    ActionItem(name: "Suggestions", icon: Icon(Icons.alternate_email)),
    ActionItem(name: "Adv Id", icon: Icon(Icons.monetization_on))
  ];

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme() =>
        MediaQuery
            .of(context)
            .platformBrightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
          color: (isDarkTheme())
              ? Color.fromARGB(1, 38, 38, 38)
              : Colors.grey[100],
          border: Border(bottom: BorderSide())),
      padding: EdgeInsets.symmetric(vertical: 10),
      height: 120,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, position) {
            ActionItem currentItem = actionItems[position];
            return Container(
              width: 90,
              child: ListTile(
                enabled: true,
                title: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color:
                      isDarkTheme() ? Colors.blueAccent : Colors.blue[100],
                      shape: BoxShape.circle),
                  child: SizedBox.fromSize(
                      size: Size.square(30), child: currentItem.icon),
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      currentItem.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                onTap: () {
                  handleActionClick(position, context);
                },
              ),
            );
          },
          itemCount: actionItems.length,
        ),
      ),
    );
  }

  void handleActionClick(int index, BuildContext context) {
    switch (index) {
      case 0:
        startSendStringFlow(context);
        break;
      case 1:
        startSendFileFlow(context);
        break;
      case 2:
        startFeedbackFlow(context);
        break;
      case 3:
        startAdvIdFlow(context);
        break;
    }
  }

  void startAdvIdFlow(BuildContext context) async {
    String id = await AdvertisingId.id;
    StringTransaction transaction =
    StringTransaction(value: id);
    widget.onStringSend(transaction);
    ConnectionManager cm = ConnectionManager.getInstance();
    cm.sendString(id).then((success) {
      widget.onStringSend(transaction);
    });
  }

  void startFeedbackFlow(BuildContext context) async {
    const uri = 'mailto:judeosby@gmail.com?subject=Suggestion or Error';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      doSnackbar(context, "Could not find a email program",
          type: SnackbarType.ERROR);
    }
  }

  void startSendFileFlow(BuildContext context) async {
    List<File> selectedFiles = await FilePicker.getMultiFile();
    if (selectedFiles.isEmpty) {
      return;
    }
    ConnectionManager cm = ConnectionManager.getInstance();
    for (int i = 0; i < selectedFiles.length; i++) {
      File f = selectedFiles[i];
      FileTransaction transaction =
      FileTransaction(file: f);
      widget.onFileSend(transaction);
      var streams = await cm.sendFile(f);
      transaction.dataStreamController = streams.dataStreamController;

      streams.progressStream.listen((percent) {
        transaction.progressPercent = percent;
        widget.onFileSend(transaction);
      }, onError: (e) async {
        transaction.progressPercent = 0;
        if (!transaction.dataStreamController.isClosed ?? false) {
          await transaction.dataStreamController.close();
        }
        transaction.dataStreamController = null;
        widget.onFileSend(transaction);
      }, onDone: () async {
        if (transaction.dataStreamController?.isClosed == false) {
          await transaction.dataStreamController.close();
        }
        transaction.dataStreamController = null;
      },
          cancelOnError: true);
    }
  }

  void startSendStringFlow(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return TextInputWidget(widget.onStringSend, widget.argument);
        });
  }
}

class ActionItem {
  String name;
  Icon icon;

  ActionItem({@required this.name, @required this.icon});
}
