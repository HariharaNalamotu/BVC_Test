import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Document Viewer')),
        body: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _filePath = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Enter CSV URL here'),
          ),
        ),

        ElevatedButton(
          child: const Text('Enter'),
          onPressed: () => _downloadCSVAndExtractPDF(_controller.text),
        ),

        Expanded(
          child: _filePath.isNotEmpty
              ? PDFView(
                  filePath: _filePath,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: false,
                )
              : const Center(child: Text('Please enter a CSV URL')),
        ),
      ],
    );
  }

  Future<void> _downloadCSVAndExtractPDF(String url) async {
    Dio dio = Dio();
    Directory dir = await getApplicationDocumentsDirectory();
    String csvPath = '${dir.path}/myDocument.csv';

    // Download the CSV file
    print(url);
    await dio.download(url, csvPath);

    // Read the CSV file
    final csvFile = File(csvPath).openRead();
    final fields = await csvFile.transform(utf8.decoder).transform(CsvToListConverter()).toList();

    // Assume the PDF URL is in the first row and first column of the CSV
    String pdfUrl = fields[0][1];
    print(pdfUrl);

    String pdfPath = '${dir.path}/myDocument.pdf';

    // Download the PDF file
    await dio.download(pdfUrl, pdfPath);

    // Update the state to display the PDF
    setState(() {
      _filePath = pdfPath;
    });
  }
}
