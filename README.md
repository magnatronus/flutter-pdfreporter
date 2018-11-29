# pdfreporter

PDFReporter is a Flutter package that wraps the Flutter package [PDF](https://pub.dartlang.org/packages/pdf) to allow generation of a complete PDF document
with multiple pages and other functionality such as defined text styles, wrapping text and column printing.

Take a look at the included example project to see how to create a document. Also note that the current implementation is hard coded to create an A4 size page.

The report currently uses a pre-defined set of text styles based around the Google Open Sans fonts set up as follows:

- title: 24 pt, bold
- heading1: 19 pt, bold
- heading2: 16pt, bold
- heading1: 12 pt, semi-bold
- normal: 10pt, regular


## Methods available
The abstract class **PDFReportDocument** exposes the current methods that can be used when generating a PDFDocument just take a look at the [code here](https://github.com/magnatronus/flutter-pdfreporter/blob/master/lib/src/pdfdocument.dart).


As this is still WIP it has not been released as a published package but you can still try it out by adding the following to your apps **pubspec.yaml** under the **dependencies** section.

```
  pdfreporter:
    git:
      url: https://github.com/magnatronus/flutter-pdfreporter.git
```





## Getting Started

For help getting started with Flutter, view the online [documentation](https://flutter.io/).

For help on editing package code, view the [documentation](https://flutter.io/developing-packages/).
