class RadioModel {
  final int id;
  final String streamUrl;
  final String? currentPastor;
  final String? currentTheme;
  final bool isOnline;
  final String? coverImage;

  RadioModel({
    required this.id,
    required this.streamUrl,
    this.currentPastor,
    this.currentTheme,
    required this.isOnline,
    this.coverImage,
  });

  factory RadioModel.fromJson(Map<String, dynamic> json) {
    return RadioModel(
      id: json['id'] ?? 0,
      streamUrl: json['stream_url']?.toString() ?? '',
      currentPastor: json['current_pastor']?.toString(),
      currentTheme: json['current_theme']?.toString(),
      isOnline: json['is_online'] == 1 || json['is_online'] == true || json['is_online'] == '1',
      coverImage: json['cover_image']?.toString(),
    );
  }
}

class LiveModel {
  final int id;
  final String title;
  final String videoUrl;
  final DateTime? startTime;
  final String status;

  LiveModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    this.startTime,
    required this.status,
  });

  factory LiveModel.fromJson(Map<String, dynamic> json) {
    return LiveModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? 'Sans titre',
      videoUrl: json['video_url']?.toString() ?? '',
      startTime: json['start_time'] != null ? DateTime.tryParse(json['start_time'].toString()) : null,
      status: json['status']?.toString() ?? 'offline',
    );
  }
}

class VerseModel {
  final int? id;
  final String content;
  final String reference;

  VerseModel({
    this.id,
    required this.content,
    required this.reference,
  });

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    return VerseModel(
      id: json['id'],
      content: json['content']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
    );
  }
}

class EventModel {
  final int id;
  final String title;
  final String? description;
  final DateTime date;
  final String? location;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.location,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      location: json['location']?.toString(),
    );
  }
}

class PodcastModel {
  final int id;
  final String title;
  final String? description;
  final String audioUrl;
  final String? coverImage;
  final int categoryId;
  final String? speaker;
  final DateTime? date;

  PodcastModel({
    required this.id,
    required this.title,
    this.description,
    required this.audioUrl,
    this.coverImage,
    required this.categoryId,
    this.speaker,
    this.date,
  });

  factory PodcastModel.fromJson(Map<String, dynamic> json) {
    return PodcastModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      audioUrl: json['audio_url']?.toString() ?? '',
      coverImage: json['cover_image']?.toString(),
      categoryId: json['category_id'] ?? 0,
      speaker: json['speaker']?.toString(),
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
    );
  }
}
class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? image;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      image: json['image_url']?.toString() ?? json['image']?.toString(),
    );
  }
}

class ChatMessage {
  final int id;
  final int? userId;
  final String userName;
  final String message;
  final DateTime createdAt;
  final bool isMe;

  ChatMessage({
    required this.id,
    this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
    this.isMe = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, {int? currentUserId}) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch,
      userId: json['user_id'],
      userName: json['user_name']?.toString() ?? 'Anonyme',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      isMe: (currentUserId != null && json['user_id'] == currentUserId),
    );
  }
}


class ReplayModel {
  final int id;
  final String title;
  final String videoUrl;
  final String? coverImage;
  final DateTime? date;

  ReplayModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    this.coverImage,
    this.date,
  });

  factory ReplayModel.fromJson(Map<String, dynamic> json) {
    return ReplayModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? 'Sans titre',
      videoUrl: json['video_url']?.toString() ?? '',
      coverImage: json['cover_image']?.toString(),
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
    );
  }
}

class UserModel {

  final int id;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? 'Utilisateur',
      email: json['email']?.toString() ?? '',
    );
  }
}
