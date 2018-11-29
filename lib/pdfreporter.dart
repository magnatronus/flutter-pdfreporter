// Copyright (c) 2018, Steve Rogers. All rights reserved. Use of this source code
// is governed by an Apache License 2.0 that can be found in the LICENSE file.
library pdfreporter;

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'src/reportdocument.dart';
import 'src/pdftextstyle.dart';
import 'src/pdfmargin.dart';

export 'src/pdfdocument.dart';
export 'src/pdftextstyle.dart';

/// This is the main class used to create and generate a complete PDF document which wraps and
///  uses the excellent https://github.com/DavBfr/dart_pdf/tree/master/pdf project for all the actual PDF functionality
class PDFReporter {
  static createReport(
      {PDFTextStyle textStyle,
      PDFDocumentMargin margin,
      Color defaultFontColor}) async {
    //TODO:: Find a way of doing this in the create
    PDFPageFormat paper = PDFPageFormat.a4;

    // Make sure our params are loaded and defaulted
    PDFDocument document = PDFDocument(deflate: zlib.encode);
    textStyle = textStyle ?? await _createDefaultTextStyle(document);
    margin = margin ?? PDFDocumentMargin();
    defaultFontColor = defaultFontColor ?? Colors.black;

    /// Create the report and return it
    return ReportDocument(
      document: document,
      paper: paper,
      textStyle: textStyle,
      defaultFontColor: defaultFontColor,
      margin: margin,
    );
  }

  /// Add the loaded fonts to out default PDFTextStyle
  static _createDefaultTextStyle(document) async {
    PDFTextStyle defaultStyle = PDFTextStyle();
    ByteData standardFont = await rootBundle
        .load("packages/pdfreporter/fonts/OpenSans-Regular.ttf");
    ByteData semiBoldFont = await rootBundle
        .load("packages/pdfreporter/fonts/OpenSans-SemiBold.ttf");
    ByteData boldFont =
        await rootBundle.load("packages/pdfreporter/fonts/OpenSans-Bold.ttf");
    defaultStyle.normal['font'] = PDFTTFFont(document, standardFont);
    defaultStyle.heading3['font'] = PDFTTFFont(document, semiBoldFont);
    defaultStyle.heading2['font'] = PDFTTFFont(document, boldFont);
    defaultStyle.heading1['font'] = PDFTTFFont(document, boldFont);
    defaultStyle.title['font'] = PDFTTFFont(document, boldFont);
    return defaultStyle;
  }
}
