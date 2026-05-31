import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../search/screens/search_screen.dart';

class ZyncTextFormatter extends StatelessWidget {
  final String text;
  final double fontSize;

  const ZyncTextFormatter({super.key, required this.text, this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    final RegExp regex = RegExp(
      r'(#[a-zA-Z0-9_áéíóúÁÉÍÓÚñÑ]+|@[a-zA-Z0-9_áéíóúÁÉÍÓÚñÑ]+)',
    );
    final Iterable<Match> matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: TextStyle(fontSize: fontSize));
    }

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      final String matchText = match.group(0)!;
      final int matchStart = match.start;

      if (matchStart > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, matchStart),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: fontSize,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: matchText,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary, // Azul de Zync
            fontWeight: FontWeight.bold,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              final String terminoBusqueda =
                  matchText.startsWith('@') || matchText.startsWith('#')
                  ? matchText.substring(1)
                  : matchText;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SearchScreen(initialQuery: terminoBusqueda),
                ),
              );
            },
        ),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastMatchEnd),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: fontSize,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}
