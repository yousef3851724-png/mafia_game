import 'package:flutter_riverpod/flutter_riverpod.dart';

// این Provider برای دسترسی به سرویس چت در کل برنامه
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

class ChatService {
  // اینجا منطق اتصال Socket.io یا Firebase تو قرار می‌گیره
  void sendMessage(String message, String senderId) {
    // فعلاً فقط لاگ می‌گیریم که مطمعن بشیم کار می‌کنه
    print('Sending message: $message from $senderId');
  }
}
