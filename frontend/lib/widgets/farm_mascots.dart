import 'package:flutter/material.dart';
import 'dart:math' as math;

class FarmMascots extends StatelessWidget {
  final bool isPasswordFocused;
  final bool isPasswordVisible;
  final bool isEmailFocused;

  const FarmMascots({
    super.key,
    required this.isPasswordFocused,
    required this.isPasswordVisible,
    this.isEmailFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70, // Küçültüldü (120 -> 70)
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 1. Domates 🍅
          _MascotCharacter(
            type: _MascotType.tomato,
            width: 45, // 80 -> 45
            height: 45, // 80 -> 45
            isPasswordFocused: isPasswordFocused,
            isPasswordVisible: isPasswordVisible,
            isEmailFocused: isEmailFocused,
          ),
          const SizedBox(width: 10), // 15 -> 10
          
          // 2. Patates 🥔
          _MascotCharacter(
            type: _MascotType.potato,
            width: 50, // 85 -> 50
            height: 42, // 75 -> 42
            isPasswordFocused: isPasswordFocused,
            isPasswordVisible: isPasswordVisible,
            isEmailFocused: isEmailFocused,
          ),
          const SizedBox(width: 10),
          
          // 3. Havuç 🥕
          _MascotCharacter(
            type: _MascotType.carrot,
            width: 40, // 70 -> 40
            height: 55, // 90 -> 55
            isPasswordFocused: isPasswordFocused,
            isPasswordVisible: isPasswordVisible,
            isEmailFocused: isEmailFocused,
          ),
        ],
      ),
    );
  }
}

enum _MascotType { tomato, potato, carrot }

class _MascotCharacter extends StatelessWidget {
  final _MascotType type;
  final double width;
  final double height;
  final bool isPasswordFocused;
  final bool isPasswordVisible;
  final bool isEmailFocused;

  const _MascotCharacter({
    required this.type,
    required this.width,
    required this.height,
    required this.isPasswordFocused,
    required this.isPasswordVisible,
    required this.isEmailFocused,
  });

  @override
  Widget build(BuildContext context) {
    // El pozisyonu mantığı
    double handAlignY = 1.0; 
    
    // Yüz ifadesi / Gözler
    bool isPeeking = false;

    if (isPasswordFocused) {
      if (isPasswordVisible) {
        handAlignY = 0.4;
        isPeeking = true;
      } else {
        handAlignY = -0.2; 
      }
    }

    // Göreceli konumlandırma için oranlar
    final double eyeTop = type == _MascotType.carrot ? height * 0.4 : height * 0.35;
    final double blushTop = type == _MascotType.carrot ? height * 0.55 : height * 0.52;

    return SizedBox(
      width: width,
      height: height + 10, // Yaprak payı
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // GÖVDE ÇİZİMİ
          CustomPaint(
            size: Size(width, height),
            painter: _BodyPainter(type: type),
          ),

          // GÖZLER (Animasyonlu Takip)
          Positioned(
            top: eyeTop,
            child: _AnimatedEyes(
              width: width * 0.7, // Genişliğe göre orantıla
              isLookingDown: isEmailFocused,
              isPeeking: isPeeking,
              isCovered: isPasswordFocused && !isPasswordVisible,
            ),
          ),

          // YANAKLAR
          Positioned(
            top: blushTop,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBlush(),
                SizedBox(width: width * 0.3), 
                _buildBlush(),
              ],
            ),
          ),

          // ELLER (Animasyonlu)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutBack,
            bottom: isPasswordFocused 
                ? (isPasswordVisible ? height * 0.30 : height * 0.50) 
                : 0, 
            child: SizedBox(
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   _buildHand(type),
                   const SizedBox(width: 2), // Elleri birleştir
                   _buildHand(type),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlush() {
    return Container(
      width: 8, height: 4, 
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _buildHand(_MascotType type) {
    Color color;
    switch (type) {
      case _MascotType.tomato: color = const Color(0xFFFF6347); break;
      case _MascotType.potato: color = const Color(0xFFD4AC5D); break;
      case _MascotType.carrot: color = const Color(0xFFFF9800); break;
    }

    return Container(
      width: 14, height: 20, 
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12, width: 1),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1, offset: Offset(0,1))],
      ),
    );
  }
}

class _AnimatedEyes extends StatelessWidget {
  final double width;
  final bool isLookingDown; // Email focus
  final bool isPeeking;
  final bool isCovered;

  const _AnimatedEyes({
    required this.width,
    required this.isLookingDown,
    required this.isPeeking,
    required this.isCovered,
  });

