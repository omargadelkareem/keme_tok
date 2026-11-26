import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class Creator {
  const Creator(this.id, this.name, this.handle, this.bio, this.followers,
      this.likes, this.color);
  final String id, name, handle, bio;
  final int followers, likes, color;
}

class CreatorStore extends ChangeNotifier {
  CreatorStore._() { _following = (_box.read<List<dynamic>>('following_creators_v1') ?? [])
      .map((e) => e.toString()).toSet(); }
  static final CreatorStore instance = CreatorStore._();
  final GetStorage _box = GetStorage();
  late Set<String> _following;
  static const creators = <Creator>[
    Creator('maya', 'Maya', '@maya.live', 'موسيقى، لايفات وضحك كل يوم ✨', 12400, 85000, 0xFFDF468C),
    Creator('adam', 'Adam', '@adam.creates', 'صانع محتوى • كل يوم حكاية جديدة 🎬', 8600, 41000, 0xFF20C8D5),
    Creator('nour', 'Nour', '@nour.show', 'تحديات ولايفات ومفاجآت 💜', 24700, 125000, 0xFF8965EF),
    Creator('sara', 'Sara', '@sara.vibes', 'لحظات لطيفة ومحتوى لايت 🌸', 5100, 19300, 0xFFFFA257),
  ];
  bool isFollowing(String id) => _following.contains(id);
  int followingCount() => _following.length;
  Future<void> toggle(String id) async {
    if (!_following.add(id)) _following.remove(id);
    await _box.write('following_creators_v1', _following.toList());
    notifyListeners();
  }
}
