import 'package:AnyDrop/utils/Utils.dart';
import 'package:AnyDrop/values/DataModels.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectionHelpWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      title: Text("How to use"),
      content: Wrap(children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("1) Install Server Software"),
            SizedBox.fromSize(
              size: Size.fromHeight(10),
            ),
            InkWell(
              onTap: () async {
                const uri =
                    'https://github.com/judeosbert/anydrop-desktop/releases';
                if (await canLaunch(uri)) {
                  await launch(uri);
                } else {
                  doSnackbar(context,
                      "Could not find a browser in your device. Try googleing",
                      type: SnackbarType.ERROR);
                }
              },
              child: Text(
                "Open bit.ly/anydropdesktop on your laptop",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox.fromSize(
              size: Size.fromHeight(10),
            ),
            Text(
                "2) Click on the green play button to start the server on your laptop and press the rescan button in this screen if your device is not listed.")
          ],
        )
      ]),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Okay, Got it"),
        )
      ],
    );
  }
}
