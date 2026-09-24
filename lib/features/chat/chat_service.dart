import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

// این Provider برای دسترسی به سرویس چت در کل برنامه
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

class ChatService {
  final Logger _logger = Logger();

  void sendMessage(String message, String senderId) {
    _logger.d('Chat message requested');
  }
}
