import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'pdfdocument.dart';
import 'pdftextstyle.dart';
import 'pdfmargin.dart';
import 'pdfdocumentimage.dart';
import 'pdfdocumenttext.dart';

//import 'package:flutter/services.dart' show rootBundle;

/// This is our concrete class used to represent a PDF document
class ReportDocument implements PDFReportDocument {
  final PDFDocument document;
  PDFTextStyle textStyle;
  final PDFDocumentMargin margin;
  final PDFPageFormat paper;
  final Color defaultFontColor;
  bool pageNumberingActive = false;
  Color currentFontColor;
  PDFPage currentPage;
  _Cursor cursor;
  Map header;
  Map pageNumberInfo;

  ReportDocument({@required this.document,@required this.paper, @required this.textStyle,@required this.margin,@required this.defaultFontColor}) {
    cursor = _Cursor(paper.dimension.h, paper.dimension.w);
    cursor.margin = margin;
    currentFontColor = defaultFontColor;
    PDFDocumentText textInfo = PDFDocumentText("Pg", textStyle.normal['font'], textStyle.normal['size']); 
    cursor.lineSpacing = textInfo.cursory;
    print(cursor.lineSpacing);
  }

  addImage(PDFDocumentImage image,
      {double x, double y, double width, double height}) async {
    if (currentPage == null) {
      throw Exception(
          "The current document has no pages. To add one use the  newPage() method.");
    }

    var result = await image.load();
    //print(result.height);
    //print(result.width);

    // calc WxH aspect ratio
    double aspectRatio = (result.height / result.width);

    // if no width and no height use pixels
    if (height == null && width == null) {
      height = result.height * 1.0;
      width = result.width * 1.0;
    }

    // adjust height or width as required
    width = (width == null) ? (height / aspectRatio) : width;
    height = (height == null) ? (width * aspectRatio) : height;

    // Extract the image data
    ByteData bd = await result.toByteData(format: ImageByteFormat.rawRgba);
    PDFImage pdfimage = PDFImage(document,
        image: bd.buffer.asUint8List(),
        width: result.width,
        height: result.height);

    // Add image to current page
    currentPage.getGraphics().drawImage(pdfimage, cursor.x + x,
        (cursor.paperHeight - cursor.margin.top) - (y + height), width, height);
  }

  newline({int number: 1}) {
    for (int i = 0; i < number; i++) {
      cursor.newLine();
    }
  }

  setPageNumbering(bool active,
      {String prefix, double size, PDFPageNumberAlignment alignment}) {
    pageNumberingActive = active ?? false;
    cursor.pageNumberHeight = size ?? textStyle.normal['size'];
    pageNumberInfo = {
      "alignment": alignment ?? PDFPageNumberAlignment.center,
      "prefix": prefix,
      "size": cursor.pageNumberHeight
    };
  }

  setPageHeader(text, {Map style}) {
    style = style ?? textStyle.title;
    header = {"text": text, "style": style};
  }

  asBytes() {
    // if pageNumbering is active then loop through each page and add a page number
    if (pageNumberingActive) {
      int pageTotal = document.pdfPageList.pages.length;
      for (int i = 0; i < pageTotal; i++) {
        addPageNumber(document.pdfPageList.pages[i], (i + 1), pageTotal);
      }
    }

    // return the document as a byteArray
    return document.save();
  }

  newPage() {
    currentPage = PDFPage(document, pageFormat: paper);
    cursor.reset();
    if (header != null) {
      printHeader();
    }
  }

  setDefaultFontColor() {
    currentFontColor = defaultFontColor;
  }

  setFontColor(Color color) {
    currentFontColor = color;
  }

  addText(String text,
      {bool paragraph: false, Map style, Color backgroundColor}) {
    // if no currentPage throw an exception
    if (currentPage == null) {
      throw Exception(
          "The current document has no pages. To add one use the  newPage() method.");
    }

    // if no style specified default to normal
    style = style ?? textStyle.normal;

    // set the font to use
    PDFTTFFont textFont = style['font'];

    // add a paragraph space if required
    if (paragraph) {
      cursor.newLine();
    }

    //  calculate the word split for each line and add the lines
    List words = text.split(" ");
    String line = "";
    words.forEach((w) {
      if (line.length < 1) {
        line = w;
      } else {
        PDFDocumentText textInfo = PDFDocumentText((line + "$w"), textFont, style['size']);       
        if (textInfo.lineWidth > cursor.printWidth) {
          printLine(PDFDocumentText(line, textFont, style['size']), backgroundColor);
          line = w;
        } else {
          line += ' $w';
        }
      }
    });

    // add any text that is left then a newline
    if (line.length > 0) {
      printLine(PDFDocumentText(line, textFont, style['size']), backgroundColor);
      //cursor.newLine();
    }
  }

