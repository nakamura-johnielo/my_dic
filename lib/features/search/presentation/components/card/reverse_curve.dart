import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// 使用例
/* 
CustomPaint(
  size: Size(16, 16),
  painter: NotchCornerPainter(
    color: Colors.blue,
    notchOffset: Offset(2, -1), // 微調整
  ),
)
 */

class NotchCornerWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Offset notchOffset; // 微調整用
  final double notchRadius;

  const NotchCornerWidget({
    super.key,
    this.width = 16.0,
    this.height = 16.0,
    this.color = const Color.fromARGB(255, 157, 157, 157),
    this.notchOffset = Offset.zero,
    this.notchRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: NotchCornerPainter(
        color: color,
        notchOffset: notchOffset,
        notchRadius: notchRadius, // 微調整
      ),
    );
  }
}

class NotchCornerPainter extends CustomPainter {
  final Color color;
  final double notchRadius;
  final Offset notchOffset; // 微調整用

  NotchCornerPainter({
    required this.color,
    required this.notchRadius,
    required this.notchOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - notchOffset.dy)
      ..lineTo(size.width - notchOffset.dx, size.height - notchOffset.dy)
      ..arcToPoint(
        Offset(0, 0),
        radius: Radius.circular(notchRadius),
        //clockwise: false,
      )
      ..close();

    canvas.drawPath(path, paint);

    // ストローク 接合部分の隙間消し
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final strokePath = Path()
      ..moveTo(-1, 0)
      ..lineTo(-1, 1 + size.height - notchOffset.dy)
      ..lineTo(size.width - notchOffset.dx, 1 + size.height - notchOffset.dy);

    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(NotchCornerPainter oldDelegate) =>
      color != oldDelegate.color ||
      notchRadius != oldDelegate.notchRadius ||
      notchOffset != oldDelegate.notchOffset;
}

// class NotchCornerPainter extends CustomPainter {
//   final Color color;
//   final double notchRadius;
//   final Offset notchOffset; // 微調整用

//   NotchCornerPainter({
//     required this.color,
//     required this.notchRadius,
//     required this.notchOffset,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;

//     final path = Path()
//       ..moveTo(0, 0)
//       ..lineTo(size.width - notchRadius + notchOffset.dx, 0)
//       ..arcToPoint(
//         Offset(size.width, notchRadius + notchOffset.dy),
//         radius: Radius.circular(notchRadius),
//         clockwise: false,
//       )
//       ..lineTo(size.width, size.height)
//       ..lineTo(0, size.height)
//       ..close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(NotchCornerPainter oldDelegate) =>
//       color != oldDelegate.color ||
//       notchRadius != oldDelegate.notchRadius ||
//       notchOffset != oldDelegate.notchOffset;
// }
