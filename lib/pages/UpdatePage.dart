
import 'package:AnyDrop/values/DataModels.dart';
import 'package:flutter/material.dart';

class UpdatePage extends StatefulWidget {
  static final String routeName = "/update";
  UpdatePage({Key key}) : super(key: key);

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  Widget build(BuildContext context) {
    final PhoneUpdateResponse response = ModalRoute.of(context).settings.arguments;
    return Container(
       child: Stack(children: <Widget>[
         Align(alignment: Alignment(0,-0.3),
         child: Text("New Version is Available",
         textAlign: TextAlign.center,
         style: Theme.of(context).textTheme.display2)
         ),
         Align(alignment: Alignment.center,
         child: RaisedButton(
           child: Text("Download the new update"),
            onPressed: () {

           },
         ),),
         Align(alignment: Alignment(0,0.3),
         child: Padding(
           padding: const EdgeInsets.symmetric(horizontal:32.0),
           child: Text("This is a forced update since there are some breaking changes. I always ensure these kind of updates are minimum and are done only when there is an exciting new feature I have built that I think will make your life easier.",
           style: Theme.of(context).textTheme.subhead),
         )
         ),
         Align(alignment: Alignment(0,0.5),
         child: Padding(
           padding: const EdgeInsets.symmetric(horizontal:32.0),
           child: Text("You will be updating from ${response.currentVersionName} to ${response.newVersionName}",
           style: Theme.of(context).textTheme.caption),
         )
         ),
       ],),
    );
  }
}