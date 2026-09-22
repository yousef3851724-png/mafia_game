import 'package:flutter/material.dart';

import '../../core/widgets/radical_scaffold.dart';

class LobbyChatScreen extends StatefulWidget {
  final String lobbyId;
  const LobbyChatScreen({super.key, required this.lobbyId});

  @override
  State<LobbyChatScreen> createState() => _LobbyChatScreenState();
}

class _LobbyChatScreenState extends State<LobbyChatScreen> {
  final _controller = TextEditingController();
  final _messages = <String>[];

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() { _messages.add(text); _controller.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    return RadicalScaffold(
      appBar: AppBar(title: Text('چت لابی ${widget.lobbyId}')),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, i) => Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFF171B25), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x33E3B873))),
                  child: Text(_messages[i]),
                ),
              ),
            ),
          ),
          Row(children: [
            Expanded(child: TextField(controller: _controller, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'پیام...'))),
            IconButton(onPressed: _send, icon: const Icon(Icons.send_rounded, color: Color(0xFFE3B873))),
          ]),
        ],
      ),
    );
  }
}
