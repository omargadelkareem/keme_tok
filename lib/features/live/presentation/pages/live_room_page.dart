import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LiveRoomData {
  final String host, title, viewers, category;
  final Color color;
  final bool paid;
  const LiveRoomData(this.host, this.title, this.viewers, this.category, this.color,
      {this.paid = false});
}

class LiveRoomPage extends StatefulWidget {
  const LiveRoomPage({super.key, required this.room});
  final LiveRoomData room;
  @override
  State<LiveRoomPage> createState() => _LiveRoomPageState();
}

class _LiveRoomPageState extends State<LiveRoomPage> {
  final input = TextEditingController();
  final messages = <String>['أهلًا بيكم في الغرفة 👋', 'منورين اللايف ❤️'];
  bool following = false;
  int hearts = 0;
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void send() {
    final message = input.text.trim();
    if (message.isEmpty) return;
    setState(() => messages.add('أنت: $message'));
    input.clear();
    FocusScope.of(context).unfocus();
  }

  void notice(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)));

  void gifts() => showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    builder: (context) => SafeArea(child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('الهدايا 🎁', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('معاينة فقط — لا يتم خصم عملات',
          style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 18),
        Wrap(spacing: 14, runSpacing: 14, children: [
          for (final gift in ['🌹 وردة', '❤️ قلب', '🎉 حفلة', '👑 تاج'])
            ActionChip(label: Text(gift), onPressed: () {
              Navigator.pop(context);
              setState(() => messages.add('أنت أرسلت $gift (تجريبي)'));
            }),
        ]),
        const SizedBox(height: 15),
      ]),
    )),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    body: SafeArea(child: Stack(children: [
      Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [widget.room.color, const Color(0xFF11111B), const Color(0xFF090911)])))),
      const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.videocam_off_outlined, size: 76, color: Colors.white54),
        SizedBox(height: 12),
        Text('معاينة غرفة بث', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text('الفيديو المباشر غير متصل حاليًا',
          style: TextStyle(color: AppColors.textSecondary)),
      ])),
      Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          CircleAvatar(backgroundColor: Colors.white24,
            child: Text(widget.room.host[0])),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.room.host, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.room.viewers + ' مشاهدة • تجريبي',
              style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ])),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: following ? Colors.grey : AppColors.pink),
            onPressed: () => setState(() => following = !following),
            child: Text(following ? 'متابع' : 'متابعة')),
          IconButton(onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white)),
        ])),
        if (widget.room.paid)
          const Padding(padding: EdgeInsets.all(8),
            child: Text('غرفة حصرية — عرض تجريبي بدون دفع',
              style: TextStyle(color: Colors.amber))),
        const Spacer(),
        SizedBox(height: 160, child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: messages.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Text(messages[index], style: const TextStyle(
              color: Colors.white, shadows: [Shadow(blurRadius: 5, color: Colors.black)]))),
        )),
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
          child: Row(children: [
            Expanded(child: TextField(
              controller: input,
              onSubmitted: (_) => send(),
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'اكتب تعليق...',
                filled: true, fillColor: Colors.white12,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),
            )),
            IconButton(onPressed: send, icon: const Icon(Icons.send, color: AppColors.cyan)),
            IconButton(onPressed: gifts, icon: const Icon(Icons.card_giftcard, color: AppColors.pink)),
            IconButton(onPressed: () => notice('تم إرسال طلب ضيف تجريبي'),
              icon: const Icon(Icons.group_add_outlined, color: Colors.white)),
            IconButton(onPressed: () => setState(() => hearts++),
              icon: const Icon(Icons.favorite, color: AppColors.pink)),
          ])),
        if (hearts > 0) Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('❤️ $hearts', style: const TextStyle(color: AppColors.pink))),
      ]),
    ])),
  );
}
