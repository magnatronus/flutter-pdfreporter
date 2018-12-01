import 'package:pdf/pdf.dart';

/// Define document margins in MM
/// The default is 25.4 mm (approx 1")
class PDFDocumentMargin {
  static double standard = 25.4;
  double _top;
  double _left;
  double _bottom;
  double _right;

  /// Generate a  Document margin specifying the sizes im MM. The default size is 25.4MM
  /// but by specifying [top], [left], [bottom] or [right] this can be altered
  PDFDocumentMargin({double top, double left, double bottom, double right})
      : _top = top ?? standard,
        _left = left ?? standard,
        _bottom = bottom  ?? standard,
        _right = right  ?? standard;

  get top {
    return _top * PDFPageFormat.mm;
  }

  get left {
    return _left  * PDFPageFormat.mm;
  }

  get bottom {
    return _bottom  * PDFPageFormat.mm;
  }

  get right {
    return _right  * PDFPageFormat.mm;
  }
}
