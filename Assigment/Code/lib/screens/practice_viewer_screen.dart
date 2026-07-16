import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import 'product_completion_screen.dart';

class PracticeViewerScreen extends StatefulWidget {
  final String modelId;
  final String modelName;
  final String modelDir;

  const PracticeViewerScreen({
    Key? key,
    required this.modelId,
    required this.modelName,
    required this.modelDir,
  }) : super(key: key);

  @override
  State<PracticeViewerScreen> createState() => _PracticeViewerScreenState();
}

class _PracticeViewerScreenState extends State<PracticeViewerScreen> {
  List<dynamic> _steps = [];
  bool _isLoadingSteps = true;
  int _currentStep = 1;
  bool _isControlsVisible = true;
  double _instructionHeight = 70.0; // Dynamic height for chevron sizing

  // Simulated 3D angles
  double _rotationX = -15.0;
  double _rotationY = 45.0;
  Offset _longPressStartPos = Offset.zero;
  double _startRotationX = 0.0;
  double _startRotationY = 0.0;
  bool _isOrbiting = false;

  @override
  void initState() {
    super.initState();
    _loadSteps();
  }

  Future<void> _loadSteps() async {
    try {
      final file = File("${widget.modelDir}/steps.json");
      if (await file.exists()) {
        final jsonStr = await file.readAsString();
        final List<dynamic> parsed = jsonDecode(jsonStr);
        setState(() {
          _steps = parsed;
          _isLoadingSteps = false;
        });
      } else {
        setState(() {
          _isLoadingSteps = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading local steps mapping: $e");
      setState(() {
        _isLoadingSteps = false;
      });
    }
  }

  void _goToPrevStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      // Lower Boundary Check: Pop back to Product Detail Screen
      Navigator.of(context).pop();
    }
  }

  void _goToNextStep() {
    if (_currentStep < _steps.length) {
      setState(() {
        _currentStep++;
      });
    } else if (_steps.isNotEmpty && _currentStep == _steps.length) {
      // Upper Boundary Check: Push navigation to Product Completion Screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductCompletionScreen(
            modelName: widget.modelName,
            modelDir: widget.modelDir,
          ),
        ),
      );
    }
  }

  void _jumpPrevStep() {
    setState(() {
      _currentStep = math.max(1, _currentStep - 3);
    });
  }

  void _jumpNextStep() {
    if (_steps.isNotEmpty) {
      setState(() {
        _currentStep = math.min(_steps.length, _currentStep + 3);
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
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

    if (_isLoadingSteps) {
      return Scaffold(
        backgroundColor: settings.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(settings.primaryColor),
          ),
        ),
      );
    }

    if (_steps.isEmpty) {
      return Scaffold(
        backgroundColor: settings.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load folding steps.', style: TextStyle(color: settings.textColor)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final currentStepData = _steps[_currentStep - 1];
    final imagePath = "${widget.modelDir}/${currentStepData['image_file']}";
    final imageFile = File(imagePath);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          
          // Swipe Right-to-Left (Velocity < 0) -> Move Forward
          if (details.primaryVelocity! < 0) {
            _goToNextStep();
          } 
          // Swipe Left-to-Right (Velocity > 0) -> Move Backward
          else if (details.primaryVelocity! > 0) {
            _goToPrevStep();
          }
        },
        child: Stack(
          children: [
            // Background Canvas Grid Pattern
            Positioned.fill(
              child: Container(
                color: settings.backgroundColor,
                child: CustomPaint(
                  painter: GridBackgroundPainter(color: settings.textColor.withOpacity(0.015)),
                ),
              ),
            ),

            // Step Content Display
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isOrbiting)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Orbiting Model: Rx ${_rotationX.toStringAsFixed(0)}° | Ry ${_rotationY.toStringAsFixed(0)}°',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Courier New',
                              color: settings.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateX(_rotationX * math.pi / 180)
                            ..rotateY(_rotationY * math.pi / 180),
                          alignment: Alignment.center,
                          child: imageFile.existsSync()
                              ? Image.file(
                                  imageFile,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.broken_image, size: 80, color: settings.textColor.withOpacity(0.3));
                                  },
                                )
                              : Icon(Icons.image, size: 80, color: settings.textColor.withOpacity(0.3)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bounding Gesture Division Layers
            Positioned.fill(
              child: Row(
                children: [
                  // Absolute Left 15% strip zone
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
                        child: Center(
                          child: Icon(Icons.arrow_back_ios, color: settings.textColor.withOpacity(0.12), size: 28),
                        ),
                      ),
                    ),
                  ),
                  // Center 70% workspace window
                  Expanded(
                    flex: 70,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _toggleControls,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  // Absolute Right 15% strip zone
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
                        child: Center(
                          child: Icon(Icons.arrow_forward_ios, color: settings.textColor.withOpacity(0.12), size: 28),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // HEADER INFO BAR overlay
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
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
                        'Step $_currentStep / ${_steps.length}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM OPTIONS & EXPANDABLE GUIDE PANEL overlay
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
                    height: _instructionHeight,
                    decoration: BoxDecoration(
                      color: settings.backgroundColor.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: settings.textColor.withOpacity(0.1)),
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
                          child: SingleChildScrollView(
                            child: Text(
                              currentStepData['instruction'] ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                color: settings.textColor.withOpacity(0.8),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Chevrons to manually stretch or shrink multiline text blocks
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _instructionHeight = math.min(150.0, _instructionHeight + 30.0);
                                });
                              },
                              child: Icon(Icons.keyboard_arrow_up, size: 16, color: settings.primaryColor),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _instructionHeight = math.max(44.0, _instructionHeight - 30.0);
                                });
                              },
                              child: Icon(Icons.keyboard_arrow_down, size: 16, color: settings.primaryColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Footer control bar
                  Container(
                    color: Colors.black.withOpacity(0.8),
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.rotate_left, size: 16, color: Colors.white70),
                          label: const Text('Reset Angle', style: TextStyle(fontSize: 11, color: Colors.white70)),
                          onPressed: () {
                            setState(() {
                              _rotationX = -15.0;
                              _rotationY = 45.0;
                            });
                          },
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous, color: Colors.white54),
                              onPressed: _goToPrevStep,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Step $_currentStep / ${_steps.length}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.skip_next, color: Colors.white),
                              onPressed: _goToNextStep,
                            ),
                          ],
                        ),
                        Text(
                          'Drag edge to Orbit | Double tap to Jump',
                          style: TextStyle(color: settings.textColor.withOpacity(0.38), fontSize: 9, fontStyle: FontStyle.italic),
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

class GridBackgroundPainter extends CustomPainter {
  final Color color;
  GridBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
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
