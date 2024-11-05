import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'prediction_screen.dart';
import 'package:tflite/tflite.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  File? _image;
  final picker = ImagePicker();

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Recognition'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                ),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Camera'),
              onPressed: () => getImage(ImageSource.camera),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.photo_library),
              label: Text('Gallery'),
              onPressed: () => getImage(ImageSource.gallery),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.preview),
              label: Text('Predict'),
              onPressed: _image == null
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PredictionScreen(image: _image!),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}