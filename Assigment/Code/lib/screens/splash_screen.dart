import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Asynchronous delay of 2 seconds before navigating
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              settings.backgroundColor,
              settings.backgroundColor.withRed((settings.backgroundColor.red + 20).clamp(0, 255)),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minimalist vector origami crane
                CustomPaint(
                  size: const Size(180, 180),
                  painter: OrigamiCranePainter(primaryColor: settings.primaryColor),
                ),
                const SizedBox(height: 32),
                Text(
                  '3D ORIMASTER',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                    color: settings.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fold the World in 3D',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                // Gentle progress indicator
                SizedBox(
                  width: 140,
                  height: 3,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(settings.primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A premium custom geometric origami crane vector painter.
class OrigamiCranePainter extends CustomPainter {
  final Color primaryColor;

  OrigamiCranePainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);

    // Left Wing (darker tint of primary)
    paint.color = primaryColor.withOpacity(0.85);
    final leftWingPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - w * 0.35, center.dy - h * 0.25)
      ..lineTo(center.dx - w * 0.12, center.dy + h * 0.1)
      ..close();
    canvas.drawPath(leftWingPath, paint);

    // Right Wing (lighter tint of primary)
    paint.color = primaryColor;
    final rightWingPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + w * 0.35, center.dy - h * 0.25)
      ..lineTo(center.dx + w * 0.12, center.dy + h * 0.1)
      ..close();
    canvas.drawPath(rightWingPath, paint);

    // Neck & Head (medium opacity)
    paint.color = primaryColor.withOpacity(0.7);
    final neckPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - w * 0.25, center.dy + h * 0.15)
      ..lineTo(center.dx - w * 0.3, center.dy + h * 0.08) // beak fold
      ..lineTo(center.dx - w * 0.23, center.dy + h * 0.18)
      ..close();
    canvas.drawPath(neckPath, paint);

    // Tail (low opacity)
    paint.color = primaryColor.withOpacity(0.55);
    final tailPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + w * 0.25, center.dy + h * 0.25)
      ..lineTo(center.dx + w * 0.15, center.dy + h * 0.2)
      ..close();
    canvas.drawPath(tailPath, paint);

    // Body Center (Bright accent highlight)
    paint.color = primaryColor.withOpacity(0.95);
    final bodyPath = Path()
      ..moveTo(center.dx, center.dy - h * 0.2)
      ..lineTo(center.dx - w * 0.12, center.dy + h * 0.1)
      ..lineTo(center.dx, center.dy + h * 0.05)
      ..lineTo(center.dx + w * 0.12, center.dy + h * 0.1)
      ..close();
    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
