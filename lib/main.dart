import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const GuitarTunerApp());
}

class GuitarTunerApp extends StatelessWidget {
  const GuitarTunerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Guitar Tuner',
      theme: ThemeData.dark(useMaterial3: true),
      home: const TunerScreen(),
    );
  }
}

class GuitarStringSpec {
  final int stringNumber;
  final String note;
  final double frequencyHz;
  final String role;

  const GuitarStringSpec({
    required this.stringNumber,
    required this.note,
    required this.frequencyHz,
    required this.role,
  });
}

class TunerScreen extends StatefulWidget {
  const TunerScreen({super.key});

  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _stringAnim;
  double _wavePhase = 0.0;
  String _selectedPreset = 'Standard';
  int _selectedStringIndex = 0;
  double _centOffset = -12.0; // -50 to +50 cents

  final Map<String, List<GuitarStringSpec>> _tunings = const {
    'Standard': [
      GuitarStringSpec(
        stringNumber: 6,
        note: 'E2',
        frequencyHz: 82.41,
        role: 'Low Bass',
      ),
      GuitarStringSpec(
        stringNumber: 5,
        note: 'A2',
        frequencyHz: 110.00,
        role: 'Fifth',
      ),
      GuitarStringSpec(
        stringNumber: 4,
        note: 'D3',
        frequencyHz: 146.83,
        role: 'Fourth',
      ),
      GuitarStringSpec(
        stringNumber: 3,
        note: 'G3',
        frequencyHz: 196.00,
        role: 'Third',
      ),
      GuitarStringSpec(
        stringNumber: 2,
        note: 'B3',
        frequencyHz: 246.94,
        role: 'Second',
      ),
      GuitarStringSpec(
        stringNumber: 1,
        note: 'E4',
        frequencyHz: 329.63,
        role: 'High Treble',
      ),
    ],
    'Drop D': [
      GuitarStringSpec(
        stringNumber: 6,
        note: 'D2',
        frequencyHz: 73.42,
        role: 'Dropped Bass',
      ),
      GuitarStringSpec(
        stringNumber: 5,
        note: 'A2',
        frequencyHz: 110.00,
        role: 'Fifth',
      ),
      GuitarStringSpec(
        stringNumber: 4,
        note: 'D3',
        frequencyHz: 146.83,
        role: 'Fourth',
      ),
      GuitarStringSpec(
        stringNumber: 3,
        note: 'G3',
        frequencyHz: 196.00,
        role: 'Third',
      ),
      GuitarStringSpec(
        stringNumber: 2,
        note: 'B3',
        frequencyHz: 246.94,
        role: 'Second',
      ),
      GuitarStringSpec(
        stringNumber: 1,
        note: 'E4',
        frequencyHz: 329.63,
        role: 'High Treble',
      ),
    ],
    'Open G': [
      GuitarStringSpec(
        stringNumber: 6,
        note: 'D2',
        frequencyHz: 73.42,
        role: 'Low Bass',
      ),
      GuitarStringSpec(
        stringNumber: 5,
        note: 'G2',
        frequencyHz: 98.00,
        role: 'Root Fifth',
      ),
      GuitarStringSpec(
        stringNumber: 4,
        note: 'D3',
        frequencyHz: 146.83,
        role: 'Fourth',
      ),
      GuitarStringSpec(
        stringNumber: 3,
        note: 'G3',
        frequencyHz: 196.00,
        role: 'Third',
      ),
      GuitarStringSpec(
        stringNumber: 2,
        note: 'B3',
        frequencyHz: 246.94,
        role: 'Second',
      ),
      GuitarStringSpec(
        stringNumber: 1,
        note: 'D4',
        frequencyHz: 293.66,
        role: 'High Treble',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _stringAnim =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() {
            setState(() {
              _wavePhase += 0.35;
            });
          });
    _stringAnim.repeat();
  }

  @override
  void dispose() {
    _stringAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStrings = _tunings[_selectedPreset]!;
    final activeString = currentStrings[_selectedStringIndex];
    final isInTune = _centOffset.abs() <= 2.5;
    final actualHz = activeString.frequencyHz * pow(2, _centOffset / 1200);
    final statusColor = isInTune
        ? Colors.greenAccent
        : (_centOffset < 0 ? Colors.amberAccent : Colors.redAccent);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Digital Guitar Tuner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _tunings.keys.map((preset) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(preset),
                    selected: _selectedPreset == preset,
                    onSelected: (_) {
                      setState(() {
                        _selectedPreset = preset;
                        _centOffset = -8.0;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              height: 185,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF121724),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'String #${activeString.stringNumber} • ${activeString.role}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isInTune
                              ? 'IN TUNE'
                              : (_centOffset < 0
                                    ? 'TOO FLAT (TIGHTEN)'
                                    : 'TOO SHARP (LOOSEN)'),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: CustomPaint(
                      painter: _TunerGaugePainter(
                        centOffset: _centOffset,
                        accentColor: statusColor,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target: ${activeString.frequencyHz.toStringAsFixed(2)} Hz',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'Detected: ${actualHz.toStringAsFixed(2)} Hz (${_centOffset >= 0 ? '+' : ''}${_centOffset.toStringAsFixed(1)}c)',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 46,
              child: CustomPaint(
                painter: _VibratingStringPainter(
                  phase: _wavePhase,
                  frequencyHz: activeString.frequencyHz,
                  color: statusColor,
                ),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Peg Tune:',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                Expanded(
                  child: Slider(
                    value: _centOffset,
                    min: -50,
                    max: 50,
                    activeColor: statusColor,
                    onChanged: (v) => setState(() => _centOffset = v),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _centOffset = 0.0),
                  child: const Text('Snap 0c'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: currentStrings.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.35,
                ),
                itemBuilder: (ctx, i) {
                  final s = currentStrings[i];
                  final selected = i == _selectedStringIndex;
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        _selectedStringIndex = i;
                        _centOffset = (i.isEven ? -9.5 : 8.0);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.cyanAccent.withValues(alpha: 0.16)
                            : const Color(0xFF141A29),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? Colors.cyanAccent : Colors.white12,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s.note,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? Colors.cyanAccent
                                  : Colors.white,
                            ),
                          ),
                          Text(
                            '${s.frequencyHz.toStringAsFixed(1)} Hz',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TunerGaugePainter extends CustomPainter {
  final double centOffset;
  final Color accentColor;

  _TunerGaugePainter({required this.centOffset, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.88);
    final radius = min(size.width * 0.42, size.height * 0.75);

    final arcPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      arcPaint,
    );

    final centerZonePaint = Paint()
      ..color = Colors.greenAccent.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 - 0.12,
      0.24,
      false,
      centerZonePaint,
    );

    final normalized = (centOffset.clamp(-50, 50) / 50);
    final needleAngle = -pi / 2 + (normalized * (pi * 0.44));
    final needleEnd = Offset(
      center.dx + radius * 0.92 * cos(needleAngle),
      center.dy + radius * 0.92 * sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 6, Paint()..color = accentColor);
  }

  @override
  bool shouldRepaint(covariant _TunerGaugePainter oldDelegate) => true;
}

class _VibratingStringPainter extends CustomPainter {
  final double phase;
  final double frequencyHz;
  final Color color;

  _VibratingStringPainter({
    required this.phase,
    required this.frequencyHz,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final path = Path();
    final harmonic = (frequencyHz / 80).clamp(1.0, 4.0);

    for (double x = 0; x <= size.width; x += 3) {
      final envelope = sin((x / size.width) * pi);
      final y =
          midY + sin((x / size.width) * pi * harmonic + phase) * 11 * envelope;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _VibratingStringPainter oldDelegate) => true;
}
