import 'dart:math' as math;

import 'package:flutter/material.dart';

class LobbyPlayer {
  final String id;
  final String name;
  final String? avatarPath;
  final String? framePath;
  final bool isReady;

  const LobbyPlayer({
    required this.id,
    required this.name,
    this.avatarPath,
    this.framePath,
    this.isReady = false,
  });
}

enum LobbyGameMode {
  friendly,
  ranked,
}

class LobbyBackground {
  final String id;
  final String name;
  final List<Color> colors;
  final IconData icon;

  const LobbyBackground({
    required this.id,
    required this.name,
    required this.colors,
    required this.icon,
  });
}

class RoundLobby extends StatefulWidget {
  final List<LobbyPlayer> players;
  final int maxPlayers;
  final LobbyGameMode gameMode;
  final String creatorId;
  final String managerId;
  final bool isCurrentUserCreator;
  final bool isCurrentUserManager;
  final VoidCallback? onStartGame;
  final VoidCallback? onLeaveLobby;
  final ValueChanged<int>? onSeatTap;

  const RoundLobby({
    super.key,
    required this.players,
    this.maxPlayers = 20,
    this.gameMode = LobbyGameMode.friendly,
    this.creatorId = '',
    this.managerId = '',
    this.isCurrentUserCreator = false,
    this.isCurrentUserManager = false,
    this.onStartGame,
    this.onLeaveLobby,
    this.onSeatTap,
  });

  @override
  State<RoundLobby> createState() => _RoundLobbyState();
}

class _RoundLobbyState extends State<RoundLobby> {
  late LobbyGameMode _gameMode;
  late String _managerId;
  int _backgroundIndex = 0;

