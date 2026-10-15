import 'package:flutter/material.dart';
import 'dart:math' as math;

class MusicVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final int barCount;

  const MusicVisualizer({
    super.key,
    required this.isPlaying,
    this.color = Colors.white,
    this.barCount = 30,
  });

  @override
  State<MusicVisualizer> createState() => _MusicVisualizerState();
}

class _MusicVisualizerState extends State<MusicVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _randomFactors = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    for (int i = 0; i < widget.barCount; i++) {
      _randomFactors.add(_random.nextDouble() * 0.7 + 0.3);
    }

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(MusicVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            // Complex wave: combination of two sine waves + constant factor
            double t = _controller.value * 2 * math.pi;
            double wave1 = math.sin(t + (index * 0.5));
            double wave2 = math.cos(t * 1.5 + (index * 0.2));
            
            double amplitude = (wave1.abs() + wave2.abs()) / 2;
            double animatedHeight = widget.isPlaying
                ? (8.0 + (amplitude * _randomFactors[index] * 45))
                : 4.0;
            
            return Container(
              width: 3,
              height: animatedHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    widget.color.withOpacity(0.4),
                    widget.color,
                    widget.color.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: widget.isPlaying ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ] : [],
              ),
            );
          }),
        );
      },
    );
  }
}
