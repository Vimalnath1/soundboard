import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:soundboard/services/database.dart';
import 'package:firebase_core/firebase_core.dart';

List <Widget> buttons=[];
List buttondata=[];
Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  String? deviceId = await getId();
  FirebaseFirestore.instance.collection("Audio").doc(deviceId.toString()).get().then(( DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        var database=snapshot.data();
        Map<String, dynamic> data = {
          "data":database
        };
        for (var i=0; i<data["data"]["buttons"].length;i++){
          buttons.add(sound(data["data"]["buttons"][i]["name"],data["data"]["buttons"][i]["file"]));
          buttondata.add({"name":data["data"]["buttons"][i]["name"],"file":data["data"]["buttons"][i]["file"]});
          print(buttons);
          print(data["data"]["buttons"][i]["name"]);
        }
        
        
      }
     });
     
     

  
  runApp( MaterialApp(
    title: "Soundboard App",
    initialRoute: "/",
    routes: {
      "/": (context) => const MyApp(),
      "/second": (context) => const ButtonMaker(),
    },
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}
var player= AudioPlayer();
List idk=[];



Future<String?>   getId() async {
  var deviceInfo = DeviceInfoPlugin();
  if(Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId; 
  }
}
bool isPlaying=false;




Widget sound(String text,String url){
  
  return ElevatedButton(onPressed: (() {
    if (isPlaying==true) {
      player.stop();
      isPlaying=false;
    }
    else{ 
     
     player.play(UrlSource(url));
      isPlaying=true;
    }
    }
    ), child: Text(text));
}



class _MyAppState extends State<MyApp>{
  
  bool refresh=false;

  void refreshScreen() {
      refresh=true;
    
  }
  
  @override
  Widget build(BuildContext context) {
    if (buttons.isNotEmpty){
      setState(() {
        refresh=true;
      });
        
      }
      print(refresh);
    return Scaffold(
      
        appBar: AppBar(
            title: Text("Soundboard"),
            centerTitle: true,
        ),
        
        body:refresh?
        GridView.count(
          crossAxisCount: 4,
          children:  List.generate(buttons.length, (index)  { 
            
            return buttons.elementAt(index);
          })
        )
          :const Center(child:Text("Press the plus icon to add a sound"),),
          
        floatingActionButton: Row( children:[
          SizedBox(width: 30),
          FloatingActionButton(onPressed: () async {
            setState(() {
              refresh=false;
            });
            if (buttons.isNotEmpty & buttondata.isNotEmpty){
            bool thing=await Navigator.push(context, MaterialPageRoute(builder: (context)=> const ButtonDeleter()));
            if (thing==true) {
             setState(() {
               
               refresh=thing;
             });
           }
            }
          },child: const Icon(Icons.delete)),
          SizedBox(width: 269),
        FloatingActionButton(
        onPressed: () async{
          setState(() {
              refresh=false;
            });
           bool thing= await Navigator.push(context, MaterialPageRoute(builder: (context)=> const ButtonMaker()));
           if (thing==true) {
             //refreshScreen();
             setState(() {
               
               refresh=thing;
             });
           }
        },
        child: const Icon(Icons.add),
      ), 
        ]));
  }
}

class ButtonMaker extends StatefulWidget {
  const ButtonMaker({super.key});

  @override
  State<ButtonMaker> createState() => _ButtonMakerState();
}

class _ButtonMakerState extends State<ButtonMaker> {
  final recorder= FlutterSoundRecorder();
  String textvalue="";
  String audiofilename="";
  IconData icon=Icons.mic;
  var audiopath;
  Future<String> uploadFile(String buttonnamed) async{
    final path="files/$buttonnamed";
    final file=audiopath;

    final reference=FirebaseStorage.instance.ref().child(path);
    var uploadtask=reference.putFile(file);

    final snapshot=await uploadtask.whenComplete(() {});

    String audiourl=await snapshot.ref.getDownloadURL();
    return audiourl;
  }
  void changeicon(){
    if (icon==Icons.mic){
    setState(() {
     icon=Icons.stop; 
    });
    }
    else{
      setState(() {
     icon=Icons.mic; 
    });
    }
    }
  
       bool recorderReady=false;
         Future initRecorder() async {
          final permission= await Permission.microphone.request(); 
         

          if (permission!=PermissionStatus.granted){
            throw "Accept the permission, I won't take your data.";
          }
          await recorder.openRecorder();
          recorderReady=true;
        }
         @override
         void initState(){
           super.initState();

           initRecorder();
         }

         @override
         void dispose(){
           recorder.closeRecorder();

           super.dispose();
         }
        
         Future record() async{
           if (!recorderReady) return;
           await recorder.startRecorder(toFile: "audio");
         }
         Future stop() async{
            if (!recorderReady) return;
            final path= await recorder.stopRecorder();
            audiopath=File(path!);
            print(audiopath);
           await recorder.stopRecorder();
         }

    @override
    Widget build(BuildContext context) {
      String buttonname="";
      return Scaffold(
          appBar: AppBar(
            title: Text("Make Sounds"),
            centerTitle: true,
          ),
          resizeToAvoidBottomInset: false,
          body: 
          Center(
            child:
          Column(
            children:[ SizedBox(height: 100),
            TextField(
              onChanged: (value) {
                
                  textvalue=value;
                
                print(buttonname);
              }, 
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter New Button's Name",
              ),
            ),
            SizedBox(height: 100),
            FloatingActionButton.large(onPressed: () async{
              changeicon();
              if (recorder.isRecording==true){
                await stop();
                }
                else{
                  
                  await record();
                }

            }, child: Icon(icon),),
          SizedBox(height: 100),
        ElevatedButton(onPressed: (() async {
          //Firebase.initializeApp();
          
          
          buttonname=textvalue;
          
          print(buttonname);
          print(buttons);
          
          String url=await uploadFile(buttonname);

          print(url);
          buttons.add(sound(buttonname,url)); 
          buttondata.add({"name":buttonname,"file":url});
          
          String? deviceId = await getId();
          await DatabaseService(uid: deviceId.toString()).updateUserData(buttondata);
          Navigator.pop(context,true); 
          
        }),style:ElevatedButton.styleFrom(minimumSize: Size(150 , 50)),child: Text("Make New Button"),)]
        
      ),
        ),
    );
  }
}
class ButtonDeleter extends StatefulWidget {
  const ButtonDeleter({super.key});

