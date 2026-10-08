import 'package:flutter/material.dart';
import '../../widgets/animated_sticker.dart';
import '../../core/theme/radical_theme.dart';

class FloatingPanels extends StatefulWidget {
  final List<String> stickerAssets;
  final void Function(String text) onSendText;
  final void Function(String emoji) onSendEmoji;
  final void Function(String asset) onSendSticker;

  const FloatingPanels({
    super.key,
    required this.stickerAssets,
    required this.onSendText,
    required this.onSendEmoji,
    required this.onSendSticker,
  });

  @override
  State<FloatingPanels> createState() => _FloatingPanelsState();
}

class _FloatingPanelsState extends State<FloatingPanels> {
  bool _chatOpen = false;
  bool _pickerOpen = false;
  int _tab = 0;
  final _ctrl = TextEditingController();
  static const _gold = RadicalTheme.gold;
  static const _emojis = ['😂','😭','😍','😎','😡','😱','🤔','😊','👍','👎','❤️','💔','🔥','👏','💯'];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black87,
            border: Border.all(color: _gold, width: 2),
          ),
          child: Icon(icon, color: _gold),
        ),
      );

  Widget _panel({required bool open, required Widget child, required double width, required double height, required Alignment align}) {
    return Align(
      alignment: align,
      child: IgnorePointer(
        ignoring: !open,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          offset: open ? Offset.zero : const Offset(0, 1.2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: open ? 1 : 0,
            child: Container(
              width: width,
              height: height,
              margin: const EdgeInsets.only(bottom: 72, left: 10, right: 10),
              decoration: BoxDecoration(
                color: const Color(0xEE0B0B0F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _gold.withOpacity(0.6)),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _chat() => Column(children: [
        const Expanded(child: Center(child: Text('پیام‌ها', style: TextStyle(color: Colors.white54)))),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'پیام خود را بنویسید...', isDense: true),
                onSubmitted: (_) => _send(),
              ),
            ),
            IconButton(icon: const Icon(Icons.send, color: _gold), onPressed: _send),
          ]),
        ),
      ]);

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    widget.onSendText(t);
    _ctrl.clear();
  }

  Widget _tabBtn(int i, IconData icon) => Expanded(
        child: InkWell(
          onTap: () => setState(() => _tab = i),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: _tab == i ? _gold : Colors.transparent, width: 2)),
            ),
            child: Icon(icon, color: _tab == i ? _gold : Colors.white54),
          ),
        ),
      );

  Widget _picker() {
    Widget body;
    if (_tab == 0) {
      body = GridView.count(
        crossAxisCount: 5,
        padding: const EdgeInsets.all(8),
        children: [
          for (final e in _emojis)
            InkWell(onTap: () => widget.onSendEmoji(e), child: Center(child: Text(e, style: const TextStyle(fontSize: 28)))),
        ],
      );
    } else if (_tab == 1) {
      body = widget.stickerAssets.isEmpty
          ? const Center(child: Text('هنوز استیکری نخریدی', style: TextStyle(color: Colors.white54)))
          : GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(8),
              children: [
                for (final a in widget.stickerAssets)
                  InkWell(onTap: () => widget.onSendSticker(a), child: AnimatedSticker(asset: a, size: 56)),
              ],
            );
    } else {
      body = const Center(child: Text('به‌زودی', style: TextStyle(color: Colors.white54)));
    }
    return Column(children: [
      Row(children: [
        _tabBtn(0, Icons.emoji_emotions_outlined),
        _tabBtn(1, Icons.sentiment_satisfied_alt),
        _tabBtn(2, Icons.gif_box_outlined),
      ]),
      Expanded(child: body),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final pw = (w - 20) > 360 ? 360.0 : w - 20;
    return Stack(children: [
      _panel(open: _chatOpen, child: _chat(), width: pw, height: 260, align: Alignment.bottomLeft),
      _panel(open: _pickerOpen, child: _picker(), width: pw, height: 260, align: Alignment.bottomRight),
      Positioned(left: 16, bottom: 12, child: _roundBtn(Icons.chat_bubble_outline, () => setState(() { _chatOpen = !_chatOpen; if (_chatOpen) _pickerOpen = false; }))),
      Positioned(right: 16, bottom: 12, child: _roundBtn(Icons.emoji_emotions_outlined, () => setState(() { _pickerOpen = !_pickerOpen; if (_pickerOpen) _chatOpen = false; }))),
    ]);
  }
}
