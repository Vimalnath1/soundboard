import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_audio_recorder3/flutter_audio_recorder3.dart';
import 'package:http/http.dart' as http;


void main(){
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
final player= AudioPlayer();
final storage = FirebaseStorage.instance.ref();
List buttons=[];


Widget sound(String text, String sound){
  bool isPlaying=false;
  return ElevatedButton(onPressed: (() {
    if (isPlaying==true) {
      player.stop();
      isPlaying=false;
    }
    else{
      player.play(AssetSource(sound));
      isPlaying=true;
    }
    }
    ), child: Text(text));
}

uploadFile(String title, String filepath,String buttonnamed) async{
  var request=http.MultipartRequest("POST",Uri.parse(filepath));

  request.fields["name"]=title;

  var buttonames=buttonnamed;
  var audio=http.MultipartFile.fromBytes("audio", (await rootBundle.load("assets/")).buffer.asUint8List(),filename: "$buttonames.mp3");

  request.files.add(audio);

  var response=await request.send();

  var responseData= await response.stream.toBytes();

  var result= String.fromCharCodes(responseData);

}
class _MyAppState extends State<MyApp>{
  bool refresh=false;

  void refreshScreen() {
    refresh=true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Soundboard"),
            centerTitle: true,
        ),
        body: refresh?
        GridView.count(
          crossAxisCount: 4,
          children:  List.generate(buttons.length, (index)  { 
            print("Wahoo");
            return buttons.elementAt(index);
          })
          ):Center(child:Text("Press the plus icon to add a sound"),),/*Center(
          child: Text(
            "$counter",
            style: TextStyle(
              fontSize: 30.0, 
            ),
            ),
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: (() {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context)=>Darn())
                );
            }), 
            child: Text("Next Page")),
            ElevatedButton(onPressed: () {
              
              player.play(AssetSource("ihateyou.mp3"));
              
            }, child: Text("Free Body Diagram")),
            ElevatedButton(onPressed: () {print("Whistle Sounds");}, child: Text("Whistle")),
           // ElevatedButton(onPressed: () {print("Why are you so needy?");}, child: Text("Neediness"))
          ]),*/
        floatingActionButton: FloatingActionButton(
        onPressed: () async{
           bool thing= await Navigator.push(context, MaterialPageRoute(builder: (context)=> const ButtonMaker()));
           if (thing==true) {
             //refreshScreen();
             setState(() {
               refresh=thing;
             });
           }
        },
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      );
  }
}

class ButtonMaker extends StatefulWidget {
  const ButtonMaker({super.key});

  @override
  State<ButtonMaker> createState() => _ButtonMakerState();
}

class _ButtonMakerState extends State<ButtonMaker> {
  //final recorder= FlutterSoundRecorder();
  String buttonname="";
  String audiofilename="";
  bool recorderReady=false;
 /*   Future initRecorder() async {
    final permission= await Permission.microphone.request(); 
    

    if (permission!=PermissionStatus.granted){
      throw "Accept the permission, I won't take your data.";
    }
    await recorder.openRecorder();
    recorderReady=true;
     recorder.setSubscriptionDuration(Duration(milliseconds: 500));
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
      final audiopath=await recorder.stopRecorder();
      final audiofile=File(audiopath!);
      print("Audio File: $audiofile");
      audiofilename=audiopath;
    }
        */
    @override
    Widget build(BuildContext context) {
      String buttonname="";
      return Scaffold(
          appBar: AppBar(
            title: Text("Make Sounds"),
            centerTitle: true,
          ),
          body:
          Center(
            child:
          Column(
            children:[ SizedBox(height: 100),
            TextField(
              onChanged: (value) {
                buttonname=value;
              }, 
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter New Button's Name",
              ),
            ),
            SizedBox(height: 100),
            FloatingActionButton.large(onPressed: () async{
              FlutterAudioRecorder3 recorder=FlutterAudioRecorder3("$buttonname.mp4");
              await recorder.initialized;
          /*
          if (recorder.isRecording==true){
            await stop();
          }
          else{
            await record();
          }
          */

       }, child: Icon(Icons.mic),),
          SizedBox(height: 100),
        ElevatedButton(onPressed: (() async {
          //buttonData(context);
          uploadFile(buttonname, audiofilename, buttonname);
          buttons.add(sound(buttonname,audiofilename));
          print(buttons);
          Navigator.pop(context,true);

        }),style:ElevatedButton.styleFrom(minimumSize: Size(150 , 50)),child: Text("Make New Button"),)]
        
      ),
        ),
    );
  }
}
  /*
  Future buttonData(BuildContext context) => showDialog(
    context: context,
     builder: (context) => AlertDialog(
       title: Text("New Button"),
       content: TextField(
         autofocus: true,
         decoration: InputDecoration(hintText: "Enter New Button's Name"),
         controller: controller,
       ),
       
       actions: [Center(child:FloatingActionButton(onPressed: () async {
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
           final audiopath=await recorder.startRecorder(toFile: "audio");
         }
         Future stop() async{
            if (!recorderReady) return;
           await recorder.stopRecorder();
         }
         if (recorder.isRecording==true){
           await stop();
         }
         else{
           await record();
         }
         

       },child: recorder.isRecording? const Icon(Icons.stop):const Icon(Icons.mic),)),TextButton(child: Text("Submit"),onPressed: () {Navigator.of(context).pop(controller.text);},)],
     ) 
  );
  }

class ButtonMaker extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Make Sounds"),
          centerTitle: true,
        ),
        body:
        Center(
          child:
        Column(
          children:[ SizedBox(height: 100),
        ElevatedButton(onPressed: (() {buttonData(context);}),child: Text("Press"),)]

      ),
        ),
    );
  }
  Future buttonData(BuildContext context) => showDialog(
    context: context,
     builder: (context) => AlertDialog(
       title: Text("New Button"),
       content: TextField(
         autofocus: true,
         decoration: InputDecoration(hintText: "Enter New Button's Name"),
         controller: controller,
       ),
       actions: [TextButton(child: Text("Submit"),onPressed: Navigator.of(context).pop,)],
     ) 
  );
}*/