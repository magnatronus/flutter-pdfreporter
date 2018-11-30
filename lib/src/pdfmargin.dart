import 'package:pdf/pdf.dart';

/// Define document margins in MM
/// The default is 25.4 mm (approx 1")
class PDFDocumentMargin {
  static double standard = 25.4 * PDFPageFormat.mm;
  double _top;
  double _left;
  double _bottom;
  double _right;

  PDFDocumentMargin({double top, double left, double bottom, double right})
      : _top = top ?? standard,
        _left = left ?? standard,
        _bottom = bottom ?? standard,
        _right = right ?? standard;

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
