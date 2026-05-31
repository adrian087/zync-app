import 'package:flutter/material.dart';

class FullScreenImageScreen extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const FullScreenImageScreen({
    super.key, 
    required this.imageUrl, 
    required this.heroTag
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true, 
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0, 
          child: Hero(
            tag: heroTag,
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.contain, 
            ),
          ),
        ),
      ),
    );
  }
}