  @override
  Widget build(BuildContext context) {
    // Gözbebeği konumu
    double pupilX = 0;
    double pupilY = 0;

    if (isLookingDown) {
      pupilY = 2; // Daha az hareket
      pupilX = 0;
    } else if (isPeeking) {
      pupilY = 1; 
    }

    return SizedBox(
      width: width, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isCovered ? _closedEye() : _singleEye(pupilX, pupilY),
          const SizedBox(width: 8),
          isCovered ? _closedEye() : _singleEye(pupilX, pupilY),
        ],
      ),
    );
  }

  Widget _closedEye() {
     return Container(
       width: 7, height: 8,
       alignment: Alignment.center,
       child: Container(
         width: 7, height: 2,
         decoration: BoxDecoration(
           color: Colors.black54,
           borderRadius: BorderRadius.circular(1)
         ),
       ),
     );
  }

  Widget _singleEye(double x, double y) {
    return Container(
      width: 7, height: 8, 
      decoration: const BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          // Göz Bebeği (Hareketli parlama)
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment(x * 0.5, isLookingDown ? 0.8 : -0.5),
            child: Container(
              width: 3, height: 3, 
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  final _MascotType type;
  _BodyPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final shadowPaint = Paint()..color = Colors.black12..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2); // Blur azaldı

    final path = Path();

    if (type == _MascotType.tomato) {
      // DOMATES
      paint.color = const Color(0xFFFF6347);
      canvas.drawCircle(Offset(size.width/2, size.height/2 + 2), size.width/2, shadowPaint);
      canvas.drawCircle(Offset(size.width/2, size.height/2), size.width/2, paint);
      
      // Yaprak
      final leafPaint = Paint()..color = const Color(0xFF4CAF50);
      path.moveTo(size.width/2, 3); 
      path.quadraticBezierTo(size.width/2 + 6, -3, size.width/2 + 8, 3);
      path.moveTo(size.width/2, 3); 
      path.quadraticBezierTo(size.width/2 - 6, -3, size.width/2 - 8, 3);
      path.addRect(Rect.fromLTWH(size.width/2 - 1, 0, 2, 4)); // Sap küçüldü
      canvas.drawPath(path, leafPaint);
    } 
    else if (type == _MascotType.potato) {
      // PATATES
      paint.color = const Color(0xFFD4AC5D);
      
      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      path.addRRect(RRect.fromRectAndCorners(rect, 
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(22),
        bottomLeft: const Radius.circular(15),
        bottomRight: const Radius.circular(20),
      ));
      
      canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);
      canvas.drawPath(path, paint);

      // Benekler
      final spotPaint = Paint()..color = Colors.black.withOpacity(0.05);
      canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 1.5, spotPaint);
      canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.6), 2, spotPaint);
      canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.8), 1, spotPaint);
    } 
    else if (type == _MascotType.carrot) {
      // HAVUÇ
      paint.color = const Color(0xFFFF9800);
      
      path.moveTo(3, 0);
      path.lineTo(size.width - 3, 0);
      path.quadraticBezierTo(size.width, size.height * 0.1, size.width - 5, size.height * 0.8);
      path.quadraticBezierTo(size.width / 2, size.height, 5, size.height * 0.8);
      path.quadraticBezierTo(0, size.height * 0.1, 3, 0);
      path.close();

      canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);
      canvas.drawPath(path, paint);

      // Çizgiler
      final linePaint = Paint()
        ..color = Colors.black12
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(Offset(size.width * 0.8, size.height * 0.2), Offset(size.width * 0.6, size.height * 0.22), linePaint);
      canvas.drawLine(Offset(size.width * 0.1, size.height * 0.4), Offset(size.width * 0.35, size.height * 0.42), linePaint);
      canvas.drawLine(Offset(size.width * 0.75, size.height * 0.6), Offset(size.width * 0.55, size.height * 0.62), linePaint);

      // Yaprak
      final leafPaint = Paint()..color = const Color(0xFF4CAF50)..style = PaintingStyle.stroke..strokeWidth=2; // İnceldi
      final leafPath = Path();
      leafPath.moveTo(size.width/2, 0);
      leafPath.lineTo(size.width/2 - 6, -10);
      leafPath.moveTo(size.width/2, 0);
      leafPath.lineTo(size.width/2, -14);
      leafPath.moveTo(size.width/2, 0);
      leafPath.lineTo(size.width/2 + 6, -10);
      canvas.drawPath(leafPath, leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BodyPainter oldDelegate) => false;
}
