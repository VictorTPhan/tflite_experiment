import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageLoader extends StatefulWidget {
  const ImageLoader({Key? key}) : super(key: key);

  @override
  State<ImageLoader> createState() => _ImageLoaderState();
}

class _ImageLoaderState extends State<ImageLoader> {

  List<PickedFile> images = [];

  void _imageSelection() async {
    await ImagePicker().getImage(source: ImageSource.gallery).
    then((value) {
      if (value != null)
      {
        print(value.path);
        setState(() {
          images.add(value);
          print(images.length);
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
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: images.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 50,
            color: Colors.blueGrey[100],
            child: Text(images[index].path),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
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
                      onPressed: () {},
                      child: Icon(Icons.check)
                  ),
                ],
              ),
            ),
          ]
      ),
    );
  }
}
