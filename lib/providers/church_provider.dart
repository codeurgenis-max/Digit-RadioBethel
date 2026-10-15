import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/church_models.dart';
import '../services/api_service.dart';
import '../services/web_audio_player.dart' if (dart.library.io) '../services/web_audio_stub.dart';

class ChurchProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  // Web-specific audio player for streaming on browsers
  final _webPlayer = kIsWeb ? WebAudioPlayer() : null;

  RadioModel? _radio;
  LiveModel? _live;
  VerseModel? _verse;
  List<EventModel> _upcomingEvents = [];
  List<PodcastModel> _podcasts = [];
  List<CategoryModel> _categories = [];
  List<EventModel> _fullAgenda = [];
  List<ReplayModel> _replays = [];


  UserModel? _currentUser;
  bool _isAuthenticated = false;

  PodcastModel? _currentPodcast;
  bool _isPlaying = false;
  bool _isRadioPlaying = false;
  bool _isLoading = false;
  bool _isCheckingAuth = true;

  RadioModel? get radio => _radio;
  LiveModel? get live => _live;
  VerseModel? get verse => _verse;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  List<PodcastModel> get podcasts => _podcasts;
  List<CategoryModel> get categories => _categories;
  List<EventModel> get fullAgenda => _fullAgenda;
  List<ReplayModel> get replays => _replays;

  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  PodcastModel? get currentPodcast => _currentPodcast;
  bool get isPlaying => _isPlaying;
  bool get isRadioPlaying => _isRadioPlaying;
  bool get isCheckingAuth => _isCheckingAuth;

  // Audio Player Streams
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<Duration> get bufferedPositionStream => _audioPlayer.bufferedPositionStream;

  ChurchProvider() {
    _initAudioSession();
    _initPlayerListeners();
    checkAuth();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Handle interruptions (calls, other apps)
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.pause:
          case AudioInterruptionType.duck:
            _audioPlayer.pause();
            break;
          case AudioInterruptionType.unknown:
            _audioPlayer.pause();
            break;
        }
      } else {
        if (event.type == AudioInterruptionType.pause || event.type == AudioInterruptionType.duck) {
          _audioPlayer.play();
        }
      }
    });

    // Handle unplugging headphones
    session.becomingNoisyEventStream.listen((_) {
      _audioPlayer.pause();
    });
  }

  void _initPlayerListeners() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing && _currentPodcast != null;
      _isRadioPlaying = state.playing && _currentPodcast == null;
      notifyListeners();
    });

    _audioPlayer.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
      debugPrint('A stream error occurred: $e');
    });
  }


  Future<void> checkAuth() async {
    _isCheckingAuth = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      _apiService.setToken(token);
      try {
        final response = await _apiService.getUserProfile();
        if (response.data != null && response.data is Map) {
          _currentUser = UserModel.fromJson(Map<String, dynamic>.from(response.data));
          _isAuthenticated = true;
          // Trigger full data load after successful auth
          _initializeData();
        } else {
          debugPrint('⚠️ Invalid user profile data');
          _apiService.setToken(null);
          _initializeData(); // Load data anyway
        }
      } catch (e) {
        debugPrint('Auto-login error: $e');
        _apiService.setToken(null);
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        _initializeData(); // Load data anyway
      }
    } else {
      _initializeData(); // Load data for unauthenticated user
    }
    
    _isCheckingAuth = false;
    notifyListeners();
  }

  /// Centralized method to load all data reliably
  Future<void> refreshAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Parallel loading for better performance
      await Future.wait([
        fetchHomeData(),
        fetchPodcasts(),
        fetchAgenda(),
        fetchCategories(),
        fetchReplays(),
      ]);
    } catch (e) {
      debugPrint('Error refreshing all data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _initializeData() async {
    // 1. Load cached data (INSTANT UI UPDATE)
    await _loadHomeCache();

      
      // 2. Initialize verse (Fast)
      _syncDailyVerse();
      
      // 3. Load everything else from network
      refreshAllData();
  }


  Future<void> togglePodcast(PodcastModel podcast) async {
    try {
      if (_currentPodcast?.id == podcast.id) {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.play();
        }
      } else {
        _currentPodcast = podcast;
        _isRadioPlaying = false;
        notifyListeners();

        // Find category name for the album tag
        String? categoryName;
        try {
          categoryName = _categories.firstWhere((c) => c.id == podcast.categoryId).name;
        } catch (_) {
          categoryName = "Podcast";
        }

        // Use AudioSource.uri with MediaItem for background playback support
        final audioSource = AudioSource.uri(
          Uri.parse(podcast.audioUrl),
          tag: MediaItem(
            id: podcast.id.toString(),
            album: categoryName,
            title: podcast.title,
            artist: podcast.speaker ?? "Ma Paroisse",
            artUri: podcast.coverImage != null ? Uri.parse(podcast.coverImage!) : null,
          ),
        );

        await _audioPlayer.setAudioSource(audioSource);
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Error playing podcast: $e');
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> toggleRadio() async {
    try {
      if (_radio == null) return;
      
      if (_isRadioPlaying) {
        // Stop playback
        if (kIsWeb) {
          _webPlayer?.stop();
        } else {
          await _audioPlayer.stop();
        }
        _isRadioPlaying = false;
        _isPlaying = false;
        notifyListeners();
      } else {
        _isLoading = true;
        _isRadioPlaying = false;
        notifyListeners();
        
        // Stop any existing playback
        if (kIsWeb) {
          _webPlayer?.stop();
        } else {
          await _audioPlayer.stop();
        }
        _currentPodcast = null; 

        final streamUrl = _radio?.streamUrl ?? '';

        if (kIsWeb) {
          // === WEB: Use direct HTML5 Audio element ===
          try {
            await _webPlayer!.play(streamUrl);
            _isRadioPlaying = true;
            _isPlaying = false;
            _isLoading = false;
            notifyListeners();
          } catch (e) {
            debugPrint('Web audio error: $e');
            _isLoading = false;
            _isRadioPlaying = false;
            notifyListeners();
          }
        } else {
          // === MOBILE: Use just_audio with background support ===
          try {
            final audioSource = AudioSource.uri(
              Uri.parse(streamUrl),
              tag: MediaItem(
                id: 'radio_stream',
                album: "Direct",
                title: _radio?.currentTheme ?? "Radio Digit Bethel",
                artist: _radio?.currentPastor ?? "En Direct",
                artUri: _radio?.coverImage != null 
                  ? Uri.parse(_radio!.coverImage!) 
                  : Uri.parse("https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?q=80&w=500"), 
              ),
              headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                'Connection': 'keep-alive',
                'Icy-MetaData': '1',
              },
            );

            await _audioPlayer.setAudioSource(audioSource, preload: true);
            await _audioPlayer.setVolume(1.0);
            await _audioPlayer.setSpeed(1.0);
            _audioPlayer.play();
            
            _isRadioPlaying = true;
            _isPlaying = false;
            _isLoading = false;
            notifyListeners();
          } catch (sourceError) {
            debugPrint('First attempt failed ($sourceError), retrying...');
            final fallbackSource = AudioSource.uri(Uri.parse(streamUrl));
            await _audioPlayer.setAudioSource(fallbackSource);
            _audioPlayer.play();
            
            _isRadioPlaying = true;
            _isPlaying = false;
            _isLoading = false;
            notifyListeners();
          }
        }
      }
    } catch (e) {
      _isLoading = false;
      _isRadioPlaying = false;
      notifyListeners();
      debugPrint('Error playing radio: $e');
    }
  }



  List<ChatMessage> _chatMessages = [];
  List<ChatMessage> get chatMessages => _chatMessages;

  Future<void> fetchChatMessages() async {
    try {
      final response = await _apiService.getChatMessages();
      if (response.data is List) {
        _chatMessages = (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => ChatMessage.fromJson(e, currentUserId: _currentUser?.id))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching chat messages: $e');
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Optimistic UI update
    final tempId = DateTime.now().millisecondsSinceEpoch;
    final tempMsg = ChatMessage(
      id: tempId,
      userId: _currentUser?.id,
      userName: _currentUser?.name ?? 'Moi',
      message: text,
      createdAt: DateTime.now(),
      isMe: true,
    );
    
    _chatMessages.insert(0, tempMsg);
    notifyListeners();

    try {
      await _apiService.sendChatMessage(text, userName: _currentUser?.name);
      // Refresh to get the real ID and timestamps from server
      await fetchChatMessages();
    } catch (e) {
      debugPrint('Error sending message: $e');
      // Remove optimistic message on failure
      _chatMessages.removeWhere((m) => m.id == tempId);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.login(email, password);
      final data = response.data;
      
      final token = data['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      _apiService.setToken(token);
      _currentUser = UserModel.fromJson(data['user']);
      _isAuthenticated = true;
      
      // Load all data after login
      _initializeData();
      
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.register(name, email, password);
      final data = response.data;
      
      final token = data['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      _apiService.setToken(token);
      _currentUser = UserModel.fromJson(data['user']);
      _isAuthenticated = true;
      
      // Load all data after registration
      _initializeData();
      
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _apiService.setToken(null);
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  bool _isFetchingHome = false;
  Future<void> fetchHomeData() async {
    if (_isFetchingHome) return;
    _isFetchingHome = true;
    
    // Only show full-screen loader if we have no data at all
    if (_replays.isEmpty && _upcomingEvents.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await _apiService.getHome();
      
      // Strict safety check on response data
      if (response.data == null || response.data is! Map) {
         debugPrint('⚠️ Invalid home data format');
         return;
      }
      
      final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);
      
      _parseHomeData(data);
        
      // Save data to cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('home_cache', jsonEncode(data));
      
      debugPrint('🏠 Home data refreshed from network');
    } catch (e) {
      debugPrint('Error fetching home data: $e');
    } finally {
      _isLoading = false;
      _isFetchingHome = false;
      notifyListeners();
    }
  }

  Future<void> _loadHomeCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('home_cache');
      
      if (cachedJson != null) {
        final data = jsonDecode(cachedJson) as Map<String, dynamic>;
        _parseHomeData(data);
        debugPrint('📦 Loaded Home data from cache');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading home cache: $e');
    }
  }

  void _parseHomeData(Map<String, dynamic> data) {
    if (data['radio'] != null && data['radio'] is Map) {
      _radio = RadioModel.fromJson(Map<String, dynamic>.from(data['radio']));
    }
    
    if (data['live'] != null && data['live'] is Map) {
      _live = LiveModel.fromJson(Map<String, dynamic>.from(data['live']));
    }
    
    if (data['verse'] != null && data['verse'] is Map) {
      _verse = VerseModel.fromJson(Map<String, dynamic>.from(data['verse']));
    }

    if (data['upcoming_events'] != null && data['upcoming_events'] is List) {
      _upcomingEvents = (data['upcoming_events'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => EventModel.fromJson(e))
          .toList();
    }
    
    if (data['categories'] != null && data['categories'] is List) {
      _categories = (data['categories'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    }

    if (data['replays'] != null && data['replays'] is List) {
      _replays = (data['replays'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ReplayModel.fromJson(e))
          .toList();
    }
  }

  bool _isSyncingVerse = false;

  Future<void> _syncDailyVerse() async {
    if (_isSyncingVerse) return;
    _isSyncingVerse = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final cachedDate = prefs.getString('last_verse_date');
      final cachedContent = prefs.getString('daily_verse_content');
      final cachedRef = prefs.getString('daily_verse_ref');

      // Use cached if it's from today AND isn't just a fallback (optional optimization, but let's re-sync once to satisfy user)
      if (cachedDate == today && cachedContent != null && cachedRef != null && !cachedContent.contains('Car Dieu a tant aimé')) {
        _verse = VerseModel(content: cachedContent, reference: cachedRef);
        // We still proceed to try and get a "real" internet one if the cached one was a fallback
      }

      final List<Map<String, String>> localVerses = [
        {'content': 'Car Dieu a tant aimé le monde qu\'il a donné son Fils unique, afin que quiconque croit en lui ne périsse point, mais qu\'il ait la vie éternelle.', 'ref': 'Jean 3:16'},
        {'content': 'Je puis tout par celui qui me fortifie.', 'ref': 'Philippiens 4:13'},
        {'content': 'L\'Éternel est mon berger: je ne manquerai de rien.', 'ref': 'Psaume 23:1'},
        {'content': 'Ne t\'ai-je pas donné cet ordre: Fortifie-toi et prends courage? Ne t\'effraie point et ne t\'épouvante point, car l\'Éternel, ton Dieu, est avec toi dans tout ce que tu entreprendras.', 'ref': 'Josué 1:9'},
        {'content': 'Confie-toi en l\'Éternel de tout ton cœur, et ne t\'appuie pas sur ta prudence.', 'ref': 'Proverbes 3:5'},
        {'content': 'Soyez toujours joyeux. Priez sans cesse. Rendez grâces en toutes choses.', 'ref': '1 Thessaloniciens 5:16-18'},
        {'content': 'Car je connais les projets que j\'ai formés sur vous, dit l\'Éternel, projets de paix et non de malheur, afin de vous donner un avenir et de l\'espérance.', 'ref': 'Jérémie 29:11'},
        {'content': 'Le Seigneur est ma lumière et mon salut: de qui aurais-je crainte?', 'ref': 'Psaume 27:1'},
        {'content': 'Si Dieu est pour nous, qui sera contre nous ?', 'ref': 'Romains 8:31'},
        {'content': 'Tout ce que vous demanderez avec foi par la prière, vous le recevrez.', 'ref': 'Matthieu 21:22'},
        {'content': 'La paix soit avec vous ! Comme le Père m\'a envoyé, moi aussi je vous envoie.', 'ref': 'Jean 20:21'},
        {'content': 'Que la grâce du Seigneur Jésus-Christ, l\'amour de Dieu, et la communication du Saint-Esprit, soient avec vous tous !', 'ref': '2 Corinthiens 13:13'},
        {'content': 'Recommande à l\'Éternel tes œuvres, et tes projets réussiront.', 'ref': 'Proverbes 16:3'},
        {'content': 'Ta parole est une lampe à mes pieds, et une lumière sur mon sentier.', 'ref': 'Psaume 119:105'},
        {'content': 'Le fruit de l\'Esprit, c\'est l\'amour, la joie, la paix, la patience, la bonté, la bénignité, la fidélité, la douceur, la tempérance.', 'ref': 'Galates 5:22'},
        {'content': 'Que ton cœur ne se trouble point. Crois en Dieu, et crois en moi.', 'ref': 'Jean 14:1'},
        {'content': 'Soyez bons les uns envers les autres, compatissants, vous pardonnant réciproquement, comme Dieu vous a pardonné en Christ.', 'ref': 'Éphésiens 4:32'},
        {'content': 'L\'amour est patient, il est plein de bonté; l\'amour n\'est point envieux; l\'amour ne se vante point, il ne s\'enfle point d\'orgueil.', 'ref': '1 Corinthiens 13:4'},
      ];

      // Default to local rotation
      final now = DateTime.now();
      final dayOfYear = int.parse(DateFormat('D').format(now));
      final index = dayOfYear % localVerses.length;
      
      String newContent = localVerses[index]['content'] ?? '';
      String newRef = localVerses[index]['ref'] ?? '';

      try {
        // Attempt external sync (real VOTD from bible.org)
        final response = await _apiService.getExternalVerse();
        final data = response.data;
        
        if (data is List && data.isNotEmpty) {
          final verseObj = data[0];
          if (verseObj is Map && verseObj.containsKey('text')) {
             final String originalRef = '${verseObj['bookname']} ${verseObj['chapter']}:${verseObj['verse']}';
             debugPrint('📖 Official Internet VOTD: $originalRef');
             
             // Try to find French translation for this reference
             final frResponse = await _apiService.getFrenchPassage(originalRef);
             if (frResponse != null && frResponse.data != null && frResponse.data['text'] != null) {
                newContent = frResponse.data['text'].toString().trim();
                newRef = frResponse.data['reference'] ?? originalRef;
                debugPrint('🇫🇷 Successfully translated internet verse to French');
             } else {
                // If translation fails, use English but clean up HTML entities
                newContent = verseObj['text'].toString()
                    .replaceAll('&ldquo;', '"')
                    .replaceAll('&rdquo;', '"')
                    .replaceAll('&#39;', "'")
                    .trim();
                newRef = originalRef;
                debugPrint('⚠️ Translation failed, using English internet verse');
             }
          }
        }
      } catch (externalError) {
        debugPrint('External verse API failed: $externalError');
      }

      await prefs.setString('last_verse_date', today);
      await prefs.setString('daily_verse_content', newContent);
      await prefs.setString('daily_verse_ref', newRef);
      _verse = VerseModel(content: newContent, reference: newRef);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing daily verse: $e');
    } finally {
      _isSyncingVerse = false;
    }
  }

  bool _isFetchingPodcasts = false;
  Future<void> fetchPodcasts() async {
    try {
      final response = await _apiService.getPodcasts();
      if (response.data != null && response.data is List) {
        final List listData = response.data;
        _podcasts = listData
            .where((e) => e != null && e is Map)
            .map((e) => PodcastModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        debugPrint('🎙️ Podcasts fetched: ${_podcasts.length} items');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching podcasts: $e');
    } finally {
      _isFetchingPodcasts = false;
    }
  }

  Future<void> fetchAgenda() async {
    try {
      final response = await _apiService.getAgenda();
      if (response.data != null && response.data is List) {
        final List listData = response.data;
        _fullAgenda = listData
            .where((e) => e != null && e is Map)
            .map((e) => EventModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching agenda: $e');
    }
  }

  Future<bool> submitPrayerRequest(String name, String request) async {
    try {
      await _apiService.submitPrayer(name, request);
      return true;
    } catch (e) {
      debugPrint('Error submitting prayer request: $e');
      return false;
    }
  }
  Future<void> fetchCategories() async {
    try {
      final response = await _apiService.getCategories();
      if (response.data is List) {
        _categories = (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => CategoryModel.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchReplays() async {
    try {
      final response = await _apiService.getReplays();
      if (response.data != null && response.data is List) {
        final List listData = response.data;
        _replays = listData
            .where((e) => e != null && e is Map)
            .map((e) => ReplayModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching replays: $e');
    }
  }
}

