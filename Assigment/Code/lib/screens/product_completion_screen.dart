import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import 'dashboard_screen.dart';
import 'practice_viewer_screen.dart'; // to reuse grid background and 3D painter

class ProductCompletionScreen extends StatefulWidget {
  final String modelName;

  const ProductCompletionScreen({
    Key? key,
    required this.modelName,
  }) : super(key: key);

  @override
  State<ProductCompletionScreen> createState() => _ProductCompletionScreenState();
}

class _ProductCompletionScreenState extends State<ProductCompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    // Continuous rotation for the 3D showcase model
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _backToHome() {
    // Drop the route pointer back to the Home Dashboard view resetting navigation states
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background grid
          Positioned.fill(
            child: Container(
              color: settings.backgroundColor,
              child: const CustomGridBackgroundLines(),
            ),
          ),

          // Central viewport content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left Side: Large auto-rotating 3D model
                    Expanded(
                      flex: 45,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            // Map vertical tilt slightly and let horizontal rotate continuously
                            final double angleY = _rotationController.value * 2 * math.pi;
                            const double angleX = -20 * math.pi / 180.0;

                            return Container(
                              width: 280,
                              height: 280,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: settings.primaryColor.withOpacity(0.06),
                                    blurRadius: 50,
                                    spreadRadius: 10,
                                  )
                                ],
                              ),
                              child: CustomPaint(
                                painter: Origami3DModelPainter(
                                  paperColor: settings.paperColor,
                                  rotX: angleX,
                                  rotY: angleY,
                                  step: 8, // finished crane model
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 40),

                    // Right Side: Notice text, congratulations and home button
                    Expanded(
                      flex: 55,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'STRUCTURE COMPLETED',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.greenAccent,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Masterpiece Unveiled!',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: settings.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You have successfully folded the "${widget.modelName}". Keep practicing to master other traditional and modular models.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Notice placeholder label block text
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white12, width: 0.8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: settings.primaryColor, size: 16),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    "Màn hình hiển thị 3D, tính năng hiện đang phát triển.",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 10.5,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Centered primary action button
                          SizedBox(
                            width: 220,
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: settings.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _backToHome,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.home, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Trở về Trang chủ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
