import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

//The following code is based heavily off of code provided by:
//  -Teresa Wu https://spltech.co.uk/flutter-image-classification-using-tensorflow-in-4-steps/
//  -Nancy Patel https://medium.com/geekculture/image-classification-with-flutter-182368fea3b

class Classification extends StatefulWidget {
  const Classification({Key? key}) : super(key: key);

  @override
  _ClassificationState createState() => _ClassificationState();
}

class _ClassificationState extends State<Classification> {

  List? _listResult;
  PickedFile? _imageFile;
  bool _loading = false;

  File? _image;
  Image? _imageWidget;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loading = true;
    _loadModel();
  }

  void _loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    ).then((value) {
      setState(() {
        _loading = false;
      });
    });
  }
  void processImage(PickedFile i) {
    _imageFile = i;
    _image = File(i!.path);
    _imageWidget = Image.file(_image!);
  }
  void _imageSelection() async {
    var imageFile = await ImagePicker().getImage(source: ImageSource.gallery).
    then((value) {
      if (value != null)
      {
        _imageClasification(value!);
      }
    });
  }

  void _cameraSelection() async {
    var imageFile = await ImagePicker().getImage(source: ImageSource.camera).
    then((value) {
      if (value != null)
      {
        _imageClasification(value!);
      }
    });
  }

  void _imageClasification(PickedFile image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.1,
      imageMean: 0,
      imageStd: 255,
    ).
    then((value) {
      setState(() {
        if (value == null) print("did not successfully load");
        print(value);
        _listResult = value;
        processImage(image);
      });
    }
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tensorflow Lite Model Experiment App"),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              child: _image == null
                  ? Text("No images selected",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400),
              )
                  :Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 2),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Container(
                    child: _imageWidget
                ),
              ),
            ),
            if (_listResult != null)
              Column(
                children: [
                  Text(
                    "Prediction:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25
                    ),
                  ),
                  Text(
                      _listResult![0]["label"].toString(),
                    style: TextStyle(
                        fontSize: 20
                    )
                  ),
                  Text(
                      "Confidence:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25
                    ),
                  ),
                  Text(
                      _listResult![0]["confidence"].toString().substring(2, 4) + "%",
                      style: TextStyle(
                          fontSize: 20
                      )
                  )
                ],
              )
          ],
        ),
      ),
      floatingActionButton: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              bottom: 10,
              right: 10,
              child: Row(
                children: [
                  FloatingActionButton(
                      heroTag: null,
                      onPressed: _imageSelection,
                      child: Icon(Icons.add)
                  ),
                  FloatingActionButton(
                      heroTag: null,
                      onPressed: _cameraSelection,
                      child: Icon(Icons.add_a_photo_rounded)
                  ),
                ],
              ),
            ),
          ]
      ),
    );
  }
}