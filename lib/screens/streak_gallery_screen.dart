import 'package:flutter/material.dart';
import 'dart:io';

class StreakGalleryScreen extends StatelessWidget {
  final List<String> photoPaths;
  const StreakGalleryScreen({Key? key, required this.photoPaths})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streak Gallery')),
      body: photoPaths.isEmpty
          ? const Center(child: Text('No check-in photos yet.'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: photoPaths.length,
              itemBuilder: (context, index) {
                return Image.file(File(photoPaths[index]), fit: BoxFit.cover);
              },
            ),
    );
  }
}
