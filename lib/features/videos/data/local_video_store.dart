import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

class LocalVideo {
  const LocalVideo({required this.id, required this.path, required this.caption,
    required this.createdAt, this.likes = 0, this.liked = false,
    this.comments = const <String>[]});
  final String id, path, caption, createdAt;
  final int likes;
  final bool liked;
  final List<String> comments;
  factory LocalVideo.fromJson(Map<String, dynamic> json) => LocalVideo(
    id: json['id'] as String, path: json['path'] as String,
    caption: json['caption'] as String? ?? '',
    createdAt: json['createdAt'] as String? ?? '',
    likes: json['likes'] as int? ?? 0, liked: json['liked'] as bool? ?? false,
    comments: (json['comments'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
  );
  Map<String, dynamic> toJson() => {
    'id': id, 'path': path, 'caption': caption, 'createdAt': createdAt,
    'likes': likes, 'liked': liked, 'comments': comments,
  };
  LocalVideo copyWith({int? likes, bool? liked, List<String>? comments}) =>
    LocalVideo(id: id, path: path, caption: caption, createdAt: createdAt,
      likes: likes ?? this.likes, liked: liked ?? this.liked,
      comments: comments ?? this.comments);
}

class LocalVideoStore extends ChangeNotifier {
  LocalVideoStore._() { _load(); }
  static final LocalVideoStore instance = LocalVideoStore._();
  static const _key = 'local_reels_v1';
  final GetStorage _box = GetStorage();
  List<LocalVideo> _videos = [];
  List<LocalVideo> get videos => List.unmodifiable(_videos);

  void _load() {
    try {
      final raw = _box.read<List<dynamic>>(_key) ?? <dynamic>[];
      _videos = raw.map((e) => LocalVideo.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) { _videos = []; }
    notifyListeners();
  }

  Future<void> _save() async {
    await _box.write(_key, _videos.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  Future<void> publish(String sourcePath, String caption) async {
    final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/keme_reels');
    await dir.create(recursive: true);
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final source = File(sourcePath);
    final extension = source.path.split('.').last.toLowerCase();
    final safeExtension = ['mp4', 'mov', 'm4v', 'webm'].contains(extension) ? extension : 'mp4';
    final destination = await source.copy('${dir.path}/$id.$safeExtension');
    _videos.insert(0, LocalVideo(id: id, path: destination.path,
      caption: caption, createdAt: DateTime.now().toIso8601String()));
    await _save();
  }

  Future<void> toggleLike(String id) async {
    _videos = _videos.map((v) => v.id == id
      ? v.copyWith(liked: !v.liked, likes: (v.likes + (v.liked ? -1 : 1)).clamp(0, 999999).toInt())
      : v).toList();
    await _save();
  }

  Future<void> addComment(String id, String comment) async {
    if (comment.trim().isEmpty) return;
    _videos = _videos.map((v) => v.id == id
      ? v.copyWith(comments: [...v.comments, comment.trim()]) : v).toList();
    await _save();
  }

  Future<void> delete(String id) async {
    final matches = _videos.where((v) => v.id == id).toList();
    _videos.removeWhere((v) => v.id == id);
    await _save();
    for (final video in matches) {
      try { final file = File(video.path); if (await file.exists()) await file.delete(); }
      catch (_) { /* Metadata is already removed. */ }
    }
  }
}
