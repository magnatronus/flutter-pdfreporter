import 'package:pdf/pdf.dart';

// enum of standard available paper sizes
enum DocumentPaperSize { a5, a4, a3, letter, legal }

/// Simple class to expose PDFPageFormat
class PDFDocumentSize {
  final DocumentPaperSize size;
  final bool landscape;
  final double width;
  final double height;

  /// Define the size of the paper to use when creating PDF Document pages
  /// Either use a pre-defined [size] OR specify the [width] and [height]
  /// [landscape] can also be set to  select either portrat(the default) or lanscape orientation
  PDFDocumentSize({this.size, this.landscape: false, this.width, this.height}) {
    if ((size == null) && (width == null || height == null)) {
      throw Exception(
          "Either a size MUST be specified or the width and height MUST be provided.");
    }
  }

  /// Return the correct PDFFormatPage info for the selected paper
  get paper {
    if (size == null) {
      return PDFPageFormat(width, height);
    }
    switch (size) {
      case DocumentPaperSize.a5:
        return (landscape) ? PDFPageFormat.a5.landscape : PDFPageFormat.a5;
      case DocumentPaperSize.a3:
        return (landscape) ? PDFPageFormat.a3.landscape : PDFPageFormat.a3;
      case DocumentPaperSize.letter:
        return (landscape)
            ? PDFPageFormat.letter.landscape
            : PDFPageFormat.letter;
      case DocumentPaperSize.legal:
        return (landscape)
            ? PDFPageFormat.legal.landscape
            : PDFPageFormat.legal;
      case DocumentPaperSize.a4:
        return (landscape) ? PDFPageFormat.a4.landscape : PDFPageFormat.a4;
    }
  }
}
