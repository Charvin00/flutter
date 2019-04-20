import 'package:flutter/material.dart';

import 'loginpage.dart';
import 'dashboard.dart';

void main() => runApp(new MyApp());

//entry of app; dummy account: test@gmail.com | password: 123321
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      // goes to my home page(log in page) first
      home: new MyHomePage(),
      //if logged in, direct to dashboard page
      routes:<String, WidgetBuilder> {
        '/homepage' : (BuildContext context) => DashboardPage()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Hyper Garage Sale'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: new Center(
        child: LoginPage(),
      ),
    );
  }
}