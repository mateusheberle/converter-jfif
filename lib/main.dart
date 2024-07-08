import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter File Converter .JFIF -> .PNG',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String _fileName = 'Nenhum arquivo selecionado';

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _fileName = result.files.single.name; // Nome do arquivo
      });
      PlatformFile file = result.files.first;
      if (_fileName.contains('.jfif')) {
        convertJfifToPng(file);
      } else {
        debugPrint('Selecione um arquivo .jfif');
      }
    } else {
      debugPrint('User canceled the file picking');
    }
  }

  void convertJfifToPng(PlatformFile file) {
    if (file.bytes != null) {
      Uint8List? fileBytes = file.bytes;
      final img.Image? jfifImage = img.decodeJpg(fileBytes!);
      if (jfifImage != null) {
        final List<int> pngBytes = img.encodePng(jfifImage);
        String fileNamePng =
            _fileName.replaceAllMapped('jfif', (match) => 'png');
        createDownloadLink(pngBytes as Uint8List, fileNamePng);
        debugPrint('Arquivo convertido com sucesso!');
      } else {
        debugPrint('Erro ao decodificar a imagem JFIF.');
      }
    } else {
      debugPrint('Erro ao decodificar a imagem JFIF.');
    }
  }

  void createDownloadLink(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter File Converter .JFIF -> .PNG',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Selecionar arquivo JFIF (.jfif)',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            Text('Arquivo selecionado: $_fileName'),
          ],
        ),
      ),
    );
  }
}
