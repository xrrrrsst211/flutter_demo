mport 'dart:math' as math;

import 'package:flutter/material.dart';

class PaintingDemo extends StatefulWidget {
  const PaintingDemo({super.key});

  @override
  State<PaintingDemo> createState() => _PaintingDemoState();
}

class _PaintingDemoState extends State<PaintingDemo> {
  // These values are normalized, so 0.0 means left/top and 1.0 means right/bottom.
  // This makes the curve responsive on phones, web, and desktop windows.
  Offset p0 = const Offset(0.10, 0.75);
  Offset p1 = const Offset(0.25, 0.15);
  Offset p2 = const Offset(0.75, 0.15);
  Offset p3 = const Offset(0.90, 0.75);

  int? draggingPointIndex;

  Offset _toCanvasPoint(Offset normalized, Size size) {
    return Offset(normalized.dx * size.width, normalized.dy * size.height);
  }

  Offset _toNormalizedPoint(Offset localPosition, Size size) {
    return Offset(
      (localPosition.dx / size.width).clamp(0.0, 1.0),
      (localPosition.dy / size.height).clamp(0.0, 1.0),
    );
  }

  void _updatePoint(int index, Offset value) {
    final fixedValue = Offset(
      value.dx.clamp(0.0, 1.0),
      value.dy.clamp(0.0, 1.0),
    );

    setState(() {
      if (index == 0) p0 = fixedValue;
      if (index == 1) p1 = fixedValue;
      if (index == 2) p2 = fixedValue;
      if (index == 3) p3 = fixedValue;
    });
  }

