import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/church_provider.dart';
import '../utils/app_colors.dart';
import 'radio_screen.dart';
import 'podcast_list_screen.dart';
import 'live_video_screen.dart';
import 'agenda_screen.dart';
import 'prayer_request_screen.dart';
import 'auth_screen.dart';
import 'replay_list_screen.dart';
import 'package:intl/intl.dart';
import '../models/church_models.dart';
import 'event_detail_screen.dart';
import '../widgets/skeleton_widgets.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Default to Radio


  final List<Widget> _screens = [
    const HomeDashboard(),
    const RadioScreen(),
    const PodcastListScreen(),
    const MoreMenu(),
  ];

  @override
  void initState() {
    super.initState();
    // Data is now initialized by ChurchProvider on start
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.orange500,
          unselectedItemColor: AppColors.slate400,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12),
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_rounded),
              ),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.radio_rounded),
              ),
              label: 'Radio',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.podcasts_rounded),
              ),
              label: 'Podcasts',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.more_horiz_rounded),
              ),
              label: 'Plus',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<ChurchProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildHomeSkeleton(context);
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchHomeData(),
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (provider.verse != null)
                          _buildDailyVerse(context, provider.verse),
                        const SizedBox(height: 24),
                        _buildCategoriesList(context, provider),
                        const SizedBox(height: 32),
                        _buildLiveSection(context, provider),
                        const SizedBox(height: 32),
                        _buildReplaysSection(context, provider),
                        const SizedBox(height: 32),
                        _buildSectionHeader(context, 'AGENDA SPIRITUEL', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendaScreen()));
                        }),
                        const SizedBox(height: 16),
                        if (provider.upcomingEvents.isEmpty)
                          _buildEmptyState('Aucun événement prévu.')
                        else
                          ...provider.upcomingEvents.take(2).map((e) => _buildEventCard(context, e)),
                        const SizedBox(height: 32), 
                      ],
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

  Widget _buildHomeSkeleton(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VerseSkeleton(),
                const SizedBox(height: 24),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (_, __) => const CategorySkeleton(),
                  ),
                ),
                const SizedBox(height: 32),
                const LiveSkeleton(),
                const SizedBox(height: 32),
                SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (_, __) => const ReplaySkeleton(),
                  ),
                ),
                const SizedBox(height: 32),
                const EventSkeleton(),
                const EventSkeleton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.primary,
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            // Black overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Logo in the center
            Center(
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  'assets/logo_new.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyVerse(BuildContext context, dynamic verse) {
    if (verse == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Deep Slate/Black
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Verset du Jour',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            verse.content,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              height: 1.5,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              verse.reference,
              style: GoogleFonts.poppins(
                color: AppColors.orange500,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF0F172A),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            'Voir tout',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveSection(BuildContext context, ChurchProvider provider) {
    final live = provider.live;
    if (live == null) return const SizedBox.shrink();

    final isLive = live.status == 'live';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isLive ? Colors.red.shade100 : AppColors.slate100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            debugPrint('🔵 Navigating to LiveVideoScreen for: ${live.title}');
            try {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LiveVideoScreen(live: live)),
              );
            } catch (e, stackTrace) {
              debugPrint('🔴 ERROR navigating to LiveVideoScreen: $e');
              debugPrint('Stack trace: $stackTrace');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isLive ? AppColors.red700 : AppColors.orange500).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLive ? Icons.live_tv : Icons.videocam,
                    color: isLive ? AppColors.red700 : AppColors.orange500,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLive ? '' : 'PROCHAIN DIRECT',
                        style: GoogleFonts.poppins(
                          color: isLive ? Colors.red : AppColors.slate500,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        live.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.slate400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, dynamic event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.orange500.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.event, color: AppColors.orange500),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        subtitle: Text(
          '${event.date.day}/${event.date.month} • ${event.location ?? "Paroisse"}',
          style: TextStyle(color: AppColors.slate500),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.slate400),
        onTap: () {
          debugPrint('🔵 Navigating to EventDetailScreen for event: ${event.title}');
          try {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
            );
          } catch (e, stackTrace) {
            debugPrint('🔴 ERROR navigating to EventDetailScreen: $e');
            debugPrint('Stack trace: $stackTrace');
          }
        },
      ),
    );
  }

  Widget _buildReplaysSection(BuildContext context, ChurchProvider provider) {
    if (provider.replays.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'REPLAYS', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReplayListScreen()));
        }),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.replays.length,
            padding: const EdgeInsets.only(right: 20),
            itemBuilder: (context, index) {
              final replay = provider.replays[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
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
                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: AppColors.slate100,
                                        child: const Icon(Icons.play_circle_outline, size: 40, color: Colors.white),
                                      ),
                                    )
                                  : Container(
                                      color: const Color(0xFF1E293B),
                                      child: const Icon(Icons.play_circle_outline, size: 40, color: Colors.white54),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 12,
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Replay",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              replay.title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (replay.date != null)
                              Text(
                                DateFormat('dd MMM yyyy', 'fr_FR').format(replay.date!),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.slate500,
                                ),
                              ),
                          ],
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
    );
  }


  Widget _buildCategoriesList(BuildContext context, ChurchProvider provider) {
    // Note: Temporary list since provider might not have categories yet or we use them from podcasts
    final categories = provider.categories;
    
    if (categories.isEmpty) return _buildEmptyState('Aucune catégorie.');

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () {
                debugPrint('🔵 Navigating to PodcastListScreen with category: ${cat.name}');
                try {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PodcastListScreen(initialCategory: cat),
                    ),
                  );
                } catch (e, stackTrace) {
                  debugPrint('🔴 ERROR navigating to PodcastListScreen: $e');
                  debugPrint('Stack trace: $stackTrace');
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: cat.image != null 
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: cat.image!,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              memCacheWidth: 200,
                              placeholder: (context, url) => const Icon(Icons.tag, color: AppColors.orange500),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.orange500.withOpacity(0.1),
                                child: const Icon(Icons.category, color: AppColors.orange500),
                              ),
                            ),
                          )
                        : const Icon(Icons.tag, color: AppColors.orange500, size: 30),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat.name,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.slate100.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: AppColors.slate400, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: AppColors.slate500, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class MoreMenu extends StatelessWidget {
  const MoreMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Plus'),
        centerTitle: false,
      ),
      body: Consumer<ChurchProvider>(
        builder: (context, provider, _) {
          final user = provider.currentUser;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (user != null)
                _buildMenuSection(context, 'Mon Profil', [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 25,
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      user.email,
                      style: GoogleFonts.inter(color: AppColors.slate500),
                    ),
                  ),
                ]),
              const SizedBox(height: 24),
              _buildMenuSection(context, 'Spirituel', [
            _buildMenuItem(
              context,
              icon: Icons.calendar_today_rounded,
              title: 'Agenda complet',
              subtitle: 'Événements et célébrations',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendaScreen())),
            ),
            _buildMenuItem(
              context,
              icon: Icons.volunteer_activism_rounded,
              title: 'Demande de prière',
              subtitle: 'Confiez-nous vos intentions',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerRequestScreen())),
            ),
            _buildMenuItem(
              context,
              icon: Icons.play_circle_fill_rounded,
              title: 'Replays Vidéo',
              subtitle: 'Revoir nos célébrations',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReplayListScreen())),
            ),
          ]),


          const SizedBox(height: 24),
          _buildMenuSection(context, 'Application', [
            _buildMenuItem(
              context,
              icon: Icons.info_outline_rounded,
              title: 'À propos',
              subtitle: 'Ma Paroisse Digitale v1.0',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.share_rounded,
              title: 'Partager l\'app',
              subtitle: 'Invitez vos proches',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.logout_rounded,
              title: 'Déconnexion',
              subtitle: 'Quitter la session',
              onTap: () {
                provider.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              },
            ),
          ]),
        ],
      );
    }),
  );
}

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.slate400,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate500),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: 20),
      onTap: onTap,
    );
  }
}
