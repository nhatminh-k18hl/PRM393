import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import 'product_completion_screen.dart';

class PracticeViewerScreen extends StatefulWidget {
  final String modelName;
  final Color paperColor;
  final int totalSteps;

  const PracticeViewerScreen({
    Key? key,
    required this.modelName,
    required this.paperColor,
    required this.totalSteps,
  }) : super(key: key);

  @override
  State<PracticeViewerScreen> createState() => _PracticeViewerScreenState();
}

class _PracticeViewerScreenState extends State<PracticeViewerScreen> {
  int _currentStep = 1;
  bool _isControlsVisible = true;
  bool _isInstructionsExpanded = false;

  // 3D rotation angles (in degrees)
  double _rotationX = -15.0;
  double _rotationY = 45.0;

  // Gesture tracking variables
  Offset _longPressStartPos = Offset.zero;
  double _startRotationX = 0.0;
  double _startRotationY = 0.0;
  bool _isOrbiting = false;

  // Hardcoded folding steps database
  final List<String> _stepInstructions = [
    "Step 1: Place the square paper colored side up. Valley-fold diagonally in half to form a triangle, crease sharply, then unfold back to square.",
    "Step 2: Fold along the opposite diagonal corners, crease the crease-line firmly, then unfold. You should see an 'X' crease pattern.",
    "Step 3: Flip the paper over. Fold in half horizontally and vertically, making sharp creases, then unfold both folds completely.",
    "Step 4: Bring all 4 corners of the paper together to form a square base. The diagonal folds should collapse inwards naturally.",
    "Step 5: Fold the left and right lower edges of the top flap to meet the central vertical crease line. Crease the folds firmly.",
    "Step 6: Fold the top triangle downwards over the side flaps to create a horizontal fold crease. Unfold these 3 folds back to the square base.",
    "Step 7: Perform a petal fold by lifting the bottom corner of the top flap upwards. Press the sides inwards along the creases to flatten.",
    "Step 8: Reverse-fold the narrow neck and tail sections upwards. Fold the wings outwards and down to finalize the origami master shape!"
  ];

