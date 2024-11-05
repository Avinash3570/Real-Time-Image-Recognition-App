import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class PredictionScreen extends StatefulWidget {
  final File image;

  PredictionScreen({required this.image});

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  List? _predictions;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadModelAndPredict();
  }

  @override
  void dispose() {
    _closeModel();
    super.dispose();
  }

  Future<void> _closeModel() async {
    try {
      await Tflite.close();
    } catch (e) {
      print('Error closing model: $e');
    }
  }

  Future<void> _loadModelAndPredict() async {
    try {
      print('Starting model loading...');
      print('Image path: ${widget.image.path}');

      // Load model with error catching
      print('Attempting to load model...');
      String? res = await Tflite.loadModel(
          model: "assets/model.tflite",
          labels: "assets/labels.txt",
          numThreads: 1,
          isAsset: true,
          useGpuDelegate: false
      );

      print('Model loading response: $res');

      // Make prediction
      print('Making prediction...');
      var predictions = await Tflite.runModelOnImage(
          path: widget.image.path,
          numResults: 5,
          threshold: 0.5,
          imageMean: 127.5,
          imageStd: 127.5,
          asynch: true
      );

      print('Predictions: $predictions');

      setState(() {
        _predictions = predictions;
        _isLoading = false;
      });

    } catch (e) {
      print('Error in _loadModelAndPredict: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prediction Result'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(widget.image, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 20),
                if (_isLoading)
                  Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Processing image...'),
                    ],
                  )
                else if (_error.isNotEmpty)
                  Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 50),
                      SizedBox(height: 10),
                      Text(
                        'Error: $_error',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                else if (_predictions != null && _predictions!.isNotEmpty)
                    Column(
                      children: _predictions!.map((prediction) {
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(
                              "${prediction['label']}".replaceAll(RegExp(r'[0-9]+'), '').trim(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Confidence: ${(prediction['confidence'] * 100).toStringAsFixed(1)}%",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    Text(
                      "No predictions available",
                      style: TextStyle(fontSize: 18),
                    ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}