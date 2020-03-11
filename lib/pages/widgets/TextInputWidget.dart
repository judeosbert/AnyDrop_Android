import 'package:AnyDrop/pages/widgets/TransactionsList.dart';
import 'package:AnyDrop/utils/ConnectionManager.dart';
import 'package:AnyDrop/values/arguments/PortToPingArguments.dart';
import 'package:flutter/material.dart';
class TextInputWidget extends StatefulWidget {
  final Function(StringTransaction) onStringSend;
  final PortToPingArguments argument;
  TextInputWidget(this.onStringSend,this.argument);
  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  final TextEditingController controller = TextEditingController();
  bool _isSendButtonEnabled = false;
  @override
  Widget build(BuildContext context) {

          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            title: Text("Sending text over"),
            content: TextFormField(
              onChanged: (value){
                if(_isSendButtonEnabled != value.isNotEmpty) {
                  setState(() {
                    _isSendButtonEnabled = value.isNotEmpty;
                  });
                }
              },
              autofocus: true,
              decoration: InputDecoration.collapsed(
                hintText: "Paste or type the string here.",
              ),
              maxLines: 10,
              controller: controller,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
              RaisedButton.icon(
                  onPressed:_getButtonFunction(),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                  color: Colors.blue,
                  textColor: Colors.white,
                  icon: Icon(Icons.send,
                    color: Colors.white,),
                  label: Text("Send")
              ),

            ],
          );
  }
  Function _getButtonFunction(){
    return _isSendButtonEnabled?_sendFunction:null;
  }
  void _sendFunction(){
    StringTransaction transaction = StringTransaction(
      value: controller.text,);
    widget.onStringSend(transaction);
    ConnectionManager cm = ConnectionManager.getInstance();
    cm.sendString(controller.text).then((success){
      widget.onStringSend(transaction);
      Navigator.of(context).pop();
    });
  }
}
