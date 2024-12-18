import 'package:flutter/material.dart';
import 'dart:io';

Widget getImage(String? path) {

  if (path == null) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
          image: const DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage("assets/images/default.png"),
          ),
          border: Border.all(
              color: Colors.black,
              width: 5
          )
      ),
    );
  }
  else {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: Image.file(File(path)).image,
          ),
          border: Border.all(
              color: Colors.black,
              width: 2
          )
      ),
    );
  }
}