  int? _nearestPoint(Offset localPosition, Size size) {
    final points = [p0, p1, p2, p3];
    const touchRadius = 34.0;

    int? closestIndex;
    double closestDistance = double.infinity;

    for (int i = 0; i < points.length; i++) {
      final canvasPoint = _toCanvasPoint(points[i], size);
      final distance = (canvasPoint - localPosition).distance;

      if (distance < closestDistance && distance <= touchRadius) {
        closestDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  void _resetCurve() {
    setState(() {
      p0 = const Offset(0.10, 0.75);
      p1 = const Offset(0.25, 0.15);
      p2 = const Offset(0.75, 0.15);
      p3 = const Offset(0.90, 0.75);
      draggingPointIndex = null;
    });
  }

  Widget _buildSliderSection() {
    return Column(
      children: [
        _PointSliders(
          label: 'P0 start point',
          color: Colors.green,
          point: p0,
          onChanged: (value) => _updatePoint(0, value),
        ),
        _PointSliders(
          label: 'P1 control point',
          color: Colors.orange,
          point: p1,
          onChanged: (value) => _updatePoint(1, value),
        ),
        _PointSliders(
          label: 'P2 control point',
          color: Colors.purple,
          point: p2,
          onChanged: (value) => _updatePoint(2, value),
        ),
        _PointSliders(
          label: 'P3 end point',
          color: Colors.red,
          point: p3,
          onChanged: (value) => _updatePoint(3, value),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cubic Bezier Curve'),
        actions: [
          IconButton(
            tooltip: 'Reset curve',
            onPressed: _resetCurve,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 850;
            final canvasSize = math.min(
              isWide ? constraints.maxWidth * 0.58 : constraints.maxWidth - 32,
              isWide ? constraints.maxHeight - 48 : 390,
            ).clamp(280.0, 560.0);

            final curveArea = Card(
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.zero,
              child: Container(
                width: canvasSize,
                height: canvasSize,
                color: theme.colorScheme.surface,
                child: LayoutBuilder(
                  builder: (context, canvasConstraints) {
                    final size = Size(
                      canvasConstraints.maxWidth,
                      canvasConstraints.maxHeight,
                    );

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) {
                        draggingPointIndex = _nearestPoint(
                          details.localPosition,
                          size,
                        );
                      },
                      onPanUpdate: (details) {
                        final index = draggingPointIndex;
                        if (index == null) return;
                        _updatePoint(index, _toNormalizedPoint(details.localPosition, size));
                      },
                      onPanEnd: (_) => draggingPointIndex = null,
                      onTapDown: (details) {
                        final index = _nearestPoint(details.localPosition, size);
                        if (index != null) {
                          _updatePoint(index, _toNormalizedPoint(details.localPosition, size));
                        }
                      },
                      child: CustomPaint(
                        painter: BezierPainter(
                          p0: p0,
                          p1: p1,
                          p2: p2,
                          p3: p3,
                          selectedIndex: draggingPointIndex,
                          colorScheme: theme.colorScheme,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );

            final controls = Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adjust the curve',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Drag the colored points directly on the canvas, or use the sliders below.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildSliderSection(),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _resetCurve,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ),
            );

            if (isWide) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    curveArea,
                    const SizedBox(width: 24),
                    Expanded(child: controls),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  curveArea,
                  const SizedBox(height: 16),
                  controls,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PointSliders extends StatelessWidget {
  const _PointSliders({
    required this.label,
    required this.color,
    required this.point,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final Offset point;
  final ValueChanged<Offset> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$label  (${point.dx.toStringAsFixed(2)}, ${point.dy.toStringAsFixed(2)})',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 22, child: Text('X')),
              Expanded(
                child: Slider(
                  value: point.dx,
                  onChanged: (value) => onChanged(Offset(value, point.dy)),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 22, child: Text('Y')),
              Expanded(
                child: Slider(
                  value: point.dy,
                  onChanged: (value) => onChanged(Offset(point.dx, value)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BezierPainter extends CustomPainter {
  const BezierPainter({
    required this.p0,
    required this.p1,
    required this.p2,
    required this.p3,
    required this.selectedIndex,
    required this.colorScheme,
  });

  final Offset p0;
  final Offset p1;
  final Offset p2;
  final Offset p3;
  final int? selectedIndex;
  final ColorScheme colorScheme;

  Offset _scale(Offset point, Size size) {
    return Offset(point.dx * size.width, point.dy * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final start = _scale(p0, size);
    final control1 = _scale(p1, size);
    final control2 = _scale(p2, size);
    final end = _scale(p3, size);

    _drawGrid(canvas, size);
    _drawControlLines(canvas, start, control1, control2, end);
    _drawBezierCurve(canvas, start, control1, control2, end);
    _drawPoint(canvas, start, 'P0', Colors.green, selectedIndex == 0);
    _drawPoint(canvas, control1, 'P1', Colors.orange, selectedIndex == 1);
    _drawPoint(canvas, control2, 'P2', Colors.purple, selectedIndex == 2);
    _drawPoint(canvas, end, 'P3', Colors.red, selectedIndex == 3);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = colorScheme.outlineVariant.withOpacity(0.45)
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawControlLines(
    Canvas canvas,
    Offset start,
    Offset control1,
    Offset control2,
    Offset end,
  ) {
    final controlPaint = Paint()
      ..color = colorScheme.outline
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, control1, controlPaint);
    canvas.drawLine(control1, control2, controlPaint);
    canvas.drawLine(control2, end, controlPaint);
  }

  void _drawBezierCurve(
    Canvas canvas,
    Offset start,
    Offset control1,
    Offset control2,
    Offset end,
  ) {
    final curvePath = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        end.dx,
        end.dy,
      );

    final curvePaint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(curvePath, curvePaint);
  }

  void _drawPoint(
    Canvas canvas,
    Offset point,
    String label,
    Color color,
    bool selected,
  ) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(point.translate(0, 2), selected ? 17 : 14, shadowPaint);

    final fillPaint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(point, selected ? 16 : 13, fillPaint);
    canvas.drawCircle(point, selected ? 16 : 13, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelOffset = Offset(
      (point.dx + 16).clamp(4.0, double.infinity),
      (point.dy - 28).clamp(4.0, double.infinity),
    );

    final labelBackground = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        labelOffset.dx - 6,
        labelOffset.dy - 3,
        textPainter.width + 12,
        textPainter.height + 6,
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(labelBackground, Paint()..color = Colors.white.withOpacity(0.86));
    textPainter.paint(canvas, labelOffset);
  }

  @override
  bool shouldRepaint(covariant BezierPainter oldDelegate) {
    return oldDelegate.p0 != p0 ||
        oldDelegate.p1 != p1 ||
        oldDelegate.p2 != p2 ||
        oldDelegate.p3 != p3 ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.colorScheme != colorScheme;
  }
}
