import 'dart:async';

import 'package:flutter/material.dart';

class FileUploadIndicator extends StatefulWidget {
  final int totalFilesToUpload;
  final Key key;
  FileUploadIndicator(this.key,this.totalFilesToUpload):super(key:key);
  @override
  FileUploadIndicatorState createState() => FileUploadIndicatorState();
}

class FileUploadIndicatorState extends State<FileUploadIndicator> {
  int currentlyProcessedFiles = 0;

  void notifyFileComplete(){
    if(currentlyProcessedFiles == widget.totalFilesToUpload-1){
      Navigator.of(context).pop();
    }
    setState(() {
      currentlyProcessedFiles++;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progressPercent = currentlyProcessedFiles /
        widget.totalFilesToUpload;
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        title: Text("Uploading"),
        content: LinearProgressIndicator(
          backgroundColor: Colors.grey[400],
          value: progressPercent,
          valueColor: AlwaysStoppedAnimation(Colors.green),
        ),
      );

  }


}
