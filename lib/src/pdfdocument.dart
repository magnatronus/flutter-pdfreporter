import 'package:flutter/material.dart';
import 'pdftextstyle.dart';

/// This is the abstract class that defines the interface for our ReportDocument
/// and the interface exposed through the PDFReporter.createReport() method
abstract class PDFReportDocument {
  PDFTextStyle textStyle;

  asBytes();
  newPage();
  setFontColor(Color color);
  setDefaultFontColor();
  setPageHeader(text, {Map style});
  newline({int number: 1});
  paragraph();
  addText(String text, {bool paragraph: true, Map style});
  addColumnText(List<String> text,
      {List<int> flex,
      int spaceMultiplier: 4,
      bool paragraph: true,
      Map style});
}
