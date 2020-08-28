import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gifmaker/ui/colors.dart';
import 'package:gifmaker/ui/filecard.dart';
import 'package:gifmaker/ui/editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class Preloader extends StatefulWidget {
  @override
  _PreloaderState createState() => _PreloaderState();
}

class _PreloaderState extends State<Preloader> {
  static const platform = const MethodChannel('samples.flutter.dev/gifmaker');
bool show;
  VideoPlayerController _controller;
  File _file;

  List<File> allfiles=[];
  @override
  void initState() {
    show=false;
    _getallfiles();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        decoration: BoxDecoration(
          color: grey.withOpacity(0.5)
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 6,sigmaX: 6),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[

                Container(
                  height: MediaQuery.of(context).size.height*.25,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        child: Icon(Icons.add_circle_outline,color: grey,size: 100,),
                    onTap: _pickafile,
                    ),
                  ),
                ),
               show?Container(
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))
                  ),
                  padding: EdgeInsets.only(top: 20),
                  height: MediaQuery.of(context).size.height*.7,
                  child:GridView.count(
                    crossAxisCount: 2,
                  children: List.generate(allfiles.length,
                      (index){
                    return Filecard(allfiles[index],this.callback);
                      }
                  ),
                  )
                ):Container(),
              ],
            ),

          ),
        ),
      )
    );
  }


_getallfiles()async{

  var appDocDir = await getExternalStorageDirectory();
  var folderPath = appDocDir.path + "/GifMaker";
  final dir = Directory(folderPath);
  if(dir.existsSync()){
   var files = dir.listSync().toList();
   if(files.isEmpty){
     setState(() {
       show=false;
       return;
     });
   }
   allfiles.clear();
   files.forEach((e){
   setState(() {
     show=true;
     allfiles.add(e);
   });
   });

}
  }

_pickafile() async{
  String result = await platform.invokeMethod('StartSecondActivity');
  if(result!="success") return;
  _file= await FilePicker.getFile(type: FileType.video);
  if(_file!=null){
    showDialog(context: context,
        barrierDismissible: false,
        builder: (context){
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7,sigmaY: 7),
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              shape:RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)
              ) ,
              content:Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(backgroundColor: lime)),
            ),
          );
        }
    );
    _controller = VideoPlayerController.file(_file)
      ..initialize().then((_) {
        _controller.setLooping(true);
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute<String>(
                builder: (context){
                  return Editor(_controller,_file.path
                  );
                })
        ).then((value){
          _getallfiles();
        });
      });

  }
}
  void callback() {
    _getallfiles();
  }



}
