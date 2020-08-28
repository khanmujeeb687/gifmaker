import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'colors.dart';

class Filecard extends StatefulWidget {
  Function callback;
  File file;
  Filecard(this.file,this.callback);
  @override
  _FilecardState createState() => _FilecardState();
}

class _FilecardState extends State<Filecard> {

  CustomPopupMenu choice;
bool show;
  List<CustomPopupMenu> choices;
  @override
  void initState() {
    show= true;
    choices = <CustomPopupMenu>[
      CustomPopupMenu(title: 'Delete', icon: Icons.delete,onclick:(){
        widget.file.delete();
        widget.callback();
      }),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return show?Card(
      elevation: 15,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: (){
              OpenFile.open(widget.file.path);
            },
            child: Container(
              width: 500,
              height: 500,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(widget.file,fit: BoxFit.cover,)),
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            child:PopupMenuButton<CustomPopupMenu>(
              icon: Icon(Icons.more_vert,color: white,),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
              ),
              elevation: 10,
              onSelected: (choice){
                choice.onclick();
              },
              itemBuilder: (BuildContext context) {
                return choices.map((CustomPopupMenu choice) {
                  return PopupMenuItem<CustomPopupMenu>(
                    value: choice,
                    child:Row(
                      mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Icon(choice.icon),
                        Text(choice.title)
                      ],
                    ),
                  );
                }).toList();
              },
            )
          )
        ],
      ),

    ):Container();
  }

}

class CustomPopupMenu {
  CustomPopupMenu({this.title, this.icon,this.onclick});
  String title;
  IconData icon;
  VoidCallback onclick;
}