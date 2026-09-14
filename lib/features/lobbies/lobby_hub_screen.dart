import 'package:flutter/material.dart';

import '../../core/theme/radical_theme.dart';
import '../scenarios/radical_game_screen.dart';
import '../scenarios/scenario_catalog.dart';
import 'lobby_system.dart';

class LobbyHubScreen extends StatefulWidget {
  final String ownerId;
  const LobbyHubScreen({super.key, required this.ownerId});

  @override
  State<LobbyHubScreen> createState() => _LobbyHubScreenState();
}

class _LobbyHubScreenState extends State<LobbyHubScreen> {
  LobbyCategory _category = LobbyCatalog.friendlyAdult;
  LobbyLabel _label = LobbyLabel.radical;
  String _scenarioId = 'classic';
  int _players = 10;
  bool _locked = false;
  final TextEditingController _chat = TextEditingController();

  String get _lobbyId => 'local_${widget.ownerId}';
  ScenarioDefinition? get _scenario => ScenarioCatalog.byId(_scenarioId);
  List<ScenarioDefinition> get _scenarios => ScenarioCatalog.forMode(
        _category.mode == LobbyMode.ranked
            ? ScenarioMode.ranked
            : ScenarioMode.friendly,
      );

  @override
  void initState() {
    super.initState();
    LobbyChatStore.seed(_lobbyId, widget.ownerId == 'local_creator' ? 'شما' : widget.ownerId);
  }

  @override
  void dispose() {
    _chat.dispose();
    super.dispose();
  }

  void _pickCategory(LobbyCategory value) {
    final scenarios = ScenarioCatalog.forMode(
      value.mode == LobbyMode.ranked ? ScenarioMode.ranked : ScenarioMode.friendly,
    );
    setState(() {
      _category = value;
      if (scenarios.isNotEmpty) {
        _scenarioId = scenarios.first.id;
        _players = scenarios.first.minPlayers;
      }
    });
  }

  void _start() {
    final scenario = _scenario;
    if (scenario == null) return;
    final mode = _category.mode == LobbyMode.ranked
        ? ScenarioMode.ranked
        : ScenarioMode.friendly;
    if (!ScenarioCatalog.canStart(
      scenarioId: scenario.id,
      mode: mode,
      playerCount: _players,
    )) {
      _toast('تعداد بازیکن با این سناریو هماهنگ نیست.');
      return;
    }
    if (_category.isRanked && _players != 10) {
      _toast('بازی امتیازی دقیقاً ۱۰ نفره است.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RadicalGameScreen(
          scenario: scenario,
          mode: mode,
          playerCount: _players,
        ),
      ),
    );
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _sendText(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return;
    LobbyChatStore.send(
      lobby: _localLobby(),
      senderId: widget.ownerId,
      senderName: 'شما',
      text: clean,
    );
    _chat.clear();
    setState(() {});
  }

  void _sendEmoji(String emoji) {
    LobbyChatStore.send(
      lobby: _localLobby(),
      senderId: widget.ownerId,
      senderName: 'شما',
      text: '',
      emoji: emoji,
    );
    setState(() {});
  }

