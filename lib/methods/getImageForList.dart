import 'dart:io';

import 'package:flutter/material.dart';

getImage(String? path) {
  return path == null
      ? const AssetImage("assets/images/default.png")
      : Image.file(File(path)).image;
}
