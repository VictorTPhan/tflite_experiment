import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:tflite_experiment/results.dart';

class ImageLoader extends StatefulWidget {
  const ImageLoader({Key? key}) : super(key: key);

  @override
  State<ImageLoader> createState() => _ImageLoaderState();
}

class ImageData {
  File imageFile;
  late Image imageWidget;

  ImageData(this.imageFile)
  {
    imageWidget = Image.file(imageFile);
  }
}

class _ImageLoaderState extends State<ImageLoader> {

  TextEditingController targetController = new TextEditingController();
  List<ImageData> images = [];
  bool showImages = false;

  void imageSelection() async {
    await ImagePicker().pickMultiImage().
    then((value) {
      List<XFile> files = value as List<XFile>;
      for(XFile f in files)
        {
          setState(() {
            images.add(ImageData(File(f.path)));
          });
        }
    });
  }

  void toggleImageVisibility()
  {
    setState(() {
      showImages = !showImages;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Load Images"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 90,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: showImages? 75: 20,
                  color: Colors.blueGrey[100],
                  child: showImages
                      ? images[index].imageWidget
                      : Text(
                          (index + 1).toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                        )
                );
              },
            ),
          ),
          Expanded(
            flex: 10,
            child: Container(
              color: Colors.blue[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 150,
                    child: TextField(
                      controller: targetController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter target label",
                          filled: true,
                          fillColor: Colors.white70,
                      ),
                      onChanged: (String value)
                      {
                        setState(() {});
                      },
                    ),
                  ),
                  Row(
                    children: [
                      FloatingActionButton(
                          heroTag: null,
                          onPressed: imageSelection,
                          child: Icon(Icons.add)
                      ),
                      if (images.length > 1)
                        FloatingActionButton(
                            heroTag: null,
                            onPressed: toggleImageVisibility,
                            child: Icon(Icons.remove_red_eye_outlined)
                        ),
                      if (images.length > 1)
                        FloatingActionButton(
                            heroTag: null,
                            onPressed: () {
                              setState(() {
                                images = [];
                              });
                            },
                            child: Icon(Icons.delete)
                        ),
                      if (images.length > 1 && targetController.text.isNotEmpty)
                        FloatingActionButton(
                            heroTag: null,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Results(images: images, target: targetController.text,)),
                              );
                            },
                            child: Icon(Icons.check)
                        ),
                    ],
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
