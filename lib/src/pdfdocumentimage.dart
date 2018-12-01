import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

class PDFDocumentImage {
  
    int width;
    int height;
    Uint8List image;
    Image _img;

    PDFDocumentImage.loadAssetImage(String name){
      _img = Image.asset(name);
    }

    ///  Load our image
    load(){
      Completer completer = Completer();
      _img.image
        .resolve(ImageConfiguration())
        .addListener((ImageInfo info, bool _) =>completer.complete(info.image));
      return completer.future;      
    }

  /// Load an image from an asset
  loadAssetAImage(String name) async {
    Image img = Image.asset(name);
    img.image.resolve(ImageConfiguration()).addListener((ImageInfo info, bool _) async {
      height = info.image.height;
      width = info.image.width;
      ByteData bd = await info.image.toByteData(format: ImageByteFormat.rawRgba);
      image = bd.buffer.asUint8List();
    });
  }


  /// Load an image from a network location
  loadNetworkAImage(String url) async {
    Image img = Image.network(url);
    img.image.resolve(ImageConfiguration()).addListener((ImageInfo info, bool _) async {
      height = info.image.height;
      width = info.image.width;
      ByteData bd = await info.image.toByteData(format: ImageByteFormat.rawRgba);
      image = bd.buffer.asUint8List();
    });
  }

}