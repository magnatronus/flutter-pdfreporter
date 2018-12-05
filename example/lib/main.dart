import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfreporter/pdfreporter.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';

/// Demo app for testing te PDFReporter Package
void main() => runApp(PDFReporterDemo());

/// Material App
class PDFReporterDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'PDFReporter Demo', home: _DemoScreen());
  }
}

/// DemoScreen where the PDF is generated
class _DemoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDFReporter Demo"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () => generateReport(context),
          child: Text("Generate and View Test PDF"),
        ),
      ),
    );
  }

  /// Test the the PDFReporter plugin and geerate a report we can save and show
  generateReport(context) async {
    // Start by creatng a new blank document and set up a standard header
    PDFReportDocument pdf = await PDFReporter.createReport(
      paper: PDFDocumentSize(size: DocumentPaperSize.a5, landscape: true),
      margin:
          PDFDocumentMargin(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0),
    );

    // Add Page Header and numbering
    pdf.setPageHeader("Test PDF Document");
    pdf.setPageNumbering(
      true,
      size: 8.0,
      alignment: PDFDocumentTextAlignment.center,
    );

    // Create the first page
    pdf.newPage();

    pdf.addText("This is Heading1 and should be right aligned",
        alignment: PDFDocumentTextAlignment.right,
        style: pdf.textStyle.heading1);

    pdf.addText("This is Heading2 and should be center aligned",
        alignment: PDFDocumentTextAlignment.center,
        style: pdf.textStyle.heading2);

    /* 
    //example on how to load a network image
    await pdf.addImage( 
      PDFDocumentImage.loadNetworkImage({put url here}),
      x: 50.0,
      y: 50.0,
      width: 200.0,
      //height: 150.0  
    );
    */

    pdf.addText(
      "This should be right aligned - Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
      paragraph: true,
      alignment: PDFDocumentTextAlignment.right,
    );

    pdf.addText(
        "Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
        "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
        "content has been created, giving the design and production process more freedom.",
        paragraph: true,
        backgroundColor: Colors.yellowAccent);

    pdf.addText(
      "Center aligned Text - Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
      paragraph: true,
      alignment: PDFDocumentTextAlignment.center,
    );

    pdf.newline();

    await pdf.addImage(
      PDFDocumentImage.loadAssetImage("images/cat.png"),
      //x: 200.0,
      //y: 0.0,
      width: 200.0,
      //updateCursor: true
    );

    pdf.addText(
      "Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
      paragraph: true,
      indent: 205.0,
    );

    pdf.newline(number: 2);

    pdf.addText(
      "1. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
      paragraph: true,
    );

    pdf.addText(
      "2. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
      paragraph: true,
      //style: pdf.textStyle.heading1,
      //backgroundColor: Colors.red
    );

    pdf.addText(
      "3. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
    );

    pdf.addText(
        "4. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
        "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
        "content has been created, giving the design and production process more freedom.",
        backgroundColor: Colors.pink);

    pdf.addText(
        "5. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
        "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
        "content has been created, giving the design and production process more freedom.",
        backgroundColor: Colors.green);

    pdf.addText(
        "6. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
        "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
        "content has been created, giving the design and production process more freedom.",
        backgroundColor: Colors.blue);

    pdf.addText(
        "7. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
        "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
        "content has been created, giving the design and production process more freedom.",
        backgroundColor: Colors.pink);

    pdf.addText(
        "8. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
        "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
        "content has been created, giving the design and production process more freedom.",
        backgroundColor: Colors.green);

    // Add another paragraph in a different color
    pdf.setFontColor(Colors.orange);
    pdf.addText("This is Heading 2", style: pdf.textStyle.heading2);
    pdf.addText(
      "2. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
    );

    pdf.newline();

    await pdf.addImage(PDFDocumentImage.loadAssetImage("images/cat.png"),
        //x: 200.0,
        //y: 0.0,
        width: 100.0,
        updateCursor: true);

    pdf.newline();

    // And another paragraph in a different color
    pdf.setFontColor(Colors.indigo);
    pdf.addText("This is Heading 3", style: pdf.textStyle.heading3);
    pdf.addText(
      "3. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
    );

    // And another paragraph back in the default color
    pdf.setDefaultFontColor();
    pdf.addText(
        "4. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
        "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
        "content has been created, giving the design and production process more freedom.",
        paragraph: true,
        alignment: PDFDocumentTextAlignment.right);

    // add column as a header
    pdf.addColumnText(["Date", "Work carried out", "Time"],
        flex: [2, 10, 1], spaceMultiplier: 5, style: pdf.textStyle.heading3);

    // print some column text that should wrap the page
    for (int i = 0; i < 30; i++) {
      pdf.addColumnText(
        [
          "11 Nov 2018",
          "And this is the second detailed text for column number two and will truncate if it is too long for the defined column, but hopefully this is not the case",
          "01:35"
        ],
        flex: [2, 10, 1],
        spaceMultiplier: 5,
      );
    }

    pdf.addText(
      "5. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
      paragraph: true,
    );

    /// To view the PDF we should save it first
    var savedfile = await _saveAndViewReport(pdf.asBytes(), "helloword");

    // then pass the file to the viewer if it created OK
    if (savedfile != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PDFViewer(
                    pdffile: savedfile,
                  )));
    }
  }

  /// THis will save the generated PDF as a file and pass the path of the file to the PDF viewer
  _saveAndViewReport(pdfdoc, documentname) async {
    String pdfFile;
    var directory = await getApplicationDocumentsDirectory();
    String storageDir = "${directory.path}/reports";
    Directory(storageDir).createSync();
    if (Directory(storageDir).existsSync()) {
      pdfFile = "$storageDir/$documentname.pdf";
      var file = File(pdfFile);
      file.writeAsBytesSync(pdfdoc);
    }
    return pdfFile;
  }
}

/// Simple PDF Viewer
class PDFViewer extends StatelessWidget {
  final String pdffile;

  PDFViewer({@required this.pdffile});

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
      ),
      path: pdffile,
    );
  }
}
