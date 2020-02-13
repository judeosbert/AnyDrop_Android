import 'package:AnyDrop/pages/PingPage.dart';
import 'package:AnyDrop/utils/ConnectionManager.dart';
import 'package:AnyDrop/values/arguments/PingArgument.dart';
import 'package:flutter/material.dart';

class DiscoveredHostList extends StatefulWidget {
  @override
  _DiscoveredHostListState createState() => _DiscoveredHostListState();
}

class _DiscoveredHostListState extends State<DiscoveredHostList> {
  List<PingArgument> _hostList = [];
  bool _isScaningComplete;
  Stream _stream;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _TitleBar(
          isScanningComplete: _isScaningComplete,
          retry: scanForPeers,
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (builder, position) {
              PingArgument currentHost = _hostList[position];
              return InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(PingPage.routeName,
                      arguments: currentHost);
                },
                child: ListTile(
                  leading: currentHost.getIcon(),
                  title: Text(currentHost.deviceName),
                  subtitle: Text(currentHost.ip),
                ),
              );
            },
            itemCount: _hostList.length,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    scanForPeers();
  }

  void scanForPeers() {
    setState(() {
      _isScaningComplete = false;
      _hostList.clear();
    });
    _stream = discoverHost();
    _stream.listen((event) {
      setState(() {
        _hostList.add(event);
      });
    }).onDone(() {
      setState(() {
        _isScaningComplete = true;
      });
    });
  }
}

class _TitleBar extends StatelessWidget {
  final bool isScanningComplete;
  final Function retry;

  _TitleBar({@required this.isScanningComplete, @required this.retry});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "Select your device",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        _getStateActionWidget()
      ],
    );
  }

  Widget _getStateActionWidget() {
    if (isScanningComplete) {
      return RaisedButton.icon(
        icon: Icon(Icons.sync),
        label: Text("Rescan"),
        onPressed: () {
          retry();
        },
      );
    } else {
      return SizedBox.fromSize(
          size: Size.square(20), child: CircularProgressIndicator());
    }
  }
}
