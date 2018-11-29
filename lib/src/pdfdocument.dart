import 'package:flutter/material.dart';
import 'pdftextstyle.dart';

/// Enum used to specify the alignment of the page nubering
enum PDFPageNumberAlignment {
  left, 
  right,
  center
}

/// This is the abstract class that defines the interface for our ReportDocument
/// and the interface exposed through the PDFReporter.createReport() method
abstract class PDFReportDocument {
  PDFTextStyle textStyle;

  asBytes();
  newPage();
  setFontColor(Color color);
  setDefaultFontColor();
  setPageHeader(text, {Map style});
  setPageNumbering(bool active, {String prefix, double size, PDFPageNumberAlignment alignment});
  newline({int number: 1});
  paragraph();
  addText(String text, {bool paragraph: true, Map style});
  addColumnText(List<String> text,
      {List<int> flex,
      int spaceMultiplier: 4,
      bool paragraph: true,
      Map style});
}
