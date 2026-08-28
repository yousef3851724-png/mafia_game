import 'package:flutter/material.dart';
import '../../domain/entities/player.dart';
import '../widgets/player_avatar_card.dart';

class GameRoomScreen extends StatefulWidget {
  final String roomId;

  const GameRoomScreen({super.key, this.roomId = "ROOM-101"});

  @override
  State<GameRoomScreen> createState() => _GameRoomScreenState();
}

class _GameRoomScreenState extends State<GameRoomScreen> {
  String? selectedPlayerId;

  final List<Player> players = const [
    Player(id: '1', name: 'پدرخوانده', role: 'مافیا'),
    Player(id: '2', name: 'دکتر لکتر', role: 'مافیا'),
    Player(id: '3', name: 'کارآگاه', role: 'شهروند'),
    Player(id: '4', name: 'پزشک', role: 'شهروند'),
    Player(id: '5', name: 'اسنایپر', role: 'شهروند'),
    Player(id: '6', name: 'شهروند ساده', role: 'شهروند', isAlive: false),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('اتاق بازی: ${widget.roomId}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // نوار وضعیت فاز بازی
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.wb_sunny, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('فاز روز: گفت‌وگو و رای‌گیری', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Text('00:45', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),

          // گرید بازیکنان
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return PlayerAvatarCard(
                  player: player,
                  isSelected: selectedPlayerId == player.id,
                  onTap: () {
                    setState(() {
                      selectedPlayerId = player.id;
                    });
                  },
                );
              },
            ),
          ),

          // دکمه اقدام/رای
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: selectedPlayerId == null
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('رای شما به بازیکن $selectedPlayerId ثبت شد!')),
                        );
                      },
                icon: const Icon(Icons.how_to_vote, color: Colors.white),
                label: const Text('ثبت رأی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
