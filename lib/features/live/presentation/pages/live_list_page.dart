import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'live_room_page.dart';

class LiveListPage extends StatefulWidget {
  const LiveListPage({super.key});
  @override
  State<LiveListPage> createState() => _LiveListPageState();
}

class _LiveListPageState extends State<LiveListPage> {
  int filter = 0;
  static const rooms = <LiveRoomData>[
    LiveRoomData('Maya', 'سهرة موسيقى ووناسة', '1.2K', 'موسيقى', Color(0xFF7B2E69)),
    LiveRoomData('Adam', 'احكيلنا يومك', '856', 'دردشة', Color(0xFF12616D)),
    LiveRoomData('Nour', 'تحدي PK الليلة', '2.4K', 'تحديات', Color(0xFF5341A0)),
    LiveRoomData('Sara', 'جلسة أصحاب', '530', 'دردشة', Color(0xFF9A4A5A)),
    LiveRoomData('Karim', 'مواهب على الهوا', '940', 'مواهب', Color(0xFF3A6670)),
    LiveRoomData('Laila', 'سهرة خاصة', '320', 'حصري', Color(0xFF704A9D), paid: true),
  ];

  @override
  Widget build(BuildContext context) {
    final visible = filter == 0 ? rooms : rooms.where((r) =>
      filter == 1 ? !r.paid : r.paid).toList();
    return Column(children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(18, 20, 18, 8),
        child: Row(children: [
          Expanded(child: Text('استكشف اللايف', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
          Icon(Icons.sensors, color: AppColors.pink),
        ]),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Align(alignment: Alignment.centerLeft,
          child: Text('غرف تجريبية لاستعراض تجربة البث',
            style: TextStyle(color: AppColors.textSecondary))),
      ),
      SizedBox(height: 58, child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        children: List.generate(3, (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: ChoiceChip(
            selected: filter == i,
            onSelected: (_) => setState(() => filter = i),
            label: Text(['الكل', 'مجاني', 'حصري'][i]),
            selectedColor: AppColors.pink,
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(color: filter == i ? Colors.white : AppColors.textSecondary),
          ),
        )),
      )),
      Expanded(child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 22),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: .78, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemCount: visible.length,
        itemBuilder: (context, index) {
          final room = visible[index];
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => LiveRoomPage(room: room))),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [room.color, AppColors.surface]),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: room.paid ? Colors.amber.shade700 : AppColors.pink,
                      borderRadius: BorderRadius.circular(7)),
                    child: Text(room.paid ? 'VIP' : 'LIVE',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  const Icon(Icons.visibility_outlined, size: 14),
                  const SizedBox(width: 3),
                  Text(room.viewers, style: const TextStyle(fontSize: 11)),
                ]),
                const Spacer(),
                Center(child: CircleAvatar(radius: 35,
                  backgroundColor: Colors.white12,
                  child: Text(room.host[0], style: const TextStyle(
                    fontSize: 37, fontWeight: FontWeight.bold)))),
                const Spacer(),
                Text(room.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text('${room.host} • ${room.category}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
          );
        },
      )),
    ]);
  }
}
