import 'dart:io';

import 'package:flutter/material.dart';

Widget getImage(String? path) {
  if (path == null) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
          image: const DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage("assets/images/defaultAdd.png"),
          ),
          border: Border.all(color: Colors.black, width: 1)),
    );
  } else {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: Image.file(File(path)).image,
          ),
          border: Border.all(color: Colors.black, width: 1)),
    );
  }
}
