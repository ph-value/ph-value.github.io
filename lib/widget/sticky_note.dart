import 'dart:math';

import 'package:flutter/material.dart';

class StickyNote extends StatelessWidget {
  const StickyNote(
      {required this.child, required this.color, required this.isMe});

  final Widget child;
  final Color color;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final double randomAngle = (Random().nextBool() ? 0.01 : -0.01) * pi;

    return Transform.rotate(
      angle: randomAngle,
      child: CustomPaint(
          painter: StickyNotePainter(color: color, isMe: isMe),
          child: Center(child: child)),
    );
  }
}

class StickyNotePainter extends CustomPainter {
  StickyNotePainter({
    required this.color,
    required this.isMe,
  });

  Color color;
  bool isMe;

  @override
  void paint(Canvas canvas, Size size) {
    _drawShadow(size, canvas);
    Paint gradientPaint = _createGradientPaint(size);
    _drawNote(size, canvas, gradientPaint);
  }

  void _drawNote(Size size, Canvas canvas, Paint gradientPaint) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    double foldAmount = 0.12;

    if (isMe) {
      // isMe가 true일 때: 왼쪽 하단이 말리는 경우
      path.lineTo(size.width, size.height);
      path.lineTo(size.width * 3 / 4, size.height);
      path.quadraticBezierTo(
        size.width * foldAmount * 2,
        size.height,
        size.width * foldAmount,
        size.height - (size.height * foldAmount),
      );
      path.quadraticBezierTo(
        0,
        size.height - (size.height * foldAmount * 1.5),
        0,
        size.height / 4,
      );
    } else {
      // isMe가 false일 때: 오른쪽 하단이 말리는 경우
      path.lineTo(size.width, size.height * 3 / 4);
      path.quadraticBezierTo(
        size.width,
        size.height - (size.height * foldAmount * 1.5),
        size.width - (size.width * foldAmount),
        size.height - (size.height * foldAmount),
      );
      path.quadraticBezierTo(
        size.width - (size.width * foldAmount * 2),
        size.height,
        size.width * 3 / 4,
        size.height,
      );
      path.lineTo(0, size.height);
    }

    path.lineTo(0, 0);

    canvas.drawPath(path, gradientPaint);
  }

  Paint _createGradientPaint(Size size) {
    Paint paint = Paint();

    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    RadialGradient gradient = RadialGradient(
        colors: [brighten(color), color],
        radius: 1.0,
        stops: const [0.5, 1.0],
        center: isMe ? Alignment.bottomLeft : Alignment.bottomRight);
    paint.shader = gradient.createShader(rect);
    return paint;
  }

  void _drawShadow(Size size, Canvas canvas) {
    Rect rect = Rect.fromLTWH(12, 12, size.width - 24, size.height - 24);
    Path path = Path();
    path.addRect(rect);
    canvas.drawShadow(path, Colors.black.withOpacity(0.7), 12.0, true);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

Color brighten(Color c, [int percent = 30]) {
  var p = percent / 100;
  return Color.fromARGB(
      c.alpha,
      c.red + ((255 - c.red) * p).round(),
      c.green + ((255 - c.green) * p).round(),
      c.blue + ((255 - c.blue) * p).round());
}

Color darker(Color c, [int percent = 30]) {
  var p = percent / 100;
  return Color.fromARGB(
    c.alpha,
    (c.red * (1 - p)).round(),
    (c.green * (1 - p)).round(),
    (c.blue * (1 - p)).round(),
  );
}
