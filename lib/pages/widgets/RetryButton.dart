import 'package:flutter/material.dart';

import '../../utils/ConnectionManager.dart';
import 'TransactionsList.dart';

class RetryButton extends StatefulWidget {
  final Transaction transaction;
  final Function onSuccess;
  RetryButton({@required this.transaction,@required this.onSuccess});

  @override
  _RetryButtonState createState() => _RetryButtonState();
}

class _RetryButtonState extends State<RetryButton> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _isRetrying = widget.transaction.isInProgress ?? false;
    _controller = AnimationController(vsync: this,duration: Duration(seconds: 1));
    _controller.repeat();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(!widget.transaction.isSuccess) {
      if(_isRetrying) {
        return AnimatedBuilder(
          animation: _controller,
          child: getChild(),
          builder: (BuildContext context, Widget _widget) {
            return Transform.rotate(angle: _controller.value * 6.3,
              child: _widget,);
          },
        );
      }else{
        return getChild();
      }
    }
    return SizedBox.fromSize(size: Size.square(0),child: null,);
  }

  Widget getChild(){
    return IconButton(
        icon: Icon(Icons.autorenew),
        onPressed: () {
          setState(() {
            _isRetrying = true;
          });
          ConnectionManager cm = ConnectionManager.getInstance();
          if (widget.transaction.type == TransactionTypes.STRING) {
            StringTransaction t = (widget.transaction) as StringTransaction;
            cm.sendString(t.value).then((isSuccess) {
              onRetryComplete(isSuccess);
            });
          }
          else if(widget.transaction.type == TransactionTypes.FILE){
            FileTransaction t = (widget.transaction ) as FileTransaction;
            cm.sendFile(t.file).then((isSuccess){
              onRetryComplete(isSuccess);
            });
          }
        });
  }

  void onRetryComplete(bool isSuccess){
    setState(() {
      _isRetrying = false;
    });
    if (!isSuccess) return;
    widget.onSuccess();
  }
}
