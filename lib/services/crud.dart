import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrudMedthods {
  // check log in with firebase authentication
  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser() != null) {
      return true;
    } else {
      return false;
    }
  }

//upload data into firebase 
  Future<void> addData(carData) async {
    if (isLoggedIn()) {
      Firestore.instance.collection('baby').add(carData).catchError((e) {
         print(e);
       });

    } else {
      print('You need to be logged in');
    }
  }
// fetch data from firebase
  getData() async {
    return await Firestore.instance.collection('baby').getDocuments();
  }
}