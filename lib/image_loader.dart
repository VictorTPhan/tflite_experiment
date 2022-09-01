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
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 75,
                  color: Colors.blueGrey[100],
                  child: Row(
                    children: [
                      images[index].imageWidget
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
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
                    width: 200,
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
