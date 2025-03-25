import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class BreathingExercise extends StatefulWidget {
  const BreathingExercise({super.key});

  @override
  State<BreathingExercise> createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercise> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isBreathing = false;
  String _instruction = "Select a level and tap Begin";
  int _selectedLevel = 0; // 0: Level 1, 1: Level 2, 2: Level 3
  Timer? _timer;

  // Breathing level configurations tailored for pregnancy
  final List<Map<String, dynamic>> _levels = [
    {
      'name': 'Gentle Flow',
      'description': '4s in, 4s out - Calm for you & baby',
      'inhale': 4,
      'hold': 0,
      'exhale': 4,
    },
    {
      'name': 'Mama’s Breath',
      'description': '4s in, 6s out - Deep relaxation',
      'inhale': 4,
      'hold': 0,
      'exhale': 6,
    },
    {
      'name': 'Blossom Calm',
      'description': '4s in, 7s hold, 8s out - Peaceful bonding',
      'inhale': 4,
      'hold': 7,
      'exhale': 8,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Default for Level 1 inhale
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (!_isBreathing) return;
      if (status == AnimationStatus.completed) {
        if (_levels[_selectedLevel]['hold'] > 0) {
          setState(() => _instruction = "Hold gently...");
          _controller.stop();
          Future.delayed(Duration(seconds: _levels[_selectedLevel]['hold']), () {
            if (_isBreathing) {
              setState(() => _instruction = "Exhale softly...");
              _controller.duration = Duration(seconds: _levels[_selectedLevel]['exhale']);
              _controller.reverse();
            }
          });
        } else {
          setState(() => _instruction = "Exhale softly...");
          _controller.duration = Duration(seconds: _levels[_selectedLevel]['exhale']);
          _controller.reverse();
        }
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _instruction = "Inhale gently...");
        _controller.duration = Duration(seconds: _levels[_selectedLevel]['inhale']);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _toggleBreathing() {
    setState(() {
      _isBreathing = !_isBreathing;
    });

    if (_isBreathing) {
      _instruction = "Inhale gently...";
      _controller.duration = Duration(seconds: _levels[_selectedLevel]['inhale']);
      _controller.forward();
      _timer = Timer.periodic(
        Duration(seconds: _levels[_selectedLevel]['inhale'] +
            _levels[_selectedLevel]['hold'] +
            _levels[_selectedLevel]['exhale']),
        (timer) {
          if (!_isBreathing) timer.cancel();
        },
      );
    } else {
      _instruction = "Select a level and tap Begin";
      _controller.stop();
      _controller.reset();
      _timer?.cancel();
    }
  }

  void _selectLevel(int level) {
    if (!_isBreathing) {
      setState(() {
        _selectedLevel = level;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50, // Soft pink background
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade200, Colors.purple.shade200], // Matching HomeContent
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Calm & Breathe",
          style: GoogleFonts.pacifico( // More nurturing font
            fontSize: 24,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Level Selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16), // Softer corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade100.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Find Your Calm",
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (int i = 0; i < _levels.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => _selectLevel(i),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _selectedLevel == i ? Colors.pink.shade100 : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedLevel == i ? Colors.pink.shade300 : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.self_improvement, // More pregnancy-friendly icon
                                  color: _selectedLevel == i ? Colors.pink.shade400 : Colors.purple.shade300,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _levels[i]['name'],
                                        style: GoogleFonts.nunito(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedLevel == i ? Colors.purple.shade800 : Colors.grey.shade800,
                                        ),
                                      ),
                                      Text(
                                        _levels[i]['description'],
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          color: _selectedLevel == i ? Colors.pink.shade600 : Colors.grey.shade600,
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
              ),
              const SizedBox(height: 40),

              // Breathing Animation Circle
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.pink.shade200, Colors.purple.shade300], // Softer gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.shade200.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Current Instruction
              Text(
                _instruction,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Start/Stop Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade300, // Softer pink
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2, // Reduced elevation
                ),
                onPressed: _toggleBreathing,
                child: Text(
                  _isBreathing ? "Pause" : "Begin",
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}