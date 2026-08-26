import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../widgets/round_table_widget.dart';
import '../widgets/player_seat_widget.dart';
import '../../chat/widgets/chat_panel_widget.dart';

/// صفحه‌ی لابی دوستانه: میز گرد در انتظار شروع بازی.
/// این نسخه UI است؛ داده‌ی واقعی بازیکنان بعداً از طریق Riverpod تزریق می‌شود.
class LobbyWaitingScreen extends StatefulWidget {
  const LobbyWaitingScreen({
    super.key,
    required this.lobbyName,
    required this.lobbyCode,
    required this.seats,
    required this.hostName,
    this.onStartGame,
  });

  final String lobbyName;
  final String lobbyCode;
  final List<SeatData> seats;
  final String hostName;
  final VoidCallback? onStartGame;

  @override
  State<LobbyWaitingScreen> createState() => _LobbyWaitingScreenState();
}

class _LobbyWaitingScreenState extends State<LobbyWaitingScreen> {
  bool _showSettings = true;

  final List<ChatMessage> _messages = [
    const ChatMessage(senderName: 'میزبان', text: 'سلام به همه 👋', time: '', isSystem: false, isHost: true, senderColor: AppColors.secondary),
    const ChatMessage(senderName: 'دختر_منطقی', text: 'سلام', time: ''),
  ];

  int get readyCount => widget.seats.where((s) => s.status == SeatStatus.ready).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: Row(
                children: [
                  if (_showSettings) _buildSettingsPanel(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: RoundTableWidget(seats: widget.seats),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ChatPanelWidget(
                messages: _messages,
                onSendMessage: (text) {
                  setState(() {
                    _messages.add(ChatMessage(senderName: 'شما', text: text, time: ''));
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _StartGameButton(onTap: widget.onStartGame),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.lobbyName, style: AppTextStyles.titleMedium),
              Row(
                children: [
                  Text('کد لابی: ${widget.lobbyCode}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.copy, size: 14, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
          const Spacer(),
          _CenterStatusBadge(current: readyCount, total: widget.seats.length, hostName: widget.hostName),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _showSettings = !_showSettings),
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: TextButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.15)),
            child: Text('خروج', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تنظیمات بازی', style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary)),
          const SizedBox(height: 10),
          _settingsRow('سناریو', 'کلاسیک'),
          _settingsRow('نقش‌ها', 'پیش‌فرض'),
          _settingsRow('زمان روز', '120 ثانیه'),
          _settingsRow('زمان شب', '60 ثانیه'),
          _settingsRow('تعداد رأی', '1'),
          _settingsRow('ویس چت', 'فعال'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add_alt, size: 16, color: AppColors.secondary),
            label: Text('دعوت از دوستان', style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
              minimumSize: const Size.fromHeight(36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _CenterStatusBadge extends StatelessWidget {
  const _CenterStatusBadge({required this.current, required this.total, required this.hostName});
  final int current;
  final int total;
  final String hostName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('در انتظار شروع بازی', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          Text('$current / $total', style: AppTextStyles.titleMedium.copyWith(color: AppColors.secondary)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('گرداننده: ', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
              Text(hostName, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontSize: 10)),
              const SizedBox(width: 2),
              const Icon(Icons.emoji_events, size: 12, color: AppColors.secondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartGameButton extends StatelessWidget {
  const _StartGameButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppColors.goldButtonGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Text(
          'شروع بازی',
          style: AppTextStyles.titleMedium.copyWith(color: const Color(0xFF2B1E05), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
