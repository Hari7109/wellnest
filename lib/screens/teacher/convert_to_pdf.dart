import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart'; // Add this import for handling permissions

class ExaminationResultsPage extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const ExaminationResultsPage({Key? key, required this.studentData}) : super(key: key);

  @override
  _ExaminationResultsPageState createState() => _ExaminationResultsPageState();
}

class _ExaminationResultsPageState extends State<ExaminationResultsPage> {
  final Map<String, dynamic> _results = {};
  bool _isLoading = true;
  bool _generatingPdf = false;
  String? _pdfPath;
  File? _pdfFile;

  @override
  void initState() {
    super.initState();
    _fetchExaminationData();
    _requestPermissions(); // Request storage permissions on startup
  }

  // Method to request necessary permissions
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();
    }
  }

  Future<void> _fetchExaminationData() async {
    try {
      String regNo = widget.studentData['reg_no'];
      List<String> collections = [
        'physical_examinations',
        'body_composition',
        'ent_examinations',
        'eye_examinations',
        'laboratory_findings'
      ];

      for (String collection in collections) {
        DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection(collection).doc(regNo).get();

        if (snapshot.exists && snapshot.data() != null) {
          _results[collection] = snapshot.data();
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePDF() async {
    setState(() {
      _generatingPdf = true;
    });

    try {
      final pdf = pw.Document();

      // Add page to the PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          header: (pw.Context context) {
            return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('MEDICAL EXAMINATION RESULTS',
                      style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold
                      )
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text('Student: ${widget.studentData['name'] ?? 'N/A'}'),
                  pw.Text('Registration Number: ${widget.studentData['reg_no'] ?? 'N/A'}'),
                  pw.Divider(),
                ]
            );
          },
          build: (pw.Context context) {
            if (_results.isEmpty) {
              return [pw.Center(child: pw.Text('No examination results found'))];
            }

            return [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: _results.entries.map((entry) {
                  // Convert the value to a properly typed Map to avoid type errors
                  Map<String, dynamic> resultData = {};
                  if (entry.value is Map) {
                    resultData = Map<String, dynamic>.from(entry.value as Map);
                  }

                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                          _formatCollectionName(entry.key),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)
                      ),
                      pw.SizedBox(height: 5),
                      pw.Table(
                        border: pw.TableBorder.all(width: 0.5),
                        columnWidths: {
                          0: pw.FlexColumnWidth(2),
                          1: pw.FlexColumnWidth(3),
                        },
                        children: resultData.entries.map((e) =>
                            pw.TableRow(
                                children: [
                                  pw.Padding(
                                      padding: pw.EdgeInsets.all(4),
                                      child: pw.Text(_formatFieldName(e.key.toString()),
                                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                                      )
                                  ),
                                  pw.Padding(
                                      padding: pw.EdgeInsets.all(4),
                                      child: pw.Text(e.value?.toString() ?? 'N/A')
                                  ),
                                ]
                            )
                        ).toList(),
                      ),
                      pw.SizedBox(height: 15),
                    ],
                  );
                }).toList(),
              )
            ];
          },
        ),
      );

      // First try to save to the documents directory (works on both iOS and Android)
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'examination_results_${widget.studentData['reg_no'] ?? 'report'}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      // Save the PDF
      await file.writeAsBytes(await pdf.save());

      // Store both the path and the file object
      _pdfPath = file.path;
      _pdfFile = file;

      print("PDF saved to: $_pdfPath");

      // Show success dialog with share and view options
      _showSuccessDialog(file.path);

    } catch (e) {
      print('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _generatingPdf = false;
      });
    }
  }

  void _showSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('PDF Generated Successfully'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your PDF has been created successfully.'),
            SizedBox(height: 10),
            Text('File location:'),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                filePath,
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.visibility),
            label: Text('View'),
            onPressed: () {
              Navigator.of(context).pop();
              _viewPDF();
            },
          ),
          TextButton.icon(
            icon: Icon(Icons.share),
            label: Text('Share'),
            onPressed: () {
              Navigator.of(context).pop();
              _sharePDF();
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Method to verify file exists and then open it
  Future<void> _viewPDF() async {
    if (_pdfFile == null || !await _pdfFile!.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF file not found. Please generate it again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await OpenFile.open(_pdfFile!.path);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open file: ${result.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to verify file exists and then share it
  Future<void> _sharePDF() async {
    if (_pdfFile == null || !await _pdfFile!.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF file not found. Please generate it again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // This uses a file provider for sharing on newer Android versions
      await Share.shareXFiles(
        [XFile(_pdfFile!.path)],
        subject: 'Medical Examination Results',
        text: 'Medical examination results for ${widget.studentData['name'] ?? 'student'}',
      );
    } catch (e) {
      print('Share error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper function to format collection names
  String _formatCollectionName(String name) {
    return name.replaceAll('_', ' ').toUpperCase();
  }

  // Helper function to format field names
  String _formatFieldName(String name) {
    return name.replaceAll('_', ' ').split(' ').map((word) =>
    word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Examination Results', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        actions: [
          if (_pdfFile != null)
            IconButton(
              icon: Icon(Icons.share),
              onPressed: _sharePDF,
              tooltip: 'Share Report',
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _results.isEmpty
                  ? Center(child: Text('No examination results found'))
                  : ListView(
                children: _results.entries.map((entry) {
                  Map<String, dynamic> data = {};
                  if (entry.value is Map) {
                    data = Map<String, dynamic>.from(entry.value as Map);
                  }

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              _formatCollectionName(entry.key),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                          Divider(),
                          ...data.entries.map((e) =>
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text("${_formatFieldName(e.key.toString())}: ${e.value ?? 'N/A'}"),
                              )
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generatingPdf ? null : _generatePDF,
                    icon: _generatingPdf
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : Icon(Icons.picture_as_pdf),
                    label: Text(_generatingPdf ? 'Generating PDF...' : 'Generate PDF Report'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.blue[300],
                    ),
                  ),
                ),
                if (_pdfFile != null) ...[
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: _viewPDF,
                    icon: Icon(Icons.visibility),
                    tooltip: 'View PDF',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: _sharePDF,
                    icon: Icon(Icons.share),
                    tooltip: 'Share PDF',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}