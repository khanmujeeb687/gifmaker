import 'package:flutter/material.dart';
import 'package:gifmaker/ui/preloader.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "GifMaker",
      home: Preloader(),
    )
  );
}
