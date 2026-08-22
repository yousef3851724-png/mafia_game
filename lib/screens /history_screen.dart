import 'package:flutter/material.dart';
import 'package:mafia_game/database/app_database.dart';
import 'package:mafia_game/models/game_history_model.dart';
import 'package:mafia_game/utils/export_data.dart';
import 'package:share_plus/share_plus.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<GameHistoryModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final db = AppDatabase();
    _history = await db.getGameHistory();
    setState(() => _isLoading = false);
  }

  Future<void> _shareHistory() async {
    String text = ExportData.exportToText(_history);
    await Share.share(text, subject: 'تاریخچه بازی‌های مافیا');
  }

  Future<void> _clearHistory() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('پاک کردن تاریخچه'),
        content: const Text('آیا مطمئن هستید؟ این عمل قابل بازگشت نیست.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final db = AppDatabase();
              await db.clearHistory();
              await _loadHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تاریخچه پاک شد')),
              );
            },
            child: const Text('پاک کن', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📜 تاریخچه بازی‌ها'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareHistory,
            ),
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'تاریخچه‌ای وجود ندارد',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.winner.contains('مافیا')
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          child: Icon(
                            item.winner.contains('مافیا')
                                ? Icons.emoji_emotions
                                : Icons.emoji_events,
                            color: item.winner.contains('مافیا')
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        title: Text('🏆 ${item.winner}'),
                        subtitle: Text(
                          '👥 ${item.players.length} نفر  |  🌙 ${item.nights} شب  |  ${item.timestamp.toLocal()}',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
