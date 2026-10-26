import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import '../providers/church_provider.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _waveController;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Halo doux lent
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Contrôleur rapide et dynamique pour les ondes audio (rythme musical)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChurchProvider>(
      builder: (context, provider, child) {
        final radio = provider.radio;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0806),
          body: Stack(
            children: [
              // 1. Fond ambiance studio radio sombre avec reflets dorés
              Positioned.fill(
                child: Image.asset(
                  'assets/micropc.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // Overlay sombre dégradé élégant
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        const Color(0xFF0F0B06).withValues(alpha: 0.85),
                        const Color(0xFF0A0704).withValues(alpha: 0.98),
                      ],
                      stops: const [0.0, 0.5, 0.95],
                    ),
                  ),
                ),
              ),

              // Motifs géométriques dorés discrets en bas/coins
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 180,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFFD4AF37).withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                ),
              ),

              // Contenu principal
              SafeArea(
                child: Column(
                  children: [
                    // --- HEADER SUPÉRIEUR ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.7),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFDC2626).withValues(alpha: 0.25),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedBuilder(
                                animation: _glowController,
                                builder: (context, child) => Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFEF4444).withValues(
                                      alpha: 0.4 + (0.6 * _glowController.value),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'EN DIRECT',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.podcasts_rounded,
                                color: Color(0xFFFBBF24),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // --- VISUEL CENTRAL : LOGO CIRCULAIRE AVEC ONDES DORÉES ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Ondes sonores gauches
                        _buildWaveBars(isLeft: true, isPlaying: provider.isRadioPlaying),

                        const SizedBox(width: 14),

                        // Cercle central lumineux
                        AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) {
                            return Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFF59E0B),
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withValues(
                                      alpha: provider.isRadioPlaying
                                          ? (0.45 + 0.35 * _glowController.value)
                                          : 0.25,
                                    ),
                                    blurRadius: provider.isRadioPlaying ? 45 : 20,
                                    spreadRadius: provider.isRadioPlaying ? 10 : 2,
                                  ),
                                ],
                              ),
                              child: child,
                            );
                          },
                          child: ClipOval(
                            child: Image.asset(
                              'assets/digitradio_circle_clean.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Ondes sonores droites
                        _buildWaveBars(isLeft: false, isPlaying: provider.isRadioPlaying),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- TITRE ET SOUS-TITRE DU DIRECT ---
                    Text(
                      radio?.currentTheme ?? 'La Voix de Foi',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      radio?.currentPastor != null
                          ? 'Par ${radio!.currentPastor}'
                          : 'La Voix De Foi',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),

                    const Spacer(flex: 1),

                    // --- BARRE DE PROGRESSION DORÉE ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: StreamBuilder<Duration>(
                        stream: provider.positionStream,
                        builder: (context, posSnapshot) {
                          final position = posSnapshot.data ?? Duration.zero;
                          return StreamBuilder<Duration?>(
                            stream: provider.durationStream,
                            builder: (context, durSnapshot) {
                              final total = durSnapshot.data ?? const Duration(hours: 24);

                              return ProgressBar(
                                progress: position,
                                total: total,
                                buffered: Duration.zero,
                                onSeek: null, // Stream live direct
                                barHeight: 3.5,
                                baseBarColor: Colors.white.withValues(alpha: 0.15),
                                progressBarColor: const Color(0xFFFBBF24),
                                thumbColor: const Color(0xFFFBBF24),
                                thumbRadius: 6,
                                thumbGlowRadius: 16,
                                timeLabelLocation: TimeLabelLocation.below,
                                timeLabelTextStyle: GoogleFonts.poppins(
                                  color: Colors.white60,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- RANGÉE DE CONTRÔLES (Timer, Précédent, PLAY/PAUSE, Suivant, Favori) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 1. Minuterie de mise en veille
                          _buildCircleIconButton(
                            icon: Icons.timer_outlined,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Minuterie de veille : 30 minutes'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),

                          // 2. Précédent
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.skip_previous_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),

                          // 3. GROS BOUTON CENTRAL DORÉ PLAY / PAUSE
                          GestureDetector(
                            onTap: () => provider.toggleRadio(),
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFDE68A),
                                    Color(0xFFF59E0B),
                                    Color(0xFFD97706),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                                    blurRadius: 22,
                                    spreadRadius: 3,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: provider.isLoading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF0F172A),
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      provider.isRadioPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 46,
                                      color: const Color(0xFF0A0806),
                                    ),
                            ),
                          ),

                          // 4. Suivant
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),

                          // 5. Bouton Favori (Cœur)
                          _buildCircleIconButton(
                            icon: _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isFavorite ? const Color(0xFFEF4444) : Colors.white,
                            onTap: () {
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Petit bouton rond sombre translucide (Timer / Cœur)
  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // Ondes dorées vivantes et organiques de chaque côté du cercle
  Widget _buildWaveBars({required bool isLeft, required bool isPlaying}) {
    // 7 barres de spectre pour une dynamique riche
    final baseHeights = [12.0, 18.0, 30.0, 48.0, 38.0, 24.0, 14.0];
    final displayHeights = isLeft ? baseHeights : baseHeights.reversed.toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(displayHeights.length, (index) {
        final baseH = displayHeights[index];
        // Déphasage sinusoïdal unique pour chaque barre
        final phaseOffset = (index * 0.9) + (isLeft ? 0.0 : math.pi);

        return AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            double barHeight;
            double opacity;

            if (isPlaying) {
              final t = _waveController.value * 2 * math.pi;
              // Synthèse d'harmoniques pour simuler le beat musical
              final harmonic1 = math.sin(t * 1.8 + phaseOffset);
              final harmonic2 = math.cos(t * 2.6 + (phaseOffset * 1.5));
              final wave = ((harmonic1.abs() * 0.65) + (harmonic2.abs() * 0.35));

              barHeight = 8.0 + (wave * (baseH - 4.0));
              opacity = 0.65 + (0.35 * wave);
            } else {
              // Mode repos / pause
              barHeight = 6.0;
              opacity = 0.3;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.2),
              width: 3.5,
              height: barHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFFD97706).withValues(alpha: opacity),
                    const Color(0xFFFBBF24).withValues(alpha: opacity),
                    const Color(0xFFFEF3C7).withValues(alpha: opacity),
                  ],
                ),
                boxShadow: isPlaying
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFBBF24).withValues(alpha: 0.5 * opacity),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            );
          },
        );
      }),
    );
  }
}
