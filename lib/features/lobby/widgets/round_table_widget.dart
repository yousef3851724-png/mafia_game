import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'player_seat_widget.dart';

/// داده‌ی یک صندلی برای رندر دور میز
class SeatData {
  const SeatData({
    required this.seatNumber,
    this.playerName,
    this.avatarImageProvider,
    this.status = SeatStatus.empty,
    this.isHost = false,
    this.roleTagLabel,
    this.roleTagColor,
    this.isSpeaking = false,
    this.isMuted = false,
  });

  final int seatNumber;
  final String? playerName;
  final ImageProvider? avatarImageProvider;
  final SeatStatus status;
  final bool isHost;
  final String? roleTagLabel;
  final Color? roleTagColor;
  final bool isSpeaking;
  final bool isMuted;
}

/// میز گرد بازی: صندلی‌ها را بر پایه‌ی زاویه دور یک بیضی می‌چیند،
/// شبیه چیدمان موکاپ (صندلی ۱ بالا، سپس در جهت ساعتگرد).
class RoundTableWidget extends StatelessWidget {
  const RoundTableWidget({
    super.key,
    required this.seats,
    this.tableLabel = 'MAFIA\nRADICAL',
    this.onSeatTap,
    this.avatarSize = 62,
  });

  final List<SeatData> seats;
  final String tableLabel;
  final ValueChanged<SeatData>? onSeatTap;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double centerX = width / 2;
        final double centerY = height / 2;
        // شعاع بیضی کمی کوچک‌تر از کادر تا آواتارها بیرون نزنند
        final double radiusX = (width / 2) - (avatarSize * 0.9);
        final double radiusY = (height / 2) - (avatarSize * 0.9);

        final int count = seats.length;

        return Stack(
          alignment: Alignment.center,
          children: [
            // ---------- میز چوبی/طلایی مرکزی ----------
            Center(
              child: Container(
                width: math.min(width, height) * 0.5,
                height: math.min(width, height) * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF2A1E10), Color(0xFF160F08)],
                    stops: [0.4, 1],
                  ),
                  border: Border.all(color: const Color(0xFF7A5A22), width: 3),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 24, spreadRadius: 4),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  tableLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondary.withOpacity(0.35),
                    fontWeight: FontWeight.w900,
                    fontSize: math.min(width, height) * 0.075,
                    letterSpacing: 2,
                    height: 1.1,
                  ),
                ),
              ),
            ),
            // ---------- صندلی‌ها ----------
            for (int i = 0; i < count; i++) _buildSeat(i, count, centerX, centerY, radiusX, radiusY),
          ],
        );
      },
    );
  }

  Widget _buildSeat(int index, int count, double cx, double cy, double rx, double ry) {
    // صندلی صفر (شماره ۱) بالای میز (زاویه -90 درجه) و بقیه ساعتگرد
    final double angle = (-math.pi / 2) + (2 * math.pi * index / count);
    final double x = cx + rx * math.cos(angle) - (avatarSize + 24) / 2;
    final double y = cy + ry * math.sin(angle) - (avatarSize + 40) / 2;
    final seat = seats[index];

    return Positioned(
      left: x,
      top: y,
      child: SizedBox(
        width: avatarSize + 24,
        child: PlayerSeatWidget(
          seatNumber: seat.seatNumber,
          playerName: seat.playerName,
          avatarImageProvider: seat.avatarImageProvider,
          status: seat.status,
          isHost: seat.isHost,
          roleTagLabel: seat.roleTagLabel,
          roleTagColor: seat.roleTagColor,
          isSpeaking: seat.isSpeaking,
          isMuted: seat.isMuted,
          avatarSize: avatarSize,
          onTap: onSeatTap == null ? null : () => onSeatTap!(seat),
        ),
      ),
    );
  }
}
