import 'dart:math' as math;
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  final String vibeType; // 'BUBBLES', 'HORROR_ASH', 'LEAVES', 'SWALLOWS', 'SPARKS'

  const ParticleBackground({
    super.key,
    required this.vibeType,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();
  Size _screenSize = Size.zero;

  // Giant shape variables (whale, butterfly, maple leaf, swallow)
  double _giantShapeProgress = 0.0;
  bool _isGiantShapeActive = false;
  String _giantShapeType = 'none'; // 'whale', 'butterfly', 'maple_leaf', 'swallow'
  int _tickCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _controller.addListener(_updateSystem);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateSystem);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ParticleBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vibeType != widget.vibeType) {
      _initParticles();
      // Reset giant shape to let it trigger for the new vibe
      _isGiantShapeActive = false;
      _tickCount = 0;
    }
  }

  void _initParticles() {
    if (_screenSize == Size.zero) return;
    _particles.clear();
    int count = 20;
    if (widget.vibeType == 'LEAVES' || widget.vibeType == 'BUBBLES') count = 25;
    if (widget.vibeType == 'SWALLOWS') count = 10;

    for (int i = 0; i < count; i++) {
      _particles.add(_generateParticle(initial: true));
    }
  }

  _Particle _generateParticle({bool initial = false}) {
    final double x = _random.nextDouble() * _screenSize.width;
    final double y = initial
        ? _random.nextDouble() * _screenSize.height
        : (widget.vibeType == 'BUBBLES' ? _screenSize.height + 20 : -20);

    double size = 4.0 + _random.nextDouble() * 10.0;
    if (widget.vibeType == 'SWALLOWS') {
      size = 14.0 + _random.nextDouble() * 12.0;
    }

    double speed = 0.4 + _random.nextDouble() * 1.5;
    double angle = _random.nextDouble() * math.pi * 2;
    double driftSpeed = 0.15 + _random.nextDouble() * 0.65;

    Color color;
    switch (widget.vibeType) {
      case 'BUBBLES':
        color = const Color(0xFF00FFCC);
        break;
      case 'HORROR_ASH':
        color = const Color(0xFFEF4444);
        break;
      case 'LEAVES':
        final r = _random.nextInt(3);
        if (r == 0) {
          color = const Color(0xFFF59E0B);
        } else if (r == 1) {
          color = const Color(0xFFEA580C);
        } else {
          color = const Color(0xFF78350F);
        }
        break;
      case 'SWALLOWS':
        color = const Color(0xFF2C3E2B);
        break;
      case 'SPARKS':
      default:
        color = const Color(0xFFFFE29A);
        break;
    }

    return _Particle(
      x: x,
      y: y,
      size: size,
      speed: speed,
      angle: angle,
      driftSpeed: driftSpeed,
      color: color,
    );
  }

  void _updateSystem() {
    if (_screenSize == Size.zero) return;

    setState(() {
      // 1. Update giant shape timer & progress
      _tickCount++;
      
      // Trigger giant shape every ~30 seconds (30s * 60 FPS = 1800 ticks)
      if (!_isGiantShapeActive && _tickCount >= 1200) { // Using 1200 ticks (~20s) for faster showcase verification
        _isGiantShapeActive = true;
        _giantShapeProgress = 0.0;
        _tickCount = 0;
        
        // Match giant shape type to the active vibe
        if (widget.vibeType == 'BUBBLES') {
          _giantShapeType = 'butterfly';
        } else if (widget.vibeType == 'HORROR_ASH' || widget.vibeType == 'SPARKS') {
          _giantShapeType = 'whale';
        } else if (widget.vibeType == 'LEAVES') {
          _giantShapeType = 'maple_leaf';
        } else if (widget.vibeType == 'SWALLOWS') {
          _giantShapeType = 'swallow';
        }
      }

      if (_isGiantShapeActive) {
        // Increment progress. Takes about 8 seconds to cross (0.0025 * 400 frames)
        _giantShapeProgress += 0.0025;
        if (_giantShapeProgress >= 1.0) {
          _isGiantShapeActive = false;
          _tickCount = 0;
        }
      }

      // 2. Update normal background particles
      for (int i = 0; i < _particles.length; i++) {
        final p = _particles[i];
        p.angle += 0.015;

        switch (widget.vibeType) {
          case 'BUBBLES':
            p.y -= p.speed * 0.9;
            p.x += math.sin(p.angle) * p.driftSpeed * 0.8;
            if (p.y < -p.size) {
              _particles[i] = _generateParticle();
            }
            break;

          case 'HORROR_ASH':
            p.y += p.speed * 0.7;
            p.x += math.cos(p.angle) * p.driftSpeed * 0.4;
            if (p.y > _screenSize.height + p.size) {
              _particles[i] = _generateParticle();
            }
            break;

          case 'LEAVES':
            p.y += p.speed * 0.8;
            p.x += math.sin(p.angle) * p.driftSpeed * 1.2;
            if (p.y > _screenSize.height + p.size) {
              _particles[i] = _generateParticle();
            }
            break;

          case 'SWALLOWS':
            // Small swallows flying left
            p.x -= p.speed * 1.2;
            p.y += math.sin(p.angle) * p.driftSpeed * 0.4;
            if (p.x < -p.size) {
              _particles[i] = _generateParticle();
              _particles[i].x = _screenSize.width + 20;
            }
            break;

          case 'SPARKS':
          default:
            p.y -= p.speed * 0.4;
            p.x += math.sin(p.angle) * p.driftSpeed * 0.2;
            if (p.y < -p.size) {
              _particles[i] = _generateParticle();
            }
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (_screenSize != size) {
          _screenSize = size;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initParticles();
          });
        }

        return CustomPaint(
          size: size,
          painter: _ParticlePainter(
            particles: _particles,
            vibeType: widget.vibeType,
            giantShapeProgress: _giantShapeProgress,
            isGiantShapeActive: _isGiantShapeActive,
            giantShapeType: _giantShapeType,
          ),
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double angle;
  double driftSpeed;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.driftSpeed,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final String vibeType;
  final double giantShapeProgress;
  final bool isGiantShapeActive;
  final String giantShapeType;

  _ParticlePainter({
    required this.particles,
    required this.vibeType,
    required this.giantShapeProgress,
    required this.isGiantShapeActive,
    required this.giantShapeType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Draw giant mathematical shape watermark overlays chìm (Opacity 0.015 - 0.02)
    if (isGiantShapeActive) {
      _drawGiantShape(canvas, size);
    }

    // 2. Draw regular particles
    for (final p in particles) {
      paint.color = p.color.withOpacity(0.015); // Strict 0.015 - 0.02 opacity

      if (vibeType == 'BUBBLES') {
        final strokePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = p.color.withOpacity(0.025);
        canvas.drawCircle(Offset(p.x, p.y), p.size, strokePaint);
        canvas.drawCircle(Offset(p.x - p.size / 3, p.y - p.size / 3), p.size / 6, paint);
      } else if (vibeType == 'LEAVES') {
        canvas.save();
        canvas.translate(p.x, p.y);
        canvas.rotate(p.angle);
        
        final path = Path();
        path.moveTo(0, -p.size);
        path.quadraticBezierTo(p.size, -p.size / 2, 0, p.size);
        path.quadraticBezierTo(-p.size, p.size / 2, 0, -p.size);
        
        canvas.drawPath(path, paint);
        canvas.restore();
      } else if (vibeType == 'SWALLOWS') {
        canvas.save();
        canvas.translate(p.x, p.y);
        canvas.rotate(0.3);
        
        final path = Path();
        path.moveTo(-p.size / 2, 0);
        path.quadraticBezierTo(-p.size / 4, -p.size / 4, 0, -p.size * 0.1);
        path.quadraticBezierTo(p.size / 4, -p.size / 4, p.size / 2, 0);
        path.quadraticBezierTo(0, -p.size * 0.35, -p.size / 2, 0);
        
        canvas.drawPath(path, paint);
        canvas.restore();
      } else {
        canvas.drawCircle(Offset(p.x, p.y), p.size / 2, paint);
      }
    }
  }

  void _drawGiantShape(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Fading in and out mathematically using a sine wave
    final opacity = (math.sin(giantShapeProgress * math.pi) * 0.018).clamp(0.0, 0.02);
    
    canvas.save();

    if (giantShapeType == 'whale') {
      // Whale swims left to right along a sine wave
      final double x = -200 + (size.width + 400) * giantShapeProgress;
      final double y = size.height * 0.5 + math.sin(giantShapeProgress * math.pi * 2) * 60;
      
      paint.color = const Color(0xFF0284C7).withOpacity(opacity);
      canvas.translate(x, y);
      canvas.scale(1.2); // Large whale size

      final path = Path();
      path.moveTo(-100, 0);
      path.quadraticBezierTo(0, -50, 80, -20); // Back
      path.quadraticBezierTo(120, -10, 140, -35); // Upper tail fin
      path.lineTo(140, 15); // End fin
      path.quadraticBezierTo(120, 0, 85, 10); // Lower tail fin
      path.quadraticBezierTo(30, 35, -50, 15); // Belly
      path.quadraticBezierTo(-85, 12, -100, 0);
      path.close();
      canvas.drawPath(path, paint);

    } else if (giantShapeType == 'butterfly') {
      // Butterfly flies upwards and sideways
      final double x = size.width * 0.2 + (size.width * 0.6) * giantShapeProgress;
      final double y = size.height + 100 - (size.height + 200) * giantShapeProgress;
      
      paint.color = const Color(0xFF00FFCC).withOpacity(opacity);
      canvas.translate(x, y);
      canvas.rotate(math.sin(giantShapeProgress * math.pi * 4) * 0.2); // Wing flutter rotate
      canvas.scale(1.4);

      final path = Path();
      path.moveTo(0, 0);
      // Left wings
      path.cubicTo(-35, -50, -70, -15, -10, 0);
      path.cubicTo(-50, 35, -15, 50, 0, 10);
      // Right wings
      path.cubicTo(15, 50, 50, 35, 10, 0);
      path.cubicTo(70, -15, 35, -50, 0, 0);
      path.close();
      canvas.drawPath(path, paint);

    } else if (giantShapeType == 'maple_leaf') {
      // Maple leaf falls down and spins
      final double x = size.width * 0.7 - (size.width * 0.5) * giantShapeProgress;
      final double y = -100 + (size.height + 200) * giantShapeProgress;
      final double rotation = giantShapeProgress * math.pi * 4; // Multi-rotation spin
      
      paint.color = const Color(0xFFEA580C).withOpacity(opacity);
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.scale(1.5);

      final path = Path();
      path.moveTo(0, -40); // Top tip
      path.lineTo(8, -15);
      path.lineTo(30, -25); // Right top tip
      path.lineTo(20, -5);
      path.lineTo(40, 10); // Right bottom tip
      path.lineTo(15, 10);
      path.lineTo(25, 35); // Bottom right
      path.lineTo(0, 22); // Stem
      path.lineTo(-25, 35); // Bottom left
      path.lineTo(-15, 10);
      path.lineTo(-40, 10); // Left bottom tip
      path.lineTo(-20, -5);
      path.lineTo(-30, -25); // Left top tip
      path.lineTo(-8, -15);
      path.close();
      canvas.drawPath(path, paint);

    } else if (giantShapeType == 'swallow') {
      // Solitary swallow flies left to right quickly
      final double x = size.width + 150 - (size.width + 300) * giantShapeProgress;
      final double y = size.height * 0.35 + math.sin(giantShapeProgress * math.pi * 3) * 40;
      
      paint.color = const Color(0xFF526E52).withOpacity(opacity);
      canvas.translate(x, y);
      canvas.scale(1.8);

      final path = Path();
      path.moveTo(-60, 0);
      path.quadraticBezierTo(-30, -30, 0, -8); // Left wing
      path.quadraticBezierTo(30, -30, 60, 0); // Right wing
      path.quadraticBezierTo(0, -45, -60, 0);
      path.moveTo(0, -8);
      path.quadraticBezierTo(0, 15, 8, 35); // Tail left
      path.lineTo(0, 22);
      path.lineTo(-8, 35); // Tail right
      path.quadraticBezierTo(0, 15, 0, -8);
      path.close();
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
