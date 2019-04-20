import 'dart:async';

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'services/crud.dart';

import 'package:page_view_indicators/circle_page_indicator.dart';

import 'package:image_picker/image_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:path/path.dart';


class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String itemName;
  String itemPrice;
  String detail;
  List<String> imageArr = [];
  List<File> fileArr = [];

  QuerySnapshot cars;

  File sampleImage;

  crudMedthods crudObj = new crudMedthods();

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = tempImage;
      fileArr.add(sampleImage);
    });
  }

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
                  decoration: InputDecoration(hintText: 'Enter item name'),
                  onChanged: (value) {
                    this.itemName = value;
                  },
                ),
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(hintText: 'Enter item price'),
                  onChanged: (value) {
                    this.itemPrice = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(hintText: 'Enter detail'),
                  onChanged: (value) {
                    this.detail = value;
                  },
                ),
                sampleImage == null
                    ? _emptyImage()
                    : _imageList()
              ],
            ),
            actions: <Widget>[
              FloatingActionButton(
                onPressed: getImage,
                tooltip: 'Add Image',
                child: new Icon(Icons.add),
              ),
              FlatButton(
                child: Text('Add'),
                textColor: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                  if (sampleImage != null ||
                      this.itemPrice != null ||
                      this.itemName != null ||
                      this.detail != null) {
                    dialogTrigger(context);
                    uploadImage().then((result) {
                      crudObj.addData({
                        'title': this.itemName,
                        'price': this.itemPrice,
                        'details': this.detail,
                        'pictures': this.imageArr
                      }).catchError((e) {
                        print(e);
                      });
                    }).then((result) {
                      sampleImage = null;
                      imageArr.clear();
                      fileArr.clear();
                    }).catchError((e) {
                      dialogError(context);
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
                  sampleImage = null;
                  imageArr.clear();
                  fileArr.clear();
                },
              ),
            ],
          );
        });
  }

  Future<String> uploadImage() async {
    for (var image in fileArr) {
    var now = new DateTime.now().toString();
    StorageReference ref = FirebaseStorage.instance.ref().child(now);
    StorageUploadTask uploadTask = ref.putFile(image);

    var downUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    imageArr.add(downUrl);
    }

    return "";
  }

  // Future<String> uploadData(BuildContext context) async {
  //   crudObj.addData({
  //     'title': this.itemName,
  //     'price': this.itemPrice,
  //     'details': this.detail,
  //     'pictures': this.imageArr
  //   }).then((result) {
  //     dialogTrigger(context);
  //   }).catchError((e) {
  //     print(e);
  //   });
  //   return "";
  // }

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

Widget _emptyImage() {
    return Container(
      height: 50,
      width: 500,
      child: Text('No image selected'),
    );
    
  }
Widget _imageList() {
    return Container(
      height: 450,
      width: 500,
      child: ListView.builder(
        itemCount: fileArr.length,
        padding: EdgeInsets.all(5.0),
        itemBuilder: (context, i) {
          return new Image.file(fileArr[i], height: 200, width: 300);
        },
      ),
    );
    
  }

  Widget _carList() {
    if (cars != null) {
      return ListView.builder(
        itemCount: cars.documents.length,
        padding: EdgeInsets.all(5.0),
        itemBuilder: (context, i) {
          return new ListTile(
            leading: SizedBox(
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

  Future<bool> showDetails(
      BuildContext context, DocumentSnapshot documents) async {
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
            title:
                Text(documents.data['title'], style: TextStyle(fontSize: 15.0)),
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
