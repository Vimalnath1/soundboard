import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:soundboard/main.dart';

class DatabaseService{
  final String uid;
  DatabaseService({required this.uid});
  final CollectionReference buttonaudio=FirebaseFirestore.instance.collection("Audio");
  var deviceinfo= new DeviceInfoPlugin();
  Future updateUserData(List thing) async{
    return await buttonaudio.doc(uid).set({"buttons": thing}); 
  }
  
}