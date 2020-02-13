import 'package:AnyDrop/pages/HomePage.dart';
import 'package:AnyDrop/pages/HomeScreen.dart';
import 'package:AnyDrop/pages/PingPage.dart';
import 'package:AnyDrop/pages/PortPage.dart';
import 'package:AnyDrop/pages/ScanPage.dart';
import 'package:AnyDrop/pages/UpdatePage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
          primaryColor:Colors.blue,
        backgroundColor: Color.fromARGB(1, 38, 38, 38)
      ),
      theme: ThemeData(
        brightness:Brightness.light,
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
            headline4: TextStyle(
            color: Colors.black87
          )
        )
      ),
      initialRoute: ScanPage.routeName,
      routes: {
        ScanPage.routeName:(context) => ScanPage(),
        HomePage.routeName:(context) => HomePage(),
        PortPage.routeName:(context) => PortPage(),
        PingPage.routeName:(context) => PingPage(),
        HomeScreen.routeName:(context) => HomeScreen(),
        UpdatePage.routeName:(context) => UpdatePage(),
      },
    );
  }
}
