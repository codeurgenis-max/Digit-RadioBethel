import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/church_provider.dart';
import '../utils/app_colors.dart';
import 'event_detail_screen.dart';
import '../widgets/skeleton_widgets.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<ChurchProvider>().fetchAgenda();
        } catch (e) {
          debugPrint('Error fetching agenda in initState: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: Consumer<ChurchProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              if (provider.fullAgenda.isEmpty && provider.isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const EventSkeleton(),
                      childCount: 8,
                    ),
                  ),
                )
              else if (provider.fullAgenda.isEmpty)
                _buildEmptyState()
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = provider.fullAgenda[index];
                        return _buildEventCard(context, event);
                      },
                      childCount: provider.fullAgenda.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Agenda de la Paroisse',
          style: GoogleFonts.poppins(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
    );
  }

  Widget _buildEventCard(BuildContext context, dynamic event) {
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.orange500.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd').format(event.date),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppColors.red700,
                        ),
                      ),
                      Text(
                        DateFormat('MMM', 'fr_FR').format(event.date).toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.orange500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: AppColors.slate400),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('HH:mm').format(event.date),
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate500),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.location_on_outlined, size: 14, color: AppColors.slate400),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location ?? 'Paroisse',
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_outlined, size: 64, color: AppColors.slate300),
            const SizedBox(height: 16),
            Text(
              'Aucun événement à afficher',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.slate500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