  void _goToPrevStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      _showTemporaryFeedback("Step $_currentStep");
    }
  }

  void _goToNextStep() {
    if (_currentStep < widget.totalSteps) {
      setState(() {
        _currentStep++;
      });
      _showTemporaryFeedback("Step $_currentStep");
    } else {
      // Reached maximum step size, navigate to completion screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProductCompletionScreen(modelName: widget.modelName),
        ),
      );
    }
  }

  void _jumpPrevStep() {
    setState(() {
      _currentStep = math.max(1, _currentStep - 3);
    });
    _showTemporaryFeedback("Jumped Back: Step $_currentStep");
  }

  void _jumpNextStep() {
    if (_currentStep == widget.totalSteps) {
      _goToNextStep();
    } else {
      setState(() {
        _currentStep = math.min(widget.totalSteps, _currentStep + 3);
      });
      _showTemporaryFeedback("Jumped Forward: Step $_currentStep");
    }
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
  }

  void _showTemporaryFeedback(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(milliseconds: 600),
        behavior: SnackBarBehavior.floating,
        width: 180,
        backgroundColor: Colors.black.withOpacity(0.85),
      ),
    );
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _longPressStartPos = details.globalPosition;
      _startRotationX = _rotationX;
      _startRotationY = _rotationY;
      _isOrbiting = true;
    });
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    final delta = details.globalPosition - _longPressStartPos;
    setState(() {
      // 0.4 degree sensitivity per pixel movement
      _rotationX = _startRotationX + delta.dy * 0.4;
      _rotationY = _startRotationY + delta.dx * 0.4;
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _isOrbiting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    // Convert degrees to radians for painter
    final radX = _rotationX * math.pi / 180.0;
    final radY = _rotationY * math.pi / 180.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        
        // Right-to-Left Swipe (Velocity < 0 / Swipe Left Event) -> Move Forward
        if (details.primaryVelocity! < 0) {
          if (_currentStep == widget.totalSteps) {
            // Upper Boundary Check: Push navigation to Product Completion Screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductCompletionScreen(modelName: widget.modelName),
              ),
            );
          } else {
            _goToNextStep();
          }
        } 
        // Left-to-Right Swipe (Velocity > 0 / Swipe Right Event) -> Move Backward
        else if (details.primaryVelocity! > 0) {
          if (_currentStep == 1) {
            // Lower Boundary Check: Pop back to Product Detail Screen
            Navigator.of(context).pop();
          } else {
            _goToPrevStep();
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // BASE LAYER: Interactive 3D render area container reacting to paperColor
            Positioned.fill(
              child: Container(
                color: settings.backgroundColor,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Abstract geometric background lines
                    const Positioned.fill(child: CustomGridBackgroundLines()),
                    // Rotation angle debug readouts (premium tech touch)
                    if (_isOrbiting)
                      Positioned(
                        top: 60,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: settings.primaryColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            'Orbit Mode: Rx ${_rotationX.toStringAsFixed(1)}° | Ry ${_rotationY.toStringAsFixed(1)}°',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Courier New',
                              color: settings.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Real-time custom 3D painter representing the origami model
                    Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: settings.primaryColor.withOpacity(0.04),
                            blurRadius: 40,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: CustomPaint(
                        painter: Origami3DModelPainter(
                          paperColor: settings.paperColor,
                          rotX: radX,
                          rotY: radY,
                          step: _currentStep,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
  
            // INVISIBLE GESTURE TOUCH ZONES OVERLAY LAYER
            Positioned.fill(
              child: Row(
                children: [
                  // Far-left 15% bounding width
                  Expanded(
                    flex: 15,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _goToPrevStep,
                      onDoubleTap: _jumpPrevStep,
                      onLongPressStart: _onLongPressStart,
                      onLongPressMoveUpdate: _onLongPressMoveUpdate,
                      onLongPressEnd: _onLongPressEnd,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.08), Colors.transparent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_back_ios, color: Colors.white12, size: 28),
                        ),
                      ),
                    ),
                  ),
                  // Center 70% workspace area
                  Expanded(
                    flex: 70,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _toggleControls,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  // Far-right 15% bounding width
                  Expanded(
                    flex: 15,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _goToNextStep,
                      onDoubleTap: _jumpNextStep,
                      onLongPressStart: _onLongPressStart,
                      onLongPressMoveUpdate: _onLongPressMoveUpdate,
                      onLongPressEnd: _onLongPressEnd,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withOpacity(0.08)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 28),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
  
            // HEADER INFORMATION STRIP BAR (Toggled dynamically)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              top: _isControlsVisible ? 0 : -80,
              left: 0,
              right: 0,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.75), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.modelName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: settings.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: settings.primaryColor.withOpacity(0.4), width: 1),
                      ),
                      child: Text(
                        'Step $_currentStep / ${widget.totalSteps}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
  
            // BOTTOM CONTROL OPTIONS & EXPANDABLE GUIDE PANEL
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              bottom: _isControlsVisible ? 0 : -140,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Expandable Instruction Box
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    height: _isInstructionsExpanded ? 85 : 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.menu_book, color: settings.primaryColor, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _currentStep <= _stepInstructions.length
                                ? _stepInstructions[_currentStep - 1]
                                : "Continue to complete the structure model.",
                            maxLines: _isInstructionsExpanded ? 3 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Colors.white70, height: 1.35),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Arrow expand toggle
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isInstructionsExpanded = !_isInstructionsExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isInstructionsExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                              color: settings.primaryColor,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
  
                  // Footer option row (Previous, Steps, Orbit resetting)
                  Container(
                    color: Colors.black.withOpacity(0.8),
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.rotate_left, size: 16),
                          label: const Text('Reset Angle', style: TextStyle(fontSize: 11)),
                          style: TextButton.styleFrom(foregroundColor: Colors.white70),
                          onPressed: () {
                            setState(() {
                              _rotationX = -15.0;
                              _rotationY = 45.0;
                            });
                            _showTemporaryFeedback("Camera Reset");
                          },
                        ),
                        // Navigation indicator row
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous, color: Colors.white54),
                              onPressed: _goToPrevStep,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Step $_currentStep / ${widget.totalSteps}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.skip_next, color: Colors.white),
                              onPressed: _goToNextStep,
                            ),
                          ],
                        ),
                        // Help indicator
                        const Text(
                          'Drag edges to Orbit | Double tap to Jump',
                          style: TextStyle(color: Colors.white38, fontSize: 9, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Abstract custom painter that performs genuine 3D projections.
/// Adapts rendered geometry based on active folding index steps.
class Origami3DModelPainter extends CustomPainter {
  final Color paperColor;
  final double rotX;
  final double rotY;
  final int step;

  Origami3DModelPainter({
    required this.paperColor,
    required this.rotX,
    required this.rotY,
    required this.step,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // We build different geometric 3D shapes representing folding progression!
    // As step increases, the geometry collapses and becomes more detailed/complex.
    final List<List<double>> vertices = [];
    final List<List<int>> faces = [];
    final List<double> lightModifiers = [0.95, 0.85, 0.75, 0.65, 0.55, 0.45];

    if (step <= 2) {
      // Step 1-2: A simple flat square sheet with a single fold representation
      // We draw it slightly bent in 3D
      double foldAngle = step == 1 ? 0.0 : 0.4; // flat or slightly folded
      vertices.addAll([
        [-80, 0, -80],                      // 0: Top Left
        [80, 0, -80],                       // 1: Top Right
        [80, 0, 80],                        // 2: Bottom Right
        [-80, 0, 80],                       // 3: Bottom Left
        [0, -40 * math.sin(foldAngle), 0],   // 4: Central Crease Point
      ]);

      faces.addAll([
        [0, 1, 4], // face 1
        [1, 2, 4], // face 2
        [2, 3, 4], // face 3
        [3, 0, 4], // face 4
      ]);
    } else if (step <= 4) {
      // Step 3-4: Paper collapsing into an intermediate square base
      // An elegant 3D double pyramid
      double collapse = step == 3 ? 0.5 : 1.0;
      double sizeFactor = 80.0 - (20 * collapse);
      vertices.addAll([
        [0, -sizeFactor, 0],                            // 0: Top Point
        [0, sizeFactor, 0],                             // 1: Bottom Point
        [-sizeFactor, 0, -30 * collapse],               // 2: Left
        [sizeFactor, 0, -30 * collapse],                // 3: Right
        [0, 0, sizeFactor * 0.9 * collapse],            // 4: Front
        [0, 0, -sizeFactor * 0.9 * collapse],           // 5: Back
      ]);

      faces.addAll([
        [0, 2, 4], // Top Left Front
        [0, 4, 3], // Top Right Front
        [1, 2, 4], // Bottom Left Front
        [1, 4, 3], // Bottom Right Front
        [0, 2, 5], // Top Left Back
        [0, 5, 3], // Top Right Back
        [1, 2, 5], // Bottom Left Back
        [1, 5, 3], // Bottom Right Back
      ]);
    } else if (step <= 6) {
      // Step 5-6: Folding sides to center.
      // An elegant diamond with flaps folded in
      vertices.addAll([
        [0, -90, 0],    // 0: Top
        [0, 90, 0],     // 1: Bottom
        [-35, 0, 20],   // 2: Left fold
        [35, 0, 20],    // 3: Right fold
        [-65, 0, -30],  // 4: Left back
        [65, 0, -30],   // 5: Right back
        [0, 0, 55],     // 6: Nose
      ]);

      faces.addAll([
        [0, 2, 6],
        [0, 6, 3],
        [1, 2, 6],
        [1, 6, 3],
        [0, 4, 2],
        [0, 5, 3],
        [1, 4, 2],
        [1, 5, 3],
      ]);
    } else {
      // Step 7-8: Complete 3D Folded Crane vector representation
      vertices.addAll([
        [0, -95, 0],     // 0: Top Head
        [0, 80, 0],      // 1: Base Body
        [-110, -30, 0],  // 2: Left Wing tip
        [110, -30, 0],   // 3: Right Wing tip
        [-70, 40, -40],  // 4: Neck head fold
        [70, 50, -40],   // 5: Tail fold
        [0, 0, 35],      // 6: Front breast
        [0, 0, -35],     // 7: Back back
      ]);

      faces.addAll([
        [0, 2, 6], // left wing front
        [0, 6, 3], // right wing front
        [1, 2, 6], // left body bottom
        [1, 6, 3], // right body bottom
        [0, 4, 6], // neck fold front
        [0, 5, 6], // tail fold front
        [0, 2, 7], // left wing back
        [0, 7, 3], // right wing back
        [1, 2, 7], // body back bottom
        [1, 7, 3], // body back bottom
      ]);
    }

    // PROJECT & ROTATE VERTICES
    final List<Offset> projected = [];
    final List<double> depths = [];

    final double cosX = math.cos(rotX);
    final double sinX = math.sin(rotX);
    final double cosY = math.cos(rotY);
    final double sinY = math.sin(rotY);

    for (var vertex in vertices) {
      double x = vertex[0];
      double y = vertex[1];
      double z = vertex[2];

      // Rotate X axis
      double y1 = y * cosX - z * sinX;
      double z1 = y * sinX + z * cosX;

      // Rotate Y axis
      double x2 = x * cosY + z1 * sinY;
      double z2 = -x * sinY + z1 * cosY;

      // Perspective scale factor
      double perspective = 320.0 / (320.0 - z2);
      double px = cx + x2 * perspective;
      double py = cy + y1 * perspective;

      projected.add(Offset(px, py));
      depths.add(z2);
    }

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white24
      ..strokeWidth = 1.0;

    // Sort faces according to average depth (Painter's algorithm)
    final List<MapEntry<int, double>> sortedFaces = [];
    for (int i = 0; i < faces.length; i++) {
      final face = faces[i];
      double avgDepth = (depths[face[0]] + depths[face[1]] + depths[face[2]]) / 3.0;
      sortedFaces.add(MapEntry(i, avgDepth));
    }
    sortedFaces.sort((a, b) => a.value.compareTo(b.value));

    // Paint faces
    for (var entry in sortedFaces) {
      final int faceIdx = entry.key;
      final face = faces[faceIdx];

      final path = Path()
        ..moveTo(projected[face[0]].dx, projected[face[0]].dy)
        ..lineTo(projected[face[1]].dx, projected[face[1]].dy)
        ..lineTo(projected[face[2]].dx, projected[face[2]].dy)
        ..close();

      // Light shade calculations
      final shadeIdx = faceIdx % lightModifiers.length;
      final double mod = lightModifiers[shadeIdx];

      fillPaint.color = paperColor
          .withRed((paperColor.red * mod).toInt().clamp(0, 255))
          .withGreen((paperColor.green * mod).toInt().clamp(0, 255))
          .withBlue((paperColor.blue * mod).toInt().clamp(0, 255));

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant Origami3DModelPainter oldDelegate) {
    return oldDelegate.paperColor != paperColor ||
        oldDelegate.rotX != rotX ||
        oldDelegate.rotY != rotY ||
        oldDelegate.step != step;
  }
}

class CustomGridBackgroundLines extends StatelessWidget {
  const CustomGridBackgroundLines({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridBackgroundPainter(),
    );
  }
}

class GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 0.8;

    const double sizeFactor = 30.0;
    for (double i = 0; i < size.width; i += sizeFactor) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += sizeFactor) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
