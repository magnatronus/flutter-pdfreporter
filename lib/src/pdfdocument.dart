import 'package:flutter/material.dart';
import 'pdftextstyle.dart';
import 'pdfdocumentimage.dart';

/// Enum used to specify the alignment of the page nubering
enum PDFPageNumberAlignment { left, right, center }

/// This is the abstract class that defines the interface for our ReportDocument
/// and the  functionality available through the PDFReporter.createReport() method
abstract class PDFReportDocument {
  PDFTextStyle textStyle;

  /// Add an [image] to the current page.
  /// The position [x] and [y] are in MM from the Document Origin (0,0) and denotes the top, left corner of the image.
  /// This takes the defined margin into account e.g. if the margins were all set to 10mm the Document Origin(0,0)
  /// would be 10mm from the left and 10mm from the top. This way any x,y position always starts within the page margins
  /// [width] and [height] are also in MM  where 0, 1 or both can be specified - if only 1 is selected the other is
  /// calculated from the original aspect ratio of the image. If none are specified the pixel height and width of the original
  /// is mapped as 1 pixel = 1 MM
  ///
  /// [image] is a [PDFDocumentImage]  which can load a network image or an asset image
  /// NB: This method returns a [Future] some you MUST await the result of addImage()
  addImage(PDFDocumentImage image,
      {double x, double y, double width, double height});

  /// Return a copy of the current PDF documents as an byte array
  /// this data can be saved as a pdf file
  asBytes();

  /// Add a new page to the current document
  newPage();

  /// Sets the document current font color to [color]
  /// This color will then be used until chnaged again or reset by [setDefaultFontColor]
  setFontColor(Color color);

  /// Revert the document currentFontColor to the default
  setDefaultFontColor();

  /// Set a simple [text] page header that will be automatically added as the first line everytime a new page is generated
  /// This will use  'title' style by default unless overriddeny by [style]
  setPageHeader(text, {Map style});

  /// Turn page numbering on and off with [active] - this will always default to false
  /// The optional [prefix] is added to the page number as prefix text, for example
  /// instead of just 1 of 3, it can be set up as 'page 1 of 3' - just set the prefix to 'page'
  /// Page numbers will be printed in the normal font (as defined by the current document textstyle)
  /// but by using [size] the font size can altered from the preset size
  /// by default the page number will be left aligned but this ca be chnaged by setting [alignment]
  setPageNumbering(bool active,
      {String prefix, double size, PDFPageNumberAlignment alignment});

  /// Helper function to insert a newline space into the document
  /// if [number] is specified then that number of linespaces will be added rather than the default of 1
  newline({int number: 1});

  /// Add the specified [text] to the current page
  /// [paragraph] can be turned on and off , if set it will add a newline BEFORE any text is printed and if false by default
  /// [style] cn be used to specify the style of the text being added - this will default to 'normal'
  addText(String text,
      {bool paragraph: true, Map style, Color backgroundColor});

  /// This will do a print within the confines of a a left and right bound (a column)
  /// The effect of this is to print a restricted column of text on a SINGLE line only
  /// if the specfied text is longer that the column defined then the text will be truncated
  /// [text] is an array of strings, 1 element for each column
  /// [flex] is an array of int's defining the flex value for each column
  /// [spaceMultiplier]  is an int used to specify the width of the gap between each column
  ///
  /// Please note the number of elements in [flex] MUST match the column elements defined in [text]
  addColumnText(List<String> text,
      {List<int> flex,
      int spaceMultiplier: 4,
      bool paragraph: true,
      Map style});
}
