
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:path_provider/path_provider.dart';

import 'package:video_player/video_player.dart';

import 'colors.dart';

class Editor extends StatefulWidget {
  VideoPlayerController video;
  String filepath;
  Editor(this.video,this.filepath);
  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  static const platform = const MethodChannel('samples.flutter.dev/gifmaker');

  final _flutterVideoCompress = FlutterVideoCompress();

  RangeValues _value;

  @override
  void initState() {
    _value=RangeValues(widget.video.value.duration.inSeconds.toDouble()/2,
        widget.video.value.duration.inSeconds.toDouble()/2+widget.video.value.duration.inSeconds.toDouble()/3);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: black,
        title: Text("Create gif",
        style: TextStyle(
          color: white,
          letterSpacing: 2,
          fontWeight: FontWeight.w400,
          fontSize: 20
        ),
        ),
      ),
      body: Container(
        child: ListView(

          children: <Widget>[
            Container(
              height: (MediaQuery.of(context).size.height*3)/4,
              child: AspectRatio(
                aspectRatio: widget.video.value.aspectRatio,
                child: VideoPlayer(widget.video),
              ),
            ),
            Container(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: IconButton(
                      icon: Icon(widget.video.value.isPlaying?Icons.pause:Icons.play_arrow,color: grey,size: 30),
                      onPressed: (){
                        setState(() {
                          widget.video.value.isPlaying?widget.video.pause():widget.video.play();
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20),

                    child: IconButton(
                      icon: Icon(Icons.save,color: grey,size: 30,),
                      onPressed: (){
                        _generategif(_value, widget.filepath);
                      },
                    ),
                  ),
                ],
              )
            ) ,
            Container(
              margin: EdgeInsets.only(right: 20,left: 20),
              child: RangeSlider(
                activeColor: lime,
                inactiveColor: grey,
                values: _value,
                min: 0.0,
                max: widget.video.value.duration.inSeconds.toDouble(),
                onChanged: (b){
                  setState(() {
                    widget.video.seekTo(Duration(seconds: b.start.toInt()));
                    _value=b;
                  });
                },
                onChangeEnd: (ab){
                  setState(() {
                    widget.video.seekTo(Duration(seconds: ab.start.toInt()));
                    _value=ab;
                  });
                },
                onChangeStart: (a){
                  setState(() {
                    widget.video.seekTo(Duration(seconds: a.start.toInt()));
                    _value=a;
                  });
                },
                labels: RangeLabels(_value.start.toStringAsFixed(2),_value.end.toStringAsFixed(2)),
                divisions: 100,
              ),
            )
          ],
        )
      ),
    );
  }
  @override
  void dispose() {
    widget.video.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _generategif(RangeValues value,String filepath) async {
if(value.end-value.start<1.00){
  platform.invokeMethod('toastforlowvalue');
  return;
}
    widget.video.pause();
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

    final file = await _flutterVideoCompress.convertVideoToGif(
      filepath,
      startTime: value.start.toInt(),
      endTime: value.end.toInt(),
    );
    String time=DateTime.now().millisecondsSinceEpoch.toString();
    var appDocDir = await getExternalStorageDirectory();
    var folderPath = appDocDir.path + "/GifMaker";
    await new Directory(folderPath).create(recursive: true);
    file.copy("$folderPath/$time.gif");
platform.invokeMethod('toast').then((value){
  Navigator.pop(context);
  Navigator.pop(context);
});

  }

}
