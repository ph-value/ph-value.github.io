import 'package:flutter/material.dart';

class AppShadows {
  static const List<BoxShadow> customBaseBoxShadow = [
    BoxShadow(
      color: Colors.black,
      offset: Offset(3.0, 3.0),
      blurRadius: 0,
    ),
  ];

  static const List<BoxShadow> customHoverBoxShadow = [
    BoxShadow(
      color: Colors.black,
      offset: Offset(5.0, 5.0),
      blurRadius: 0,
    ),
  ];
}



