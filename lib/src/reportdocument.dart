import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'pdfdocument.dart';
import 'pdftextstyle.dart';
import 'pdfmargin.dart';

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

  ReportDocument(
      {@required this.document,
      @required this.paper,
      @required this.textStyle,
      @required this.margin,
      @required this.defaultFontColor}) {
    cursor = _Cursor(paper.dimension.h, paper.dimension.w);
    cursor.margin = margin;
    currentFontColor = defaultFontColor;
  }

  /// Helper function to insert a newline space into the document
  /// if [number] is specified then that nuber of linepspaces will be added
  newline({int number: 1}) {
    for (int i = 0; i < number; i++) {
      cursor.newLine();
    }
  }

  /// Helper function to insret a paragrah space into the document
  paragraph() {
    cursor.newParagraph();
  }

  /// Turn page numbering on and off with [active] this will always default to false
  /// The optional [prefix] is added to the page number as prefix text, for example
  /// instead of just 1 of 3, it can be set up as page 1 of 3
  /// Page numbers will be printed in the normal font, but by using [size] the 
  /// font size can altered from the preset size
  setPageNumbering(bool active, {String prefix, double size,  PDFPageNumberAlignment alignment}){
    pageNumberingActive = active ?? false;
    cursor.pageNumberHeight = size ?? textStyle.normal['size'];  
    pageNumberInfo = {
      "alignment": alignment ?? PDFPageNumberAlignment.center,
      "prefix": prefix,
      "size": cursor.pageNumberHeight
    };
  }

  /// Set a simple text page header that will be automatically added as the first line everytime a new page is generated
  /// This will use  'title' style by default
  setPageHeader(text, {Map style}) {
    style = style ?? textStyle.title;
    header = {"text": text, "style": style};
  }

  /// Return a copy of the current PDF documents as an byte array
  asBytes() {

    // if pageNumbering is active then loop through each page and add a page number
    if(pageNumberingActive){
      int pageTotal = document.pdfPageList.pages.length;
      for(int i=0;i<pageTotal;i++){
        addPageNumber(document.pdfPageList.pages[i], (i+1), pageTotal);
      }
    }

    // return the document as a byteArray
    return document.save();

  }

  // Add a new page to the current document
  newPage() {
    currentPage = PDFPage(document, pageFormat: paper);
    cursor.reset();
    if (header != null) {
      printHeader();
    }
  }

  /// Revert the currentFontColor to the default
  setDefaultFontColor() {
    currentFontColor = defaultFontColor;
  }

  /// Set the current font color to [color]
  setFontColor(Color color) {
    currentFontColor = color;
  }

  /// Add the specified [text] to the current page
  /// [paragraph] can be turned on and off and is used to add space before the text is added
  /// [style] cn be used to specify the style of the text being added - this will default to 'normal
  addText(String text, {bool paragraph: true, Map style}) {
    // if no currentPage throw an exception
    if (currentPage == null) {
      throw Exception(
          "The current document has no pages. To add one use the  newPage() method.");
    }

    // if no style specified default to normal
    style = style ?? textStyle.normal;

    // set the font to use
    PDFTTFFont textFont = style['font'];

    // add a paragraph space
    if (paragraph) {
      cursor.newParagraph();
    }

    //  calulate the word split for each line and add the lines
    List words = text.split(" ");
    String line = "";
    words.forEach((w) {
      if (line.length < 1) {
        line = w;
      } else {
        var lb = textFont.stringBounds(line + " $w");
        double lw = (lb.w * style['size']) + lb.x;
        if (lw > cursor.printWidth) {
          printLine(line, textFont, style['size']);
          line = w;
        } else {
          line += ' $w';
        }
      }
    });

    // add any text that is left
    if (line.length > 0) {
      printLine(line, textFont, style['size']);
      cursor.newLine();
    }
  }

  /// This will do a print within the confines of a a left and right bound (a column)
  /// The effect of this is to print a restricted column of text on a SINGLE line only
  /// if the specfied text is longer that the column defined for it will be truncated
  /// [text] is an array of string , 1 element for each column
  /// [flex] is an array of int defining the flex value for each column
  /// [spaceMultiplier]  is an int used to speciy the width of the gap between each column
  ///
  /// Please note the number of elements in [flex] MUST match the column elements defined in [text]
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
      cursor.newParagraph();
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
  addPageNumber(PDFPage page, int pageNumber, int totalPages){
    String pageText = "$pageNumber of $totalPages";
    if(pageNumberInfo['prefix'] != null) {
      pageText = "${pageNumberInfo['prefix']} $pageNumber of $totalPages";
    }

    // now calculate space required for page numbering text
    double size = pageNumberInfo['size'];
    var bounds = textStyle.normal['font'].stringBounds(pageText);
    double x = cursor.margin.left;
    double y = cursor.margin.bottom;

    // right justify the page number
    if(pageNumberInfo['alignment'] == PDFPageNumberAlignment.right){
      x  = cursor.maxx - (bounds.w * size);
    }

    // if center justify
    if(pageNumberInfo['alignment'] == PDFPageNumberAlignment.center){
      double midway = cursor.paperWidth / 2;
      x  = midway - ((bounds.w * size)/2);
    }    

    // add the page nummbering to the page
    page.getGraphics().drawString(textStyle.normal['font'], size, pageText, x, y);
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
    cursor.newParagraph();
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
  printLine(line, font, size) {
    var lb = font.stringBounds(line);
    double yshim = (lb.h - lb.y) * size;

    // Make sure we used the correct color
    currentPage
        .getGraphics()
        .setColor(PDFColor.fromInt(currentFontColor.value));

    // check if line will print on the page - if not create a new page
    if ((cursor.y - yshim) < cursor.maxy) {
      newPage();
    }

    // add line to page
    cursor.move(0.0, yshim);
    currentPage.getGraphics().drawString(font, size, line, cursor.x, cursor.y);
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

  /// The spacing between each printed line
  double lineSpacing = PDFPageFormat.mm;

  // The space to allow if we have set up page numbering
  double pageNumberHeight = 0.0;

  /// The margin set in the document being generated
  PDFDocumentMargin margin = PDFDocumentMargin();

  _Cursor(this.paperHeight, this.paperWidth,
      {this.lineSpacing: PDFPageFormat.mm})
      : x = 0.0,
        y = paperHeight;

  /// debug print
  printBounds() {
    print("x: $x, y: $y, maxx: $maxx, maxy: $maxy");
  }

  /// Reset the cursor ready for a new page
  reset() {
    x = margin.left;
    y = paperHeight - margin.top;
    maxx = paperWidth - margin.right;
    maxy = (margin.bottom + pageNumberHeight);
    printWidth = paperWidth - (margin.right + margin.left);
    printHeight = paperHeight - (margin.top + margin.bottom);
  }

  // Add a new line space
  newLine() {
    y -= lineSpacing;
  }

  /// add a paragraph space
  newParagraph() {
    y -= (lineSpacing * 4);
  }

  // Move the cursor relative to the current position
  move(double mx, double my) {
    x += mx;
    y -= my;
    y -= lineSpacing;
  }

  // This will create a new version of the current cursor
  clone() {
    _Cursor clone = _Cursor(paperHeight, paperWidth);
    clone.margin = margin;
    clone.reset();
    clone.x = x;
    clone.x = y;
    return clone;
  }
}