  addColumnText(List<String> text,
      {List<int> flex,
      int spaceMultiplier: 4,
      bool paragraph: true,
      Map style}) {
    // check if Text Supplied and Flex values match
    if (text.length != flex.length) {
      throw Exception(
          "The supplied flex element count does NOT match the column count defined by the text string array");
    }

    // add a paragraph space
    if (paragraph) {
      cursor.newLine();
    }

    // if no style specified default to normal
    style = style ?? textStyle.normal;

    // set the font to use
    PDFTTFFont textFont = style['font'];

    // calculate the column spacing
    List spacings =
        calculateColumnSizes(flex, spaceMultiplier: spaceMultiplier);

    // as a single line we only need the height
    var lb = textFont.stringBounds("D");
    double lineHeight = (lb.h - lb.y) * style['size'];

    // now generate the line from our column data
    for (int col = 0; col < text.length; col++) {
      var column = spacings[col];

      List words = text[col].split(" ");
      String line = "";
      words.forEach((w) {
        //print(line);
        if (line.length < 1) {
          line = w;
        } else {
          var lb = textFont.stringBounds(line + " $w");
          double lw = (lb.w * style['size']) + lb.x;
          if (lw < column['width']) {
            line += ' $w';
          }
        }
      });

      // now print the text
      if (line.length > 0) {
        // check if line will print on the page - if not create a new page
        if ((cursor.y - lineHeight) < cursor.maxy) {
          newPage();
        }

        // now print it
        positionPrint(line, column['start'], cursor.y, lineHeight, textFont,
            style['size']);
      }
    }

    // now move the line down
    cursor.move(0, lineHeight);
  }

  /* ************************************************** */
  /* all function below here are NOT exposed publically */
  /* i.e. they are NOT part of the abstract class       */
  /* ************************************************** */

  /// Add a page number into the specified [page]
  addPageNumber(PDFPage page, int pageNumber, int totalPages) {
    String pageText = "$pageNumber of $totalPages";
    if (pageNumberInfo['prefix'] != null) {
      pageText = "${pageNumberInfo['prefix']} $pageNumber of $totalPages";
    }

    // now calculate space required for page numbering text
    double size = pageNumberInfo['size'];
    var bounds = textStyle.normal['font'].stringBounds(pageText);
    double x = cursor.margin.left;
    double y = cursor.margin.bottom;

    // right justify the page number
    if (pageNumberInfo['alignment'] == PDFPageNumberAlignment.right) {
      x = cursor.maxx - (bounds.w * size);
    }

    // if center justify
    if (pageNumberInfo['alignment'] == PDFPageNumberAlignment.center) {
      double midway = cursor.paperWidth / 2;
      x = midway - ((bounds.w * size) / 2);
    }

    // add the page nummbering to the page
    page
        .getGraphics()
        .drawString(textStyle.normal['font'], size, pageText, x, y);
  }

  /// This will calculate the start and stop positions for the specified columns
  /// taking account of a blank space equal to the current [lineSpacng] multiplied by the specified [spaceWidth]
  calculateColumnSizes(List<int> flex, {int spaceMultiplier: 4}) {
    // Create a clone cursor for internal use
    _Cursor tc = cursor.clone();
    tc.reset();

    // calculate the column split
    int totalColumnsRequired = 0;
    flex.forEach((f) {
      totalColumnsRequired += f;
    });

    // remove space from overall available line width and calculate remaining line width then the columnUnit width
    double spaceWidth = (tc.lineSpacing * spaceMultiplier);
    double columnUnitWidth =
        (tc.printWidth - (spaceWidth * (flex.length - 1))) /
            totalColumnsRequired;

    // now seed the start and stop positions for each column
    List columns = List();
    flex.forEach((f) {
      double start = tc.x;
      double width = (f * columnUnitWidth);
      columns.add({"start": start, "width": width});
      tc.move((width + spaceWidth), 0.0);
    });

    /*
    // test calcs by printing some rects
    currentPage.getGraphics().setColor(new PDFColor(0.0, 1.0, 1.0));
    columns.forEach((c){
      currentPage.getGraphics().drawRect(c['start'], (tc.y - 20.0), c['width'], 20.0);
      currentPage.getGraphics().strokePath();
    });
    */

    return columns;
  }

