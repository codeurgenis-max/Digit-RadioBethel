import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../providers/church_provider.dart';
import '../models/church_models.dart';
import '../utils/app_colors.dart';
import 'live_video_screen.dart';

class ReplayListScreen extends StatefulWidget {
  const ReplayListScreen({super.key});

  @override
  State<ReplayListScreen> createState() => _ReplayListScreenState();
}

class _ReplayListScreenState extends State<ReplayListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<ChurchProvider>().fetchReplays();
        } catch (e) {
          debugPrint('Error fetching replays in initState: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Replays Vidéo'),
        centerTitle: false,
      ),
      body: Consumer<ChurchProvider>(
        builder: (context, provider, child) {
          final replays = provider.replays;

          if (provider.isLoading && replays.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (replays.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchReplays(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: replays.length,
              itemBuilder: (context, index) {
                final replay = replays[index];
                return _buildReplayCard(context, replay);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildReplayCard(BuildContext context, ReplayModel replay) {
    final dateStr = replay.date != null 
        ? DateFormat('dd MMMM yyyy', 'fr_FR').format(replay.date!)
        : 'Date inconnue';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            // Re-use LiveVideoScreen player logic for replays
            final liveMock = LiveModel(
              id: replay.id,
              title: replay.title,
              videoUrl: replay.videoUrl,
              status: 'finished',
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LiveVideoScreen(live: liveMock)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: replay.coverImage != null
                          ? CachedNetworkImage(
                              imageUrl: replay.coverImage!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.slate100,
                                child: const Icon(Icons.play_circle_outline, size: 48, color: Colors.white54),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.slate100,
                                child: const Icon(Icons.play_circle_outline, size: 48, color: Colors.white54),
                              ),
                            )
                          : Container(
                              color: AppColors.slate800,
                              child: const Icon(Icons.play_circle_outline, size: 48, color: Colors.white54),
                            ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      replay.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.slate400),
                        const SizedBox(width: 8),
                        Text(
                          dateStr,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 64, color: AppColors.slate300),
          const SizedBox(height: 16),
          Text(
            'Aucun replay disponible',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.slate500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
