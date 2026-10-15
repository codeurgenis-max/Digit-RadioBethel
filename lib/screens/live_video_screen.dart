import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/church_models.dart';
import '../providers/church_provider.dart';
import '../utils/app_colors.dart';

class LiveVideoScreen extends StatefulWidget {
  final LiveModel live;

  const LiveVideoScreen({super.key, required this.live});

  @override
  State<LiveVideoScreen> createState() => _LiveVideoScreenState();
}

class _LiveVideoScreenState extends State<LiveVideoScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool _isYoutube = false;
  bool _hasError = false;
  String? _errorMessage;
  Timer? _chatTimer;
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUrlAndInitialize();
    
    // Initial fetch and setup polling for chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChurchProvider>().fetchChatMessages();
      _chatTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        context.read<ChurchProvider>().fetchChatMessages();
      });
    });
  }

  void _checkUrlAndInitialize() {
    final url = widget.live.videoUrl;
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      _isYoutube = true;
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        final isLiveStream = widget.live.status == 'live';
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: true,
            isLive: isLiveStream,
            mute: false,
            enableCaption: false,
            controlsVisibleAtStart: true,
          ),
        );
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = "ID de vidéo YouTube invalide";
        });
      }
    } else {
      _isYoutube = false;
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.live.videoUrl));
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        isLive: widget.live.status == 'live',
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 42),
                const SizedBox(height: 12),
                Text(
                  'Erreur de lecture',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    _chatTimer?.cancel();
    if (!_isYoutube) {
      _videoPlayerController.dispose();
      _chewieController?.dispose();
    } else {
      _youtubeController?.dispose();
    }
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.live.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Video Section
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Impossible de charger la vidéo',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vérifiez votre connexion internet',
                          style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _hasError = false;
                              _chewieController = null;
                            });
                            _checkUrlAndInitialize();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : () {
                    if (_isYoutube) {
                      final controller = _youtubeController;
                      if (controller != null) {
                        return YoutubePlayer(
                          controller: controller,
                          showVideoProgressIndicator: true,
                          liveUIColor: Colors.red,
                        );
                      }
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    } else {
                      final controller = _chewieController;
                      if (controller != null) {
                        return Chewie(controller: controller);
                      }
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                  }(),
          ),
          
          // Chat Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A), // Slate-900
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Consumer<ChurchProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'CHAT EN DIRECT',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${provider.chatMessages.length} participants',
                              style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      
                      // Message List
                      Expanded(
                        child: ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: provider.chatMessages.length,
                          itemBuilder: (context, index) {
                            final msg = provider.chatMessages[index];
                            return _buildChatBubble(msg);
                          },
                        ),
                      ),
                      
                      // Input Field
                      _buildChatInput(provider),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: msg.isMe ? AppColors.orange500 : Colors.white10,
            child: Text(
              msg.userName[0],
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      msg.userName,
                      style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  msg.message,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput(ChurchProvider provider) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _chatController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Écrire un message...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) {
                  provider.sendMessage(val);
                  _chatController.clear();
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              provider.sendMessage(_chatController.text);
              _chatController.clear();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: AppColors.orange500, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