  /// Add a header to the page
  printHeader() {
    addText(header['text'], style: header['style']);
    cursor.newLine();
  }

  /// This will print out the specfied [text] at the specified position
  /// [start] is the x coord to start the print from
  /// [y] is the starting y position
  /// [yshim] is the height of the printed font
  /// [font] and [size] specific the font to use and the size it should be
  positionPrint(text, start, y, yshim, font, size) {
    // Make sure we used the correct color
    currentPage
        .getGraphics()
        .setColor(PDFColor.fromInt(currentFontColor.value));

    // add line to page
    currentPage.getGraphics().drawString(font, size, text, start, (y - yshim));
  }

  /// This will print out the string specified in [line] using the current cursor position
  /// and the [font] and [size] specified
  /// If the line will not fit on the page it will first create a new page
  printLine(PDFDocumentText text, backgroundColor) {

     //print("------------------------------------------------------------------------------------");
     //cursor.printBounds();
     //text.printBounds();

    // check if line will print on the page - if not create a new page
    if ((cursor.y - text.lineHeight) < cursor.maxy) {
      newPage();
    }

    // move cursor ready for text print
    cursor.move(0.0, text.cursory);

    // draw a box around the text
    if(backgroundColor != null){
      currentPage.getGraphics().setColor(PDFColor.fromInt(backgroundColor.value));
      currentPage.getGraphics().drawRect(cursor.x, cursor.y, cursor.printWidth, text.cursory);
      currentPage.getGraphics().fillPath(); 
    }

    // Set the text color
    currentPage
        .getGraphics()
        .setColor(PDFColor.fromInt(currentFontColor.value));


    // print text to page
    currentPage.getGraphics().drawString(text.font, text.size, text.text, (cursor.x + text.padding), ( cursor.y  + text.padding - text.gutter));

  }
}

/// Define a cursor to keep track of the current print position
class _Cursor {

  // Current height and width of paper
  final double paperHeight;
  final double paperWidth;

  // current/last cursor position
  double x;
  double y;

  /// max values for cursor within margins
  double maxx;
  double maxy;

  /// The available printable width and height inside the margins
  double printWidth;
  double printHeight;

  /// Default newline value
  double lineSpacing = (PDFPageFormat.mm);
  //double paragraphHeight;

  // The space to allow if we have set up page numbering
  double pageNumberHeight = 0.0;

  /// The margin set in the document being generated
  PDFDocumentMargin margin = PDFDocumentMargin();

  _Cursor(this.paperHeight, this.paperWidth):x = 0.0, y = paperHeight;

  /// debug print
  printBounds() {
    print("paperHeight: $paperHeight, paperWidth: $paperWidth, printHeight: $printHeight, printWidth: $printWidth");
    print("x: $x, y: $y, maxx: $maxx, maxy: $maxy");
  }

  /// Reset the cursor ready for a new page
  reset() {
    //paragraphHeight = 3 * lineSpacing;
    x = margin.left;
    y = paperHeight - margin.top;
    maxx = paperWidth - margin.right;
    maxy = (pageNumberHeight == 0)?margin.bottom: (margin.bottom + pageNumberHeight + lineSpacing);
    printWidth = paperWidth - (margin.right + margin.left);
    printHeight = paperHeight - (margin.top + margin.bottom);
  }

  // Add a new line space
  newLine() {
    y -= lineSpacing;
  }

  /// add a paragraph space 
  //newParagraph() {
  //  y -= paragraphHeight;
  //}

  // Move the cursor relative to the current position
  move(double mx, double my) {
    x += mx;
    y -= my;
    //y -= lineSpacing;
  }

  // This will create a new version of the current cursor
  clone() {
    _Cursor clone = _Cursor(paperHeight, paperWidth);
    clone.margin = margin;
    clone.reset();
    clone.x = x;
    clone.y = y;
    return clone;
  }
}
