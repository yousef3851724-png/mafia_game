import 'dart:convert';
import 'package:mafia_game/models/game_history_model.dart';

class ExportData {
  static String exportToJson(List<GameHistoryModel> history) {
    List<Map<String, dynamic>> list = history.map((item) {
      return {
        'players': item.players,
        'winner': item.winner,
        'nights': item.nights,
        'timestamp': item.timestamp.toIso8601String(),
      };
    }).toList();
    return jsonEncode(list);
  }

  static String exportToText(List<GameHistoryModel> history) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════');
    buffer.writeln('🎭 تاریخچه بازی‌های مافیا');
    buffer.writeln('═══════════════════════════════════\n');

    for (var item in history) {
      buffer.writeln('📅 تاریخ: ${item.timestamp.toLocal()}');
      buffer.writeln('👥 بازیکنان: ${item.players.join(', ')}');
      buffer.writeln('🏆 برنده: ${item.winner}');
      buffer.writeln('🌙 تعداد شب‌ها: ${item.nights}');
      buffer.writeln('─────────────────────────────────');
    }
    return buffer.toString();
  }
}
