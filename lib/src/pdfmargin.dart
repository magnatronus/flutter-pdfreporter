import 'package:pdf/pdf.dart';

/// Define document margins in MM
/// The default is 25.4 mm (approx 1")
class PDFDocumentMargin {
  static double standard = 25.4 * PDFPageFormat.mm;
  double _top;
  double _left;
  double _bottom;
  double _right;

  /// Generate a  Document margin specifying the sizes im MM. The default size is 25.4MM
  /// but by specifying [top], [left], [bottom] or [right] this can be altered
  PDFDocumentMargin({double top, double left, double bottom, double right})
      : _top = (top * PDFPageFormat.mm) ?? standard,
        _left = (left * PDFPageFormat.mm) ?? standard,
        _bottom = (bottom * PDFPageFormat.mm) ?? standard,
        _right = (right * PDFPageFormat.mm) ?? standard;

  get top {
    return _top;
  }

  get left {
    return _left;
  }

  get bottom {
    return _bottom;
  }

  get right {
    return _right;
  }
}
