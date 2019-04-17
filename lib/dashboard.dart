import 'dart:async';

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'services/crud.dart';

import 'package:page_view_indicators/circle_page_indicator.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String carModel;
  String carColor;

  QuerySnapshot cars;

  crudMedthods crudObj = new crudMedthods();

  Future<bool> addDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Data', style: TextStyle(fontSize: 15.0)),
            content: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(hintText: 'Enter car Name'),
                  onChanged: (value) {
                    this.carModel = value;
                  },
                ),
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(hintText: 'Enter car color'),
                  onChanged: (value) {
                    this.carColor = value;
                  },
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Add'),
                textColor: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                  if(this.carColor != null || this.carModel != null) {
                    crudObj.addData({
                    'title': this.carModel,
                    'price': this.carColor
                    }).then((result) {
                      dialogTrigger(context);
                    }).catchError((e) {
                      print(e);
                    });
                  } else {
                      dialogError(context);
                  }
                  
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                textColor: Colors.red,
                onPressed: () {
                  Navigator.of(context).pop();
                  
                },
              ),
            ],
          );
        });
  }
Future<bool> dialogError(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Ehhooo', style: TextStyle(fontSize: 15.0)),
            content: Text('Invalide input'),
            actions: <Widget>[
              FlatButton(
                child: Text('Please try again!'),
                textColor: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Future<bool> dialogTrigger(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Woohuu', style: TextStyle(fontSize: 15.0)),
            content: Text('Your post has been added!'),
            actions: <Widget>[
              FlatButton(
                child: Text('Alright'),
                textColor: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  void initState() {
    crudObj.getData().then((results) {
      setState(() {
        cars = results;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text('People are selling:'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                addDialog(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                crudObj.getData().then((results) {
                  setState(() {
                    cars = results;
                  });
                });         
              },
            )
          ],
        ),
        body: _carList());
  }

  Widget _carList() {
    if (cars != null) {
      return ListView.builder(
        itemCount: cars.documents.length,
        padding: EdgeInsets.all(5.0),
        itemBuilder: (context, i) {
          return new ListTile(
              leading:SizedBox(
                height: 50.0,
                width: 50.0,
                child: new Image.network(cars.documents[i].data['pictures'][0]),
              ),
            title: Text(cars.documents[i].data['title']),
            subtitle: Text('\$' + cars.documents[i].data['price'].toString()),
            onTap: () => showDetails(context, cars.documents[i]),
          );
        },
      );
    } else {
      return Text('Loading, Please wait..');
    }
  }

    Future<bool> showDetails(BuildContext context, DocumentSnapshot documents) async {
      final _items = documents.data['pictures'];
      final _currentPageNotifier = ValueNotifier<int>(0);
      final _pageController = PageController();

       _buildPageView() {
          return Container(
            height: 300.0, // Change as per your requirement
            width: 300.0, // Change as per your requirement
            child: PageView.builder(
              itemCount: _items.length,
              controller: _pageController,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: Image.network(_items[index]),
                );
              },
              onPageChanged: (int index) {
                _currentPageNotifier.value = index;
              },
            ),
          );
        }
      _buildCircleIndicator() {
        return Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CirclePageIndicator(
              itemCount: _items.length,
              currentPageNotifier: _currentPageNotifier,
            ),
          ),
        );
      }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(documents.data['title'], style: TextStyle(fontSize: 15.0)),
            content: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    _buildPageView(),
                    _buildCircleIndicator(),
                  ],
                ),
                Text(documents.data['price'].toString()),
                Text(documents.data['details'])
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('back'),
                textColor: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}