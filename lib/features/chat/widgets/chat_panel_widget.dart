import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class ChatMessage {
  const ChatMessage({
    required this.senderName,
    required this.text,
    required this.time,
    this.senderColor = AppColors.textPrimary,
    this.isHost = false,
    this.isSystem = false,
  });

  final String senderName;
  final String text;
  final String time;
  final Color senderColor;
  final bool isHost;
  final bool isSystem;
}

enum ChatPanelTab { messages, emoji, stickers, gifs }

/// پنل چت پایین صفحه‌ی لابی: لیست پیام + تب ایموجی/استیکر/گیف + ورودی پیام.
class ChatPanelWidget extends StatefulWidget {
  const ChatPanelWidget({
    super.key,
    required this.messages,
    this.onSendMessage,
    this.onEmojiSelected,
  });

  final List<ChatMessage> messages;
  final ValueChanged<String>? onSendMessage;
  final ValueChanged<String>? onEmojiSelected;

  @override
  State<ChatPanelWidget> createState() => _ChatPanelWidgetState();
}

class _ChatPanelWidgetState extends State<ChatPanelWidget> {
  ChatPanelTab _tab = ChatPanelTab.messages;
  final TextEditingController _controller = TextEditingController();

  static const List<String> _quickEmojis = [
    '😂', '😭', '😍', '😎', '😡',
    '😱', '🤔', '😊', '👍', '👎',
    '❤️', '💔', '🔥', '👏', '💯',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabsRow(current: _tab, onChanged: (t) => setState(() => _tab = t)),
          const SizedBox(height: 8),
          SizedBox(
            height: 170,
            child: _tab == ChatPanelTab.messages ? _buildMessageList() : _buildEmojiGrid(),
          ),
          const SizedBox(height: 8),
          _InputBar(
            controller: _controller,
            onSend: () {
              if (_controller.text.trim().isEmpty) return;
              widget.onSendMessage?.call(_controller.text.trim());
              _controller.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.separated(
      reverse: false,
      itemCount: widget.messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final m = widget.messages[index];
        if (m.isSystem) {
          return Text(m.text, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary));
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        m.senderName,
                        style: AppTextStyles.caption.copyWith(color: m.senderColor, fontWeight: FontWeight.bold),
                      ),
                      if (m.isHost) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('سازنده', style: AppTextStyles.caption.copyWith(color: AppColors.secondary, fontSize: 9)),
                        ),
                      ],
                      const Spacer(),
                      Text(m.time, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(m.text, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmojiGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _quickEmojis.length,
      itemBuilder: (context, index) {
        final emoji = _quickEmojis[index];
        return InkWell(
          onTap: () => widget.onEmojiSelected?.call(emoji),
          borderRadius: BorderRadius.circular(8),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
        );
      },
    );
  }
}

class _TabsRow extends StatelessWidget {
  const _TabsRow({required this.current, required this.onChanged});
  final ChatPanelTab current;
  final ValueChanged<ChatPanelTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = {
      ChatPanelTab.messages: 'پیام‌ها',
      ChatPanelTab.emoji: 'ایموجی',
      ChatPanelTab.stickers: 'استیکرها',
      ChatPanelTab.gifs: 'گیف‌ها',
    };
    return Row(
      children: tabs.entries.map((e) {
        final selected = e.key == current;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.surfaceVariant : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: selected ? Border.all(color: AppColors.secondary.withOpacity(0.5)) : null,
              ),
              alignment: Alignment.center,
              child: Text(
                e.value,
                style: AppTextStyles.caption.copyWith(
                  color: selected ? AppColors.secondary : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySmall,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'پیام خود را بنویسید...',
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onSend,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.goldButtonGradient),
            child: const Icon(Icons.send, color: Color(0xFF2B1E05), size: 18),
          ),
        ),
      ],
    );
  }
}