  @override
  State<ButtonDeleter> createState() => _ButtonDeleterState();
}

class _ButtonDeleterState extends State<ButtonDeleter> {
  @override
  List <Widget>buttondeletion=<Widget>[];
    
  List<bool> selectedButtons= [];
   bool vertical = false;
  Widget build(BuildContext context) {
    if (buttondeletion.length<buttons.length){
    for (var button in buttons) {
    selectedButtons.add(false);
  }
  
  for (var i=0; i<buttondata.length; i++){
     buttondeletion.add(Text(buttondata[i]["name"]));
    }
    print(buttondeletion);
  }
    return Scaffold(
      appBar: AppBar(
            title: Text("Delete Buttons"),
            centerTitle: true,
          ),
      body: 
            Center(
              child:Column(
                children:[SizedBox(height: 300,)
                ,ToggleButtons(direction: vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  // All buttons are selectable.
                  setState(() {
                    selectedButtons[index] = !selectedButtons[index];
                  });
                },isSelected: selectedButtons,
                children: buttondeletion,),
                SizedBox(height: 100,),
                ElevatedButton(onPressed: () async {
                  for (var i=0; i<selectedButtons.length; i++){
                    if(selectedButtons[i]==true){
                      var path=buttondata[i]["name"];
                      final ref= FirebaseStorage.instance.ref().child("files/$path");
                      await ref.delete();
                      String? deviceId = await getId();
                      
                        final database=FirebaseFirestore.instance.collection("Audio").doc(deviceId.toString());
                       
                      database.update({
                        
                        "buttons": FieldValue.arrayRemove([buttondata[i]])
                      });
                      setState(() {
                      buttondeletion=[];
                      selectedButtons=[];
                      buttons.removeAt(i);
                      buttondata.removeAt(i);
                    });
                  }
                }
                Navigator.pop(context,true);
                }, child: Text("Delete Selected Buttons"))
                ]
              ),
            ),
    );
  }
}