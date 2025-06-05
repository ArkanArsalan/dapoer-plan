import 'package:flutter/material.dart';
import '../models/detection_model.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<DetectionResult> results;

  BoundingBoxPainter(this.results) {
    print("DEBUG: BoundingBoxPainter diinisialisasi dengan ${results.length} hasil.");
  }

  @override
  void paint(Canvas canvas, Size size) {
    print("DEBUG: BoundingBoxPainter paint dipanggil. Canvas size: ${size.width}x${size.height}");
    final paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.redAccent.withOpacity(0.7),
    );

    for (final result in results) {
      // Skalakan koordinat bounding box dari input model 640x640
      // ke ukuran tampilan gambar aktual.
      final scaledRect = Rect.fromLTWH(
        result.rect.left * size.width,   // rect.left sudah proporsional (0-1) dari 640
        result.rect.top * size.height,   // rect.top sudah proporsional (0-1) dari 640
        result.rect.width * size.width,  // rect.width sudah proporsional (0-1) dari 640
        result.rect.height * size.height, // rect.height sudah proporsional (0-1) dari 640
      );

      // Pastikan scaledRect memiliki dimensi yang valid
      if (scaledRect.width <= 0 || scaledRect.height <= 0) {
        print("WARNING: Deteksi dengan dimensi tidak valid, dilewati: ${result.className}, Rect: $scaledRect");
        continue;
      }


      canvas.drawRect(scaledRect, paint);

      if (result.className != null) {
        final textSpan = TextSpan(
          text: '${result.className} (${(result.score * 100).toStringAsFixed(1)}%)',
          style: textStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: scaledRect.width,
        );

        final textOffset = Offset(
          scaledRect.left,
          scaledRect.top - textPainter.height - 2,
        );

        // Pastikan teks tidak keluar layar di bagian atas
        final double actualTop = textOffset.dy < 0 ? 0 : textOffset.dy;
        textPainter.paint(canvas, Offset(textOffset.dx, actualTop));
      }
    }
    print("DEBUG: BoundingBoxPainter paint selesai.");
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Selalu repaint karena hasil deteksi bisa berubah
    print("DEBUG: BoundingBoxPainter shouldRepaint: true.");
    return true;
  }
}