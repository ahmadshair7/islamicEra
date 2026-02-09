import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../../../core/theme.dart';
import '../../../core/utils/qibla_utils.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _hasCheckedSupport = false;
  bool _supportsSensors = false;
  Position? _currentPosition;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initQibla();
  }

  Future<void> _initQibla() async {
    try {
      if (!kIsWeb) {
        _supportsSensors = (await FlutterQiblah.androidDeviceSensorSupport()) ?? false;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        _currentPosition = await Geolocator.getCurrentPosition();
      } else {
        _error = "Location permission denied. Cannot calculate Qibla.";
      }
    } catch (e) {
      _error = "Initialization error: $e";
    } finally {
      setState(() {
        _hasCheckedSupport = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Qibla Compass'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.dark : AppGradients.primary,
        ),
        child: Stack(
          children: [
            // Decorative backdrop
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: !_hasCheckedSupport
                  ? Center(child: CircularProgressIndicator(color: AppColors.accent))
                  : _error != null
                      ? _buildErrorUI()
                      : _buildCompassUI(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _initQibla, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassUI() {
    bool isWeb = kIsWeb;
    
    if (_supportsSensors && !isWeb) {
      return StreamBuilder<QiblahDirection>(
        stream: FlutterQiblah.qiblahStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.accent));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
          }
          if (!snapshot.hasData) return const Center(child: Text("No data", style: TextStyle(color: Colors.white70)));

          final qiblaData = snapshot.data!;
          
          // Use our custom accurate Qibla calculation instead of the package's calculation
          // This uses Google Qibla Finder's precise Kaaba coordinates
          final accurateQiblaDirection = _currentPosition != null
              ? QiblaUtils.calculateQiblaDirection(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                )
              : qiblaData.qiblah; // Fallback to package calculation if no position
          
          return ModernCompass(
            direction: qiblaData.direction,
            qibla: accurateQiblaDirection,
          );
        },
      );
    } else {
      // Manual calculation for Web or devices without sensors
      if (_currentPosition == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.accent),
              const SizedBox(height: 20),
              const Text("Calibrating Location...", style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        );
      }
      
      final qiblaAngle = QiblaUtils.calculateQiblaDirection(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Static Mode (Web/No Sensors)",
                      style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Qibla is at ${qiblaAngle.toStringAsFixed(1)}° from North",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Turn your device towards this angle manually",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ModernCompass(
                direction: 0, // static north
                qibla: qiblaAngle,
                isStatic: true,
              ),
            ],
          ),
        ),
      );
    }
  }
}

class ModernCompass extends StatelessWidget {
  final double direction;
  final double qibla;
  final bool isStatic;

  const ModernCompass({
    super.key,
    required this.direction,
    required this.qibla,
    this.isStatic = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if aligned (within 5 degrees)
    final diff = (qibla - direction).abs() % 360;
    final isAligned = diff < 5 || diff > 355;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Alignment Indicator
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isAligned ? 1.0 : 0.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.black87, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    "PERFECTLY ALIGNED",
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow
              Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      isAligned ? AppColors.accent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Outer Ring (Glassmorphic)
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
              ),
              // Compass Card (Rotates)
              Transform.rotate(
                angle: (direction * (math.pi / 180) * -1),
                child: CustomPaint(
                  size: const Size(260, 260),
                  painter: CompassPainter(isAligned: isAligned),
                ),
              ),
              // Qibla Indicator (Kaaba Needle)
              Transform.rotate(
                angle: ((qibla - direction) * (math.pi / 180)),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                         Padding(
                           padding: const EdgeInsets.only(top: 10.0),
                           child: Icon(
                            Icons.mosque, 
                            color: isAligned ? AppColors.accent : Colors.white70, 
                            size: 44
                          ),
                         ),
                        if (isAligned)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 1.0, end: 1.4),
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 2),
                                  ),
                                ),
                              );
                            },
                            onEnd: () {}, // Repeat logic usually here
                          ),
                      ],
                    ),
                    Container(
                      height: 100,
                      width: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            isAligned ? AppColors.accent : Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              // Center Point
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isAligned ? AppColors.accent : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5)
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          if (!isStatic)
            Text(
              "${direction.toInt()}°",
              style: const TextStyle(
                fontSize: 48, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          Text(
             isStatic ? "MANUAL VIEW" : "COMPASS HEADING",
             style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  final bool isAligned;
  CompassPainter({this.isAligned = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    // ignore: unused_local_variable
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw cardinal points
    final textStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18);
    final cardinals = {'N': 0, 'E': 90, 'S': 180, 'W': 270};

    for (var entry in cardinals.entries) {
      final angle = (entry.value - 90) * math.pi / 180;
      final offset = Offset(
        center.dx + (radius - 30) * math.cos(angle),
        center.dy + (radius - 30) * math.sin(angle),
      );
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: entry.key, 
          style: entry.key == 'N' 
              ? textStyle.copyWith(color: isAligned ? AppColors.accent : Colors.redAccent) 
              : textStyle
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2));
    }

    // Draw ticks
    for (int i = 0; i < 360; i += 10) {
      final angle = i * math.pi / 180;
      final isMajor = i % 90 == 0;
      final isMedium = i % 30 == 0;
      final tickLength = isMajor ? 15.0 : (isMedium ? 10.0 : 6.0);
      
      final tickPaint = Paint()
        ..color = isMajor 
            ? (isAligned ? AppColors.accent : Colors.white) 
            : Colors.white.withOpacity(0.4)
        ..strokeWidth = isMajor ? 3 : (isMedium ? 2 : 1)
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(center.dx + (radius - tickLength) * math.cos(angle), center.dy + (radius - tickLength) * math.sin(angle)),
        Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle)),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
