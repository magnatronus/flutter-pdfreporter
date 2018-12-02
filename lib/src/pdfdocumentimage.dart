import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

/// Class that encapsulated an image for PDF printing that can be added either from an embedded asset
/// or loaded from the network, using a URL
class PDFDocumentImage {
  int width;
  int height;
  Uint8List image;
  Image _img;

  /// Load an embedded asset image [name]
  PDFDocumentImage.loadAssetImage(String name) {
    _img = Image.asset(name);
  }

  /// Load a remote network image [url]
  PDFDocumentImage.loadNetworkImage(String url) {
    _img = Image.network(url);
  }

  ///  Actually Load the image resource which will return when the load is complete
  load() {
    Completer completer = Completer();
    _img.image.resolve(ImageConfiguration()).addListener(
        (ImageInfo info, bool _) => completer.complete(info.image));
    return completer.future;
  }
}
