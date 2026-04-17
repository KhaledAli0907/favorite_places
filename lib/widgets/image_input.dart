import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});

  final void Function(File image) onPickImage;

  @override
  State<ImageInput> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;

  void _takePhoto() async {
    final imagePicker = ImagePicker();
    final XFile? pickedImage =
        await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);

    if (pickedImage == null) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    widget.onPickImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
        onPressed: () => _takePhoto(),
        icon: const Icon(Icons.camera),
        label: const Text('Take Photo'));

    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: () => _takePhoto(),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
        ),
      );
    }

    return Container(
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border:
            Border.all(width: 1, color: Theme.of(context).colorScheme.primary),
      ),
      child: content,
    );
  }
}