  LobbyDefinition _localLobby() {
    return LobbyDefinition(
      id: _lobbyId,
      name: 'لابی محلی',
      category: _category,
      label: _label,
      ownerId: widget.ownerId,
      locked: _locked,
      players: [
        LobbyPlayerLabel(
          playerId: widget.ownerId,
          playerName: 'شما',
          isLeader: true,
          isStaff: RadicalStaffDirectory.isStaff(widget.ownerId),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenario = _scenario;
    final label = LobbyLabels.of(_label);
    final count = scenario == null
        ? _players
        : _players.clamp(scenario.minPlayers, scenario.maxPlayers).toInt();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadicalTheme.ink,
        appBar: AppBar(
          title: const Text('لابی‌های رادیکال', style: TextStyle(fontWeight: FontWeight.w900)),
          actions: [
            IconButton(
              onPressed: _showDiamonds,
              icon: const Icon(Icons.diamond_rounded, color: RadicalTheme.goldBright),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
          children: [
            _section('تفکیک لابی', _categoryGrid()),
            const SizedBox(height: 14),
            _lobbyCard(label),
            const SizedBox(height: 14),
            _section('سناریو و ظرفیت', _scenarioPanel(scenario, count)),
            const SizedBox(height: 14),
            _section('بازیکنان', _playersPanel()),
            const SizedBox(height: 14),
            _section('چت گروهی همین لابی', _chatPanel()),
            const SizedBox(height: 14),
            _section('همکاران مافیا رادیکال', _staffPanel()),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('شروع بازی و ورود به میز'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _categoryGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.55,
      children: LobbyCatalog.all.map(_categoryTile).toList(),
    );
  }

  Widget _categoryTile(LobbyCategory item) {
    final selected = item == _category;
    return InkWell(
      onTap: () => _pickCategory(item),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? item.primary.withValues(alpha: .14) : RadicalTheme.panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? item.primary.withValues(alpha: .75) : RadicalTheme.line,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              item.isRanked ? Icons.emoji_events_rounded : Icons.groups_rounded,
              color: item.primary,
            ),
            const Spacer(),
            Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(
              item.isAdult ? '۱۸+ • کامل' : 'زیر ۱۸ • ملایم',
              style: TextStyle(color: item.primary, fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lobbyCard(LobbyLabelDefinition label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: RadicalTheme.glass(accent: _category.isRanked),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: label.color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(label.icon, color: label.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لابی ${_category.isRanked ? 'امتیازی' : 'دوستانه'}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(label.title, style: TextStyle(color: label.color, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(_category.description, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: _locked,
            onChanged: widget.ownerId == 'local_creator'
                ? (value) => setState(() => _locked = value)
                : null,
            activeColor: RadicalTheme.gold,
          ),
        ],
      ),
    );
  }

  Widget _scenarioPanel(ScenarioDefinition? scenario, int count) {
    final scenarios = _scenarios;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: RadicalTheme.glass(),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: scenarios.any((x) => x.id == _scenarioId) ? _scenarioId : null,
            decoration: const InputDecoration(labelText: 'سناریو'),
            items: scenarios
                .map((x) => DropdownMenuItem(value: x.id, child: Text(x.title)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              final next = ScenarioCatalog.byId(value);
              setState(() {
                _scenarioId = value;
                _players = next?.minPlayers ?? 10;
              });
            },
          ),
          if (scenario != null && scenario.minPlayers != scenario.maxPlayers) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text('ظرفیت: $count نفر', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            Slider(
              value: count.toDouble(),
              min: scenario.minPlayers.toDouble(),
              max: scenario.maxPlayers.toDouble(),
              divisions: scenario.maxPlayers - scenario.minPlayers,
              onChanged: (value) => setState(() => _players = value.round()),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _category.isRanked ? Icons.leaderboard_rounded : Icons.celebration_rounded,
                color: _category.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _category.isRanked
                      ? 'امتیاز، رتبه و لیگ فعال است.'
                      : 'بدون امتیاز و رتبه؛ فقط برای دورهمی.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _playersPanel() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: RadicalTheme.glass(),
      child: const Column(
        children: [
          _PlayerRow(name: 'شما', leader: true),
          Divider(height: 18),
          _PlayerRow(name: 'بازیکن رادیکال', staff: true),
          SizedBox(height: 8),
          _PlayerRow(name: 'بازیکن تازه‌وارد'),
          SizedBox(height: 8),
          _PlayerRow(name: 'بازیکن حرفه‌ای'),
        ],
      ),
    );
  }

  Widget _chatPanel() {
    final messages = LobbyChatStore.messagesFor(_lobbyId);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: RadicalTheme.glass(),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: ListView(
              children: [for (final message in messages) _message(message)],
            ),
          ),
          Row(
            children: [
              for (final emoji in ['😂', '🔥', '🎭', '💀', '🎉'])
                IconButton(onPressed: () => _sendEmoji(emoji), icon: Text(emoji)),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chat,
                  onSubmitted: _sendText,
                  decoration: const InputDecoration(hintText: 'پیام برای اعضای همین لابی...'),
                ),
              ),
              IconButton(
                onPressed: () => _sendText(_chat.text),
                icon: const Icon(Icons.send_rounded, color: RadicalTheme.goldBright),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _message(LobbyChatMessage message) {
    final isSystem = message.type == LobbyChatMessageType.system;
    final prefix = switch (message.type) {
      LobbyChatMessageType.text => '${message.senderName}: ',
      LobbyChatMessageType.emoji => '${message.senderName}: ',
      LobbyChatMessageType.sticker => '${message.senderName}: ',
      LobbyChatMessageType.system => '⚙️ ',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isSystem ? Alignment.center : Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isSystem ? RadicalTheme.panel3 : RadicalTheme.panel2,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(
            '$prefix${message.content}',
            style: TextStyle(
              color: isSystem ? RadicalTheme.smoke : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _staffPanel() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171122),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x669A72D9)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.diamond_rounded, color: RadicalTheme.goldBright),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'همکاران مافیا رادیکال',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final member in RadicalStaffDirectory.members)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  const CircleAvatar(radius: 17, child: Icon(Icons.person_rounded, size: 18)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(member.playerName, style: const TextStyle(fontWeight: FontWeight.w800))),
                  _badge('◆ STAFF', RadicalTheme.violet),
                ],
              ),
            ),
          if (RadicalStaffDirectory.isStaff(widget.ownerId))
            FilledButton.icon(
              onPressed: _showStaffAdmin,
              icon: const Icon(Icons.admin_panel_settings_rounded),
              label: const Text('ورود به پنل ادمین'),
            )
          else
            const Text(
              'این لابی فقط برای اعضای رسمی تیم قابل ورود است.',
              style: TextStyle(color: RadicalTheme.smoke, fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  void _showDiamonds() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: RadicalTheme.panel,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(18),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text('الماس‌های رادیکال', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            for (final item in RadicalDiamonds.all)
              ListTile(
                leading: _DiamondIcon(item),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(item.usage),
                trailing: Text(item.emoji, style: const TextStyle(fontSize: 24)),
              ),
            const Divider(),
            const Text('فروشگاه', style: TextStyle(fontWeight: FontWeight.w900)),
            for (final item in LobbyStoreCatalog.regular) _storeItem(item),
            const SizedBox(height: 8),
            const Text('فروشگاه VIP', style: TextStyle(fontWeight: FontWeight.w900, color: RadicalTheme.goldBright)),
            for (final item in LobbyStoreCatalog.vip) _storeItem(item),
          ],
        ),
      ),
    );
  }

  Widget _storeItem(LobbyStoreItem item) {
    final currency = RadicalDiamonds.of(item.currency);
    return ListTile(
      leading: Icon(item.vip ? Icons.workspace_premium_rounded : Icons.shopping_bag_rounded, color: currency.primary),
      title: Text(item.name),
      trailing: Text('${item.price} ${currency.emoji}', style: TextStyle(color: currency.primary, fontWeight: FontWeight.w900)),
    );
  }

  Widget _DiamondIcon(RadicalDiamondDefinition item) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .9, end: 1.08),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (_, scale, __) => Transform.scale(
        scale: scale,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: item.primary.withValues(alpha: .35), blurRadius: 15)],
          ),
          child: Center(child: Text(item.emoji, style: TextStyle(color: item.secondary, fontSize: 24))),
        ),
      ),
    );
  }

  void _showStaffAdmin() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('پنل همکاران رادیکال'),
        content: const Text('ابزارهای مدیریتی، آمار کامل، مدیریت لابی و گزارش‌ها در این بخش متمرکز هستند.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('بستن')),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final String name;
  final bool leader;
  final bool staff;
  const _PlayerRow({required this.name, this.leader = false, this.staff = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 19, child: Icon(Icons.person_rounded, size: 20)),
        const SizedBox(width: 9),
        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w800))),
        if (staff)
          const Text('◆ STAFF', style: TextStyle(color: RadicalTheme.violet, fontSize: 10, fontWeight: FontWeight.w900)),
        if (leader)
          const Text(' 👑 لیدر لابی', style: TextStyle(color: RadicalTheme.gold, fontSize: 10, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
