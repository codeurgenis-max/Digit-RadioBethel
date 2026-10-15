import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import '../providers/church_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/music_visualizer.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Radio Direct'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ChurchProvider>(
        builder: (context, provider, child) {
          final radio = provider.radio;

          if (radio == null) {
            return const Center(
              child: Text(
                'Radio non disponible',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return Stack(
            children: [
              // 1. Background Image with Dark Overlay
              Positioned.fill(
                child: Image.asset(
                  'assets/micropc.jpg', // User requested a background image
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0F172A).withOpacity(0.8),
                        const Color(0xFF1E293B).withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Rotating & Glowing Logo
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Container(
                              width: 240, // Reduced slightly for better compatibility
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: provider.isRadioPlaying
                                    ? [
                                        BoxShadow(
                                          color: AppColors.orange500.withOpacity(0.3 * _animationController.value),
                                          blurRadius: 40,
                                          spreadRadius: 15,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: child,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(120),
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: Image.asset(
                                  'assets/logo_new.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),

                        // Radio Info
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: 0.5 + (0.5 * _animationController.value),
                                        child: const Icon(Icons.sensors, color: Colors.red, size: 16),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'EN DIRECT',
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              radio.currentTheme ?? 'Ma Paroisse Digitale',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              radio.currentPastor != null ? 'Par ${radio.currentPastor}' : 'La Voix De Foi',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Audio Spectrum Visualizer
                        SizedBox(
                          height: 50,
                          child: MusicVisualizer(
                            isPlaying: provider.isRadioPlaying,
                            color: AppColors.orange500,
                            barCount: 30,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Progress Bar
                        StreamBuilder<Duration>(
                          stream: provider.positionStream,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            return StreamBuilder<Duration?>(
                              stream: provider.durationStream,
                              builder: (context, snapshot) {
                                final total = snapshot.data ?? const Duration(hours: 24);
                                final isLive = snapshot.data == null;

                                return ProgressBar(
                                  progress: position,
                                  total: total,
                                  buffered: Duration.zero,
                                  onSeek: isLive ? null : (duration) {
                                    provider.seek(duration);
                                  },
                                  barHeight: 4,
                                  baseBarColor: Colors.white24,
                                  progressBarColor: AppColors.orange500,
                                  bufferedBarColor: Colors.white12,
                                  thumbColor: isLive ? Colors.transparent : AppColors.orange500,
                                  thumbRadius: isLive ? 0 : 6,
                                  timeLabelTextStyle: const TextStyle(color: Colors.white70),
                                  timeLabelLocation: TimeLabelLocation.below,
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // Play/Pause Button
                        GestureDetector(
                          onTap: () => provider.toggleRadio(),
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: provider.isLoading 
                              ? const Center(
                                  child: SizedBox(
                                    height: 32,
                                    width: 32,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF0F172A),
                                      strokeWidth: 3,
                                    ),
                                  ),
                                )
                              : Icon(
                                  provider.isRadioPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  size: 52,
                                  color: const Color(0xFF0F172A),
                                ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        Text(
                          provider.isLoading 
                              ? 'Synchronisation...' 
                              : (provider.isRadioPlaying ? 'Pause' : 'Lecture'),
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
