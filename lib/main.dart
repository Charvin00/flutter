import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MyAppState();
}

class MyAppState extends State<MyApp> {
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Image Picker',
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Image Picker'),
        ),
        body: new Center(
          child: _image == null
              ? new Text('No image selected')
              : new Image.file(_image),
        ),
        floatingActionButton: new FloatingActionButton(
            onPressed: getImage,
            tooltip: 'Pick Image',
            child: new Icon(Icons.camera)),
      ),
    );
  }

  Widget enableUpload() {
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(_image, height: 300.0, width: 300.0),
          RaisedButton(
            elevation: 7.0,
            child: Text('Upload'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () {
              final StorageReference storageRef =
                  FirebaseStorage.instance.ref().child('myimage.jpg');
              final StorageUploadTask task =
                  storageRef.putFile(_image);
            },
          )
        ],
      ),
    );
  }
}