  static const List<LobbyBackground> backgrounds = [
    LobbyBackground(
      id: 'night',
      name: 'شب رادیکال',
      colors: [
        Color(0xFF090D15),
        Color(0xFF18243A),
        Color(0xFF0A101C),
      ],
      icon: Icons.nightlight_round,
    ),
    LobbyBackground(
      id: 'crimson',
      name: 'قرمز جنایی',
      colors: [
        Color(0xFF16070A),
        Color(0xFF48151B),
        Color(0xFF09090D),
      ],
      icon: Icons.local_fire_department,
    ),
    LobbyBackground(
      id: 'purple',
      name: 'بنفش رادیکال',
      colors: [
        Color(0xFF100A1C),
        Color(0xFF302052),
        Color(0xFF08070F),
      ],
      icon: Icons.auto_awesome,
    ),
    LobbyBackground(
      id: 'emerald',
      name: 'زمردی',
      colors: [
        Color(0xFF061412),
        Color(0xFF123D37),
        Color(0xFF070D0C),
      ],
      icon: Icons.diamond,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _gameMode = widget.gameMode;
    _managerId = widget.managerId.isEmpty
        ? widget.creatorId
        : widget.managerId;
  }

  bool get _canManage {
    return widget.isCurrentUserCreator ||
        widget.isCurrentUserManager;
  }

  bool get _canTransferManager {
    return widget.isCurrentUserCreator;
  }

  LobbyBackground get _background => backgrounds[_backgroundIndex];

  int get _seatCount {
    final count = widget.players.length;

    if (count < 6) return 6;
    if (count > widget.maxPlayers) return widget.maxPlayers;

    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background.colors.first,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _background.colors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return _buildTable(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                  },
                ),
              ),
              _buildBottomPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final ranked = _gameMode == LobbyGameMode.ranked;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onLeaveLobby,
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لابی مافیا رادیکال',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'میز بازی',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          _modeBadge(ranked),
          const SizedBox(width: 5),
          if (_canManage)
            IconButton(
              tooltip: 'مدیریت لابی',
              onPressed: _showManagementSheet,
              icon: const Icon(
                Icons.admin_panel_settings,
                color: Color(0xFFD4AF87),
              ),
            ),
        ],
      ),
    );
  }

  Widget _modeBadge(bool ranked) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: ranked
            ? const Color(0xFF594300)
            : const Color(0xFF123A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ranked
              ? Colors.amber
              : Colors.greenAccent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ranked
                ? Icons.emoji_events
                : Icons.sports_esports,
            size: 15,
            color: ranked
                ? Colors.amber
                : Colors.greenAccent,
          ),
          const SizedBox(width: 5),
          Text(
            ranked ? 'امتیازی' : 'دوستانه',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ranked
                  ? Colors.amber
                  : Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(double width, double height) {
    final safeHeight = math.max(240.0, height);
    final size = math.min(width, safeHeight);

    final tableSize = math.min(
      size * 0.46,
      360.0,
    );

    final orbitX = math.min(
      width * 0.39,
      size * 0.43,
    );

    final orbitY = math.min(
      safeHeight * 0.38,
      size * 0.43,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _TableGlowPainter(),
            ),
          ),
        ),

        Container(
          width: tableSize + 18,
          height: tableSize + 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFD4AF87).withOpacity(0.18),
              width: 2,
            ),
          ),
        ),

        Container(
          width: tableSize,
          height: tableSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFF394961),
                Color(0xFF1C2739),
                Color(0xFF101722),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFD4AF87),
              width: 2.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: _buildTableCenter(),
        ),

        ...List.generate(
          _seatCount,
          (index) {
            final angle =
                -math.pi / 2 +
                2 * math.pi * index / _seatCount;

            final x = math.cos(angle) * orbitX;
            final y = math.sin(angle) * orbitY;

            final player = index < widget.players.length
                ? widget.players[index]
                : null;

            return Positioned(
              left: width / 2 + x - 43,
              top: safeHeight / 2 + y - 43,
              child: _PlayerSeat(
                index: index,
                player: player,
                isCreator: player?.id == widget.creatorId,
                isManager: player?.id == _managerId,
                canManage: _canManage,
                onTap: () {
                  widget.onSeatTap?.call(index);

                  if (player != null && _canManage) {
                    _showPlayerActions(player);
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTableCenter() {
    final ranked = _gameMode == LobbyGameMode.ranked;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF87),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.local_police,
              size: 32,
              color: Color(0xFFD4AF87),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'RADICAL',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: Color(0xFFD4AF87),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.players.length}/$_seatCount',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            ranked
                ? '🏆 ورود ۱۰۰ سکه'
                : '🎮 بازی دوستانه',
            style: TextStyle(
              fontSize: 11,
              color: ranked
                  ? Colors.amber
                  : Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    final ready = widget.players
        .where((player) => player.isReady)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.people_alt_outlined,
                size: 17,
                color: Colors.white60,
              ),
              const SizedBox(width: 5),
              Text(
                '${widget.players.length} بازیکن',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 15),
              const Icon(
                Icons.check_circle_outline,
                size: 17,
                color: Colors.greenAccent,
              ),
              const SizedBox(width: 5),
              Text(
                '$ready آماده',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          if (_canManage)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: widget.players.length >= 6
                    ? widget.onStartGame
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  widget.players.length >= 6
                      ? 'شروع بازی'
                      : 'حداقل ۶ بازیکن لازم است',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showManagementSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151C28),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'مدیریت لابی',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: const Icon(
                    Icons.image,
                    color: Color(0xFFD4AF87),
                  ),
                  title: const Text('تغییر تصویر زمینه'),
                  onTap: () {
                    Navigator.pop(context);
                    _showBackgroundPicker();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.sports_esports,
                    color: Colors.greenAccent,
                  ),
                  title: const Text('حالت بازی'),
                  subtitle: Text(
                    _gameMode == LobbyGameMode.ranked
                        ? 'امتیازی • ورود ۱۰۰ سکه • برد +۲۰'
                        : 'دوستانه • رایگان',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showModePicker();
                  },
                ),
                if (_canTransferManager)
                  ListTile(
                    leading: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.amber,
                    ),
                    title: const Text('تغییر مدیر لابی'),
                    subtitle: const Text(
                      'مدیریت را به بازیکن دیگری واگذار کنید',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showManagerPicker();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBackgroundPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151C28),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'انتخاب پس‌زمینه لابی',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...List.generate(
                backgrounds.length,
                (index) {
                  final item = backgrounds[index];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.colors[1],
                      child: Icon(
                        item.icon,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(item.name),
                    trailing: index == _backgroundIndex
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _backgroundIndex = index;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showModePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151C28),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'حالت بازی',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.sports_esports,
                  color: Colors.greenAccent,
                ),
                title: const Text('دوستانه'),
                subtitle: const Text(
                  'رایگان • بدون پاداش سکه',
                ),
                onTap: () {
                  setState(() {
                    _gameMode = LobbyGameMode.friendly;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                ),
                title: const Text('امتیازی'),
                subtitle: const Text(
                  'ورود ۱۰۰ سکه • برد +۲۰ سکه',
                ),
                onTap: () {
                  setState(() {
                    _gameMode = LobbyGameMode.ranked;
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showManagerPicker() {
    final candidates = widget.players
        .where((player) => player.id != widget.creatorId)
        .toList();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151C28),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'انتخاب مدیر جدید',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (candidates.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'بازیکن دیگری برای مدیریت وجود ندارد.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ...candidates.map(
                (player) {
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(player.name),
                    trailing: player.id == _managerId
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _managerId = player.id;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPlayerActions(LobbyPlayer player) {
    if (player.id == widget.creatorId) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151C28),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(player.name),
              ),
              if (_canTransferManager)
                ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.amber,
                  ),
                  title: const Text('قرار دادن به عنوان مدیر'),
                  onTap: () {
                    setState(() {
                      _managerId = player.id;
                    });
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _PlayerSeat extends StatelessWidget {
  final int index;
  final LobbyPlayer? player;
  final bool isCreator;
  final bool isManager;
  final bool canManage;
  final VoidCallback? onTap;

  const _PlayerSeat({
    required this.index,
    required this.player,
    required this.isCreator,
    required this.isManager,
    required this.canManage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final exists = player != null;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 86,
        height: 112,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: exists
                        ? const Color(0xFF202B3C)
                        : const Color(0xFF111722),
                    border: Border.all(
                      color: isCreator
                          ? const Color(0xFFFFD54F)
                          : isManager
                              ? const Color(0xFF64B5F6)
                              : exists
                                  ? const Color(0xFFD4AF87)
                                  : Colors.white24,
                      width: isCreator || isManager ? 2.5 : 1.8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: _avatar(),
                ),

                Positioned(
                  left: -2,
                  top: -3,
                  child: Container(
                    width: 23,
                    height: 23,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF101722),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                if (isCreator)
                  const Positioned(
                    right: -5,
                    top: -12,
                    child: Text(
                      '👑',
                      style: TextStyle(fontSize: 22),
                    ),
                  )
                else if (isManager)
                  const Positioned(
                    right: -4,
                    top: -8,
                    child: Text(
                      '🛡️',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),

                if (player?.isReady == true)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 21,
                      height: 21,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              exists ? player!.name : 'صندلی خالی',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    exists ? FontWeight.bold : FontWeight.normal,
                color:
                    exists ? Colors.white : Colors.white38,
              ),
            ),
            if (isCreator)
              const Text(
                'سازنده',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.amber,
                ),
              )
            else if (isManager)
              const Text(
                'مدیر',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.lightBlueAccent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    if (player?.avatarPath == null ||
        player!.avatarPath!.isEmpty) {
      return const Icon(
        Icons.person,
        size: 38,
        color: Colors.white70,
      );
    }

    return ClipOval(
      child: Image.asset(
        player!.avatarPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.person,
            size: 38,
            color: Colors.white70,
          );
        },
      ),
    );
  }
}

class _TableGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        math.min(size.width, size.height) * 0.34;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFD4AF87).withOpacity(0.10),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
