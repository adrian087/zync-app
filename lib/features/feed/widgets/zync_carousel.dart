import 'package:flutter/material.dart';
import '../screens/full_screen_image_screen.dart';

class ZyncCarousel extends StatefulWidget {
  final List<String> imagenesUrls;
  final String publicacionId;

  const ZyncCarousel({
    super.key, 
    required this.imagenesUrls, 
    required this.publicacionId
  });

  @override
  State<ZyncCarousel> createState() => _ZyncCarouselState();
}

class _ZyncCarouselState extends State<ZyncCarousel> {
  int _paginaActual = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imagenesUrls.isEmpty) return const SizedBox.shrink();
    if (widget.imagenesUrls.length == 1) {
      return _construirImagen(widget.imagenesUrls[0]);
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            itemCount: widget.imagenesUrls.length,
            onPageChanged: (index) {
              setState(() => _paginaActual = index);
            },
            itemBuilder: (context, index) {
              return _construirImagen(widget.imagenesUrls[index]);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imagenesUrls.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _paginaActual == entry.key
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withOpacity(0.4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _construirImagen(String url) {
    final String heroTagUnico = '${widget.publicacionId}_$url';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FullScreenImageScreen(
              imageUrl: url,
              heroTag: heroTagUnico,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Hero(
          tag: heroTagUnico,
          child: Image.network(
            url,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 250,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}