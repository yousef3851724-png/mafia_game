import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// یک Provider ساده برای مدیریت لیست بازیکنان در لابی
final playersProvider = StateProvider<List<String>>((ref) => []);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playersProvider);
    final TextEditingController nameController = TextEditingController();

    void addPlayer() {
      final name = nameController.text.trim();
      if (name.isNotEmpty && players.length < 12) {
        ref.read(playersProvider.notifier).state = [...players, name];
        nameController.clear();
      } else if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لطفاً اسم خود را وارد کنید!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حداکثر ۱۲ بازیکن می‌توانند وارد شوند!')),
        );
      }
    }

    void removePlayer(int index) {
      final updatedList = List<String>.from(players);
      updatedList.removeAt(index);
      ref.read(playersProvider.notifier).state = updatedList;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎭 لابی مافیا رادیکال'),
        backgroundColor: const Color(0xFF1A1D23), // تم تاریک
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ورودی نام بازیکن
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'نام خود را وارد کنید...',
                      filled: true,
                      fillColor: Color(0xFF2C2F36),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => addPlayer(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green, size: 40),
                  onPressed: addPlayer,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // لیست بازیکنان
            Expanded(
              child: players.isEmpty
                  ? const Center(
                      child: Text(
                        'هنوز بازیکنی اضافه نشده است.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text(players[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => removePlayer(index),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // دکمه رفتن به لیست لابی‌ها
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: players.length >= 3
                    ? () {
                        // هدایت به صفحه لیست لابی‌ها (برای اینکه برود لابی بسازد)
                        context.go('/lobbies');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB99445), // طلایی رادیکال
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  'رفتن به لابی‌ها و شروع بازی',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
