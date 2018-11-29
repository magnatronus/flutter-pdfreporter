import 'package:pdf/pdf.dart';

/// Define document margins in MM
/// The default is 25.4 mm (approx 1")
class PDFDocumentMargin {
  static double standard = 25.4 * PDFPageFormat.mm;
  double _top = standard;
  double _left = standard;
  double _bottom = standard;
  double _right = standard;

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
