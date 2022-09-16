import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:tflite_experiment/image_loader.dart';

//The following code is based heavily off of code provided by:
//  -Teresa Wu https://spltech.co.uk/flutter-image-classification-using-tensorflow-in-4-steps/
//  -Nancy Patel https://medium.com/geekculture/image-classification-with-flutter-182368fea3b

class Results extends StatefulWidget {
  final List<ImageData> images;
  final String target;

  const Results({Key? key, required this.images, required this.target}) : super(key: key);

  @override
  State<Results> createState() => _ResultsState();
}

class ClassificationData {
  late ImageData imageData;
  late String label;
  late int confidence;

  ClassificationData(this.imageData, this.label, this.confidence);
}

class ResultData {
  List<ClassificationData> classifications;
  String target;

  late int numCorrect;
  late int numIncorrect;
  late double accuracy;
  late int highestConfidence;
  late int lowestConfidence;
  late double averageConfidence;

  ResultData(this.classifications, this.target)
  {
    numCorrect = 0;
    numIncorrect = 0;
    accuracy = 0;
    highestConfidence = classifications[0].confidence;
    lowestConfidence = classifications[0].confidence;
    averageConfidence = 0;

    double totalConfidence = 0;

    for(ClassificationData c in classifications)
    {
      if (c.label.contains(target)) {
        numCorrect++;
      } else {
        numIncorrect++;
      }

      if (c.confidence > highestConfidence) {
        highestConfidence = c.confidence;
      } else if (c.confidence < lowestConfidence) {
        lowestConfidence = c.confidence;
      }

      totalConfidence += c.confidence;
    }

    averageConfidence = totalConfidence / classifications.length;
    accuracy = (numCorrect.toDouble() / classifications.length.toDouble());
  }
}

class _ResultsState extends State<Results> {

  List<ClassificationData> classifications = [];
  bool showImages = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    ).then((value) {
      classifyAllImages();
    });
  }

  Future<void> classifyAllImages() async {
    for (ImageData i in widget.images)
      {
        await imageClassification(i);
      }
  }

  Future<void> imageClassification(ImageData imageData) async {
    var output = await Tflite.runModelOnImage(
      path: imageData.imageFile.path,
      numResults: 1,
      threshold: 0.1,
      imageMean: 0,
      imageStd: 255,
    ).
      then((value) {
        print(value![0]["label"].toString());
        setState(() {
          classifications.add(
            ClassificationData(
                imageData,
                value![0]["label"].toString(),
                double.parse(value![0]["confidence"].toString().substring(2, 4)).round()
            )
          );
        });
      }
    );
  }

  void generateResults(BuildContext context)
  {
    ResultData result = ResultData(classifications, widget.target);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Results for experiment"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Target: ${result.target}",
                style: const TextStyle(
                  fontSize: 18
                ),
              ),
              Text(
                "Accuracy: ${"${(result.accuracy*100).toString()}%"}",
                style: const TextStyle(
                    fontSize: 18
                ),
              ),
              Text(
                "Num Correct: ${result.numCorrect}",
                style: const TextStyle(
                    fontSize: 18
                ),
              ),
              Text(
                "Num Incorrect: ${result.numIncorrect}",
                style: const TextStyle(
                    fontSize: 18
                ),
              ),
              Text(
                "Total Images Tested: ${result.classifications.length}",
                style: const TextStyle(
                    fontSize: 18
                ),
              ),
              Text(
                "Highest Confidence: ${result.highestConfidence}%",
                style: const TextStyle(
                    fontSize: 18
                ),
              ),
              Text(
                "Lowest Confidence: ${result.lowestConfidence}%",
                style: const TextStyle(
                    fontSize: 18
                ),
              ),
              Text(
                "Average Confidence: ${result.averageConfidence.toString()}%",
                style: const TextStyle(
                    fontSize: 18
                ),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("back"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void toggleImageVisibility()
  {
    setState(() {
      showImages = !showImages;
    });
  }

  //Used within rows so that the screen can very neatly separate widgets into chunks
  Widget evenlySpacedWidget(Widget w)
  {
    return Expanded(
      child: Center(
        child: w
      ),
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
        title: Text(widget.target),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                evenlySpacedWidget(
                  const SizedBox(
                    width: 50,
                    child: Text(
                      "   #",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ),
                if (showImages)
                  evenlySpacedWidget(
                    const Text(
                      "image",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                evenlySpacedWidget(
                  const Text(
                    "label",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                evenlySpacedWidget(
                  const Text(
                    "conf.",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 80,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: classifications.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: showImages? 65: 30,
                  color: classifications[index].label.contains(widget.target)?
                    Colors.green: Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      evenlySpacedWidget(
                        Text(
                          (index + 1).toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ),
                      if (showImages)
                        evenlySpacedWidget(
                          SizedBox(
                            width: 75,
                            child: classifications[index].imageData.imageWidget,
                          )
                        ),
                      evenlySpacedWidget(
                        Text(
                          classifications[index].label,
                          style: const TextStyle(
                              fontSize: 18
                          ),
                        ),
                      ),
                      evenlySpacedWidget(
                        Text(
                          "${classifications[index].confidence}%",
                          style: const TextStyle(
                              fontSize: 18
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 10,
            child: Container(
              color: Colors.blue[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                      heroTag: null,
                      onPressed: toggleImageVisibility,
                      child: Icon(Icons.remove_red_eye_outlined)
                  ),
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () {
                      generateResults(context);
                    },
                    child: const Icon(Icons.zoom_in),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
