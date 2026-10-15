import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/church_provider.dart';
import '../models/church_models.dart';
import '../utils/app_colors.dart';
import '../widgets/skeleton_widgets.dart';

class PodcastListScreen extends StatefulWidget {
  final CategoryModel? initialCategory;
  const PodcastListScreen({super.key, this.initialCategory});

  @override
  State<PodcastListScreen> createState() => _PodcastListScreenState();
}

class _PodcastListScreenState extends State<PodcastListScreen> {
  @override
  void initState() {
    super.initState();
    // Handled by ChurchProvider
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Consumer<ChurchProvider>(
        builder: (context, provider, child) {
          final podcasts = widget.initialCategory != null
              ? provider.podcasts.where((p) => p.categoryId == widget.initialCategory?.id).toList()
              : provider.podcasts;

          debugPrint('🏗️ Building PodcastListScreen body, count: ${podcasts.length}');
          return RefreshIndicator(
            onRefresh: () => provider.fetchHomeData(),
            child: CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(context),
                    if (widget.initialCategory?.description != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'À PROPOS',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.orange500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.initialCategory?.description ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.slate600,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (podcasts.isEmpty && provider.isLoading)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => const PodcastSkeleton(),
                            childCount: 6,
                          ),
                        ),
                      )
                    else if (podcasts.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final podcast = podcasts[index];
                              final isCurrent = provider.currentPodcast?.id == podcast.id;
                              return _buildPodcastCard(context, podcast, provider, isCurrent);
                            },
                            childCount: podcasts.length,
                          ),
                        ),
                      ),
                  ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildSliverAppBar(BuildContext context) {
    debugPrint('🏗️ Building SliverAppBar');
    final hasCategory = widget.initialCategory != null;
    final hasImage = hasCategory && widget.initialCategory!.image != null;

    return SliverAppBar(
      expandedHeight: hasImage ? 240.0 : 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          hasCategory 
              ? widget.initialCategory!.name 
              : 'Podcasts & Sermons',
          style: GoogleFonts.poppins(
            color: hasImage ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            shadows: hasImage ? [
              const Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2))
            ] : null,
          ),
        ),
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 56, bottom: hasImage ? 24 : 16),
        background: hasImage 
            ? Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.initialCategory!.image != null)
                    CachedNetworkImage(
                      imageUrl: widget.initialCategory?.image ?? '',
                      fit: BoxFit.cover,
                      memCacheWidth: 600, // Reduced to optimize memory on low-end devices
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.slate100,
                        child: const Icon(Icons.image_not_supported, color: AppColors.slate300, size: 48),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(hasImage ? 0.3 : 0.0),
                    ),
                  ),
                ],
              )
            : null,
      ),
      iconTheme: IconThemeData(color: hasImage ? Colors.white : const Color(0xFF0F172A)),
    );
  }

  Widget _buildPodcastCard(BuildContext context, PodcastModel podcast, ChurchProvider provider, bool isCurrent) {
    debugPrint('🏗️ Building PodcastCard: ${podcast.title}');
    final dateStr = podcast.date != null 
        ? DateFormat('dd MMM yyyy', 'fr_FR').format(podcast.date!)
        : 'Date inconnue';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
            // Navigate to Detail logic can be added here
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: podcast.coverImage != null
                        ? CachedNetworkImage(
                            imageUrl: podcast.coverImage!,
                            fit: BoxFit.cover,
                            memCacheWidth: 200, // Optimize for thumb
                            placeholder: (context, url) => Container(
                              color: AppColors.orange500.withOpacity(0.1),
                              child: const Icon(Icons.mic, color: AppColors.orange500),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.orange500.withOpacity(0.1),
                              child: const Icon(Icons.mic, color: AppColors.orange500),
                            ),
                          )
                        : Container(
                            color: AppColors.orange500.withOpacity(0.1),
                            child: const Icon(Icons.mic, color: AppColors.orange500),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        podcast.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: AppColors.slate400),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              podcast.speaker ?? 'Intervenant',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.slate500,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => provider.togglePodcast(podcast),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCurrent && provider.isPlaying
                          ? AppColors.orange500
                          : AppColors.orange500.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCurrent && provider.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: isCurrent && provider.isPlaying ? Colors.white : AppColors.orange500,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
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
          Icon(Icons.mic_off_outlined, size: 64, color: AppColors.slate300),
          const SizedBox(height: 16),
          Text(
            'Aucun podcast disponible',
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
