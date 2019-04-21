import 'dart:async';

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'services/crud.dart';

import 'package:page_view_indicators/circle_page_indicator.dart';

import 'package:image_picker/image_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  
  String itemName;
  String itemPrice;
  String detail;
  List<String> imageArr = []; // array of images download url from firstore
  List<File> fileArr = []; // array of images files from image picker

  QuerySnapshot items; // collection of firebase instances data

  File sampleImage; // current image file from image picker

  CrudMedthods crudObj = new CrudMedthods();  // crud of firebase

// get image from image picker, to use camera, just change `ImageSource` to `camera`
  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

// once we get the desired image, add it to the image array
    setState(() {
      sampleImage = tempImage;
      fileArr.add(sampleImage);
    });
  }

// pop form to add new post
  Future<bool> addDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Item', style: TextStyle(fontSize: 20.0)),
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
                // if no image selected, show a text message(no image selected)
                // else shows a list view of all the selected images
                sampleImage == null ? _emptyImage() : _imageList()
              ],
            ),
            // buttons
            actions: <Widget>[
              // pick image from image source
              FloatingActionButton(
                onPressed: getImage,
                tooltip: 'Add Image',
                child: new Icon(Icons.add),
              ),
              // submit: 1. upload images to firestore; 
              //         2. upload item data(title, price, details, pictures[images url]) to firebase
              //         3. reset form
              FlatButton(
                child: Text('Add'),
                textColor: Colors.blue,
                onPressed: () {
                  // disappear pop form
                  Navigator.of(context).pop();
                  // user input validation
                  if (sampleImage != null &&
                      this.itemPrice != null &&
                      this.itemName != null &&
                      this.detail != null) {
                    dialogTrigger(context);
                    // step 1
                    uploadImage().then((result) {
                      // step 2
                      crudObj.addData({
                        'title': this.itemName,
                        'price': this.itemPrice,
                        'details': this.detail,
                        'pictures': this.imageArr
                      }).catchError((e) {
                        print(e);
                      });
                    }).then((result) {
                      // step 3
                      sampleImage = null;
                      imageArr.clear();
                      fileArr.clear();
                    }).catchError((e) {
                      dialogError(context);
                    });
                  } else { // handle invalid input
                    dialogError(context);
                  }
                },
              ),
              // cancel and reset form
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

// widget to show no image selected
  Widget _emptyImage() {
    return Container(
        height: 50,
        width: 500,
        //Text('No image selected'),
        child: PageView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Center(
              child: Text('No image selected'),
            );
          },
        ));
  }

// wideget to show a list view of selected images
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


// upload all images files to firebase
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

// invalide input alert
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

// successful submission alert
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

// use the data fethed from firebase to initialize state
  @override
  void initState() {
    crudObj.getData().then((results) {
      setState(() {
        items = results;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
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
                    items = results;
                  });
                });
                _showSnackBar();
              },
              
            )
          ],
        ),
        body: _itemList());
  }

  // adding snack bar for refreshing action after refresh button was clicked
   final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    _showSnackBar() {
      print("Show Snackbar here !");
      final snackBar = new SnackBar(
          content: new Text("Refreshing" , style: TextStyle(fontSize: 20.0), textAlign: TextAlign.center),
          duration: new Duration(seconds: 3),
          backgroundColor: Colors.blue,
          // action: new SnackBarAction(label: 'Ok', onPressed: (){
          //   print('press Ok on SnackBar');
          // }),
      );
      //How to display Snackbar ?
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }

// widget of list view for all posts in firebase
  Widget _itemList() {
    if (items != null) {
      return ListView.builder(
        itemCount: items.documents.length,
        padding: EdgeInsets.all(5.0),
        itemBuilder: (context, i) {
          return new ListTile(
            leading: SizedBox(
              height: 50.0,
              width: 50.0,
              child: new Image.network(items.documents[i].data['pictures'][0]),
            ),
            title: Text(items.documents[i].data['title']),
            subtitle: Text('\$' + items.documents[i].data['price'].toString()),
            // once tappped, shows details info of the selected post
            onTap: () => showDetails(context, items.documents[i]),
          );
        },
      );
    } else {
      return Text('Loading, Please wait..');
    }
  }

// detail pop page of one existing post
  Future<bool> showDetails(
      BuildContext context, DocumentSnapshot documents) async {
    final _items = documents.data['pictures'];
    final _currentPageNotifier = ValueNotifier<int>(0);
    final _pageController = PageController();

    _buildPageView() {
      return Container(
        height: 300.0, // Change as per your requirement
        width: 300.0, // Change as per your requirement
        // multi images in page view 
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

// indicators for images in page view
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
                Text(documents.data['title'], style: TextStyle(fontSize: 20.0)),
            content: Column(
              children: <Widget>[
                // stack up multi images in page view with indicator flow above
                Stack(
                  children: <Widget>[
                    _buildPageView(),
                    _buildCircleIndicator(),
                  ],
                ),
                Text("The price of the item is \$" +
                    documents.data['price'].toString()),
                Text("Details: " + documents.data['details'])
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
