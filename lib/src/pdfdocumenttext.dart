import 'package:pdf/pdf.dart';

/// This will calculate and hold the details of the text being used taking account of the fontsize
/// IT calculates the [lineHeight] based on 0.15 of the total height of the text used
class PDFDocumentText {
  String text;
  PDFTTFFont font;
  double size;
  double lineHeight;
  double lineWidth;
  double gutter;
  double padding;
  double cursory;

  PDFDocumentText(this.text, this.font, this.size) {
    var bounds = font.stringBounds(text);
    //print(bounds);
    lineHeight = bounds.h *
        size; // the height of the main print scaled for the font and size
    gutter = bounds.y * size; // gutter for chars like y or g
    padding = (lineHeight - gutter) *
        0.15; // text padding based on complete line height
    cursory = (2 * padding) +
        lineHeight -
        gutter; // position to move cursor y to to begin printing
    lineWidth = ((bounds.w + bounds.x) * size) +
        (2 * padding); // the total width of the current line with padding
  }

  printBounds() {
    print(
        "{ padding: $padding, gutter: $gutter, cursory: $cursory, lineHeight: $lineHeight, lineWidth: $lineWidth}");
  }
}
