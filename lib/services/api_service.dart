import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://digiteradio-xi.vercel.app/api',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    validateStatus: (status) => status != null && status < 500, // Handle 404/401 gracefully
  ));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('🚀 API: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ API: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint('❌ API: ${e.response?.statusCode ?? "Error"} ${e.requestOptions.path}');
        return handler.next(e);
      },
    ));
  }
  String? _token;

  void setToken(String? token) {
    _token = token;
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      return response;
    } catch (e) {
      debugPrint('Error logging in: $e');
      rethrow;
    }
  }

  Future<Response> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return response;
    } catch (e) {
      debugPrint('Error registering: $e');
      rethrow;
    }
  }

  Future<Response> getHome() async {
    try {
      return await _dio.get('/home');
    } catch (e) {
      debugPrint('Error fetching home data: $e');
      rethrow;
    }
  }

  Future<Response> getPodcasts() async {
    try {
      return await _dio.get('/podcasts');
    } catch (e) {
      debugPrint('Error fetching podcasts: $e');
      rethrow;
    }
  }

  Future<Response> getCategories() async {
    try {
      return await _dio.get('/categories');
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<Response> getReplays() async {
    try {
      return await _dio.get('/replays');
    } catch (e) {
      debugPrint('Error fetching replays: $e');
      rethrow;
    }
  }

  Future<Response> getAgenda() async {
    try {
      return await _dio.get('/agenda');
    } catch (e) {
      debugPrint('Error fetching agenda: $e');
      rethrow;
    }
  }

  Future<Response?> submitPrayer(String name, String request) async {
    try {
      return await _dio.post('/prayer', data: {
        'name': name,
        'request': request,
      });
    } catch (e) {
      debugPrint('Error submitting prayer: $e');
      return null;
    }
  }

  Future<Response> getChatMessages() async {
    try {
      return await _dio.get('/chat');
    } catch (e) {
      debugPrint('Error fetching chat messages: $e');
      rethrow;
    }
  }

  Future<Response> sendChatMessage(String message, {String? userName}) async {
    try {
      return await _dio.post('/chat', data: {
        'message': message,
        'user_name': userName,
      });
    } catch (e) {
      debugPrint('Error sending chat message: $e');
      rethrow;
    }
  }

  Future<Response> getUserProfile() async {
    try {
      return await _dio.get('/user');
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      rethrow;
    }
  }

  Future<Response> getExternalVerse() async {
    try {
      // Use bible.org official Verse of the Day API
      return await Dio().get('https://labs.bible.org/api/?passage=votd&type=json');
    } catch (e) {
      debugPrint('Error fetching external verse: $e');
      rethrow;
    }
  }

  Future<Response?> getFrenchPassage(String reference) async {
    try {
      // Use bible-api.com with LSG (Louis Segond) translation
      return await Dio().get('https://bible-api.com/$reference?translation=lsg');
    } catch (e) {
      debugPrint('Error fetching French passage ($reference): $e');
      return null;
    }
  }
}


