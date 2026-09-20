
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});
  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int coins = 1000;
  final Set<String> owned = {};
  String selectedAvatar = 'avatar_shadow';
  String? selectedFrame;
  String? selectedSticker;
  int activeTab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      coins = p.getInt('player_coins') ?? 1000;
      owned.clear();
      owned.addAll(p.getStringList('owned_store_items') ?? []);
      selectedAvatar = p.getString('selected_store_avatar') ?? 'avatar_shadow';
      selectedFrame = p.getString('selected_frame');
      selectedSticker = p.getString('selected_sticker');
    });
  }

  Future<void> _buy(StoreItem item) async {
    final p = await SharedPreferences.getInstance();
    if (!owned.contains(item.id)) {
      if (coins < item.price) {
        _toast('سکه کافی نیست! 🪙', isError: true);
        return;
      }
      coins -= item.price;
      owned.add(item.id);
      await p.setInt('player_coins', coins);
      await p.setStringList('owned_store_items', owned.toList());
      _celebrate(item);
    }
    if (item.category == 'آواتار' || item.category == 'ویژه') {
      selectedAvatar = item.id;
      await p.setString('selected_store_avatar', item.id);
    } else if (item.category == 'فریم') {
      selectedFrame = item.id;
      await p.setString('selected_frame', item.id);
    } else {
      selectedSticker = item.id;
      await p.setString('selected_sticker', item.id);
    }
    if (!mounted) return;
    setState(() {});
    _toast('${item.name} فعال شد ✓');
  }

  void _toast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      backgroundColor: isError ? Colors.redAccent.shade700 : const Color(0xFF16A34A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _celebrate(StoreItem item) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (_, v, __) => Transform.scale(
          scale: v,
          child: Dialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: Color(0xFFFFD700), width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 10),
                  const Text('خرید موفق!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Text(item.name, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2)),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('عالیه!', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    });
  }

  List<StoreItem> get _filtered {
    if (activeTab == 0) return StoreCatalog.avatars;
    if (activeTab == 1) return StoreCatalog.frames;
    if (activeTab == 2) return StoreCatalog.stickers;
    return StoreCatalog.bundles;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('فروشگاه رادیکال', style: TextStyle(fontWeight: FontWeight.w900)),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            _walletCard(),
            const SizedBox(height: 15),
            _previewCard(),
            const SizedBox(height: 15),
            _tabBar(),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (_, i) => _itemCard(_filtered[i]),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _walletCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 36),
          const SizedBox(width: 12),
          const Expanded(child: Text('موجودی سکه', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
          Text('$coins', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _previewCard() {
    final frameItem = StoreCatalog.all.firstWhere((e) => e.id == selectedFrame, orElse: () => StoreCatalog.all.first);
    final frameColor = selectedFrame != null ? frameItem.frameColor : null;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Text('پیش‌نمایش', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: frameColor ?? const Color(0xFF444444), width: 4),
              boxShadow: frameColor != null ? [BoxShadow(color: frameColor, blurRadius: 20, spreadRadius: 2)] : null,
            ),
            child: const Icon(Icons.person_rounded, size: 60, color: Color(0xFFFFD700)),
          ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    final tabs = ['آواتار', 'فریم', 'استیکر', '🔥 ویژه'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(tabs.length, (i) {
        final active = activeTab == i;
        final isSpecial = i == 3;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => activeTab = i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: active
                    ? (isSpecial
                        ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF4500)])
                        : const LinearGradient(colors: [Color(0xFF8A2BE2), Color(0xFF6A1B9A)]))
                    : null,
                color: active ? null : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? Colors.transparent : const Color(0xFF333333)),
              ),
              child: Text(
                tabs[i],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _itemCard(StoreItem item) {
    final isOwned = owned.contains(item.id);
    final isActive = (item.category == 'فریم' && selectedFrame == item.id) ||
        (item.category == 'استیکر' && selectedSticker == item.id) ||
        ((item.category == 'آواتار' || item.category == 'ویژه') && selectedAvatar == item.id);
    final isSpecial = item.category == 'ویژه';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: isSpecial ? const LinearGradient(colors: [Color(0xFF2A1A00), Color(0xFF3A2500)]) : null,
        color: isSpecial ? null : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSpecial ? const Color(0xFFFFD700) : (isActive ? const Color(0xFF16A34A) : const Color(0xFF2A2A2A)),
          width: isSpecial ? 2 : 1,
        ),
        boxShadow: isSpecial ? [const BoxShadow(color: Color(0x55FFD700), blurRadius: 15)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (item.badge != null)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF0000), Color(0xFF8B0000)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(item.badge!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ),
          Expanded(
            child: Center(
              child: item.asset != null
                  ? SvgPicture.asset(item.asset!, fit: BoxFit.contain)
                  : Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: item.frameColor ?? const Color(0xFFFFD700), width: 4),
                        color: const Color(0xFF333333),
                      ),
                      child: Icon(item.icon, size: 40, color: const Color(0xFFFFD700)),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
          const SizedBox(height: 2),
          if (item.oldPrice != null && !isOwned)
            Text('${item.oldPrice} 🪙', style: const TextStyle(color: Colors.grey, fontSize: 11, decoration: TextDecoration.lineThrough))
          else
            Text(item.category, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 6),
          SizedBox(
            height: 34,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isActive ? const Color(0xFF16A34A) : (isSpecial ? const Color(0xFFFF4500) : const Color(0xFF8A2BE2)),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _buy(item),
              child: Text(
                isActive ? '✓ فعال' : (isOwned ? 'فعال‌سازی' : '${item.price} 🪙'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StoreItem {
  final String id;
  final String name;
  final String category;
  final int price;
  final int? oldPrice;
  final String? asset;
  final IconData icon;
  final Color? frameColor;
  final String? badge;

  const StoreItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.oldPrice,
    this.asset,
    required this.icon,
    this.frameColor,
    this.badge,
  });
}

class StoreCatalog {
  static const List<StoreItem> avatars = [
    StoreItem(id: 'avatar_shadow', name: 'سایه شب', category: 'آواتار', price: 100, asset: 'assets/images/avatar_shadow.svg', icon: Icons.person_rounded),
    StoreItem(id: 'avatar_detective', name: 'بازرس', category: 'آواتار', price: 200, asset: 'assets/images/avatar_detective.svg', icon: Icons.search_rounded),
    StoreItem(id: 'avatar_crimson', name: 'قرمز مرموز', category: 'آواتار', price: 300, asset: 'assets/images/avatar_crimson.svg', icon: Icons.local_fire_department_rounded),
    StoreItem(id: 'avatar_gold', name: 'طلایی رادیکال', category: 'آواتار', price: 500, asset: 'assets/images/avatar_gold.svg', icon: Icons.workspace_premium_rounded),
  ];

  static const List<StoreItem> frames = [
    StoreItem(id: 'frame_fire', name: 'فریم آتش', category: 'فریم', price: 180, icon: Icons.local_fire_department_rounded, frameColor: Color(0xFFFF4500), badge: 'داغ'),
    StoreItem(id: 'frame_lightning', name: 'فریم صاعقه', category: 'فریم', price: 180, icon: Icons.bolt_rounded, frameColor: Color(0xFF00BFFF)),
    StoreItem(id: 'frame_gold', name: 'فریم طلایی', category: 'فریم', price: 250, icon: Icons.workspace_premium_rounded, frameColor: Color(0xFFFFD700), badge: 'VIP'),
  ];

  static const List<StoreItem> stickers = [
    StoreItem(id: 'sticker_mvp', name: 'استیکر MVP', category: 'استیکر', price: 120, icon: Icons.emoji_events_rounded),
    StoreItem(id: 'sticker_sus', name: 'استیکر مشکوک', category: 'استیکر', price: 90, icon: Icons.visibility_rounded),
  ];

  static const List<StoreItem> bundles = [
    StoreItem(id: 'bundle_king', name: 'بسته پادشاهی', category: 'ویژه', price: 250, oldPrice: 400, asset: 'assets/images/avatar_gold.svg', icon: Icons.workspace_premium_rounded, frameColor: Color(0xFFFFD700), badge: '۳۷٪ تخفیف'),
    StoreItem(id: 'bundle_fire', name: 'قاتل + فریم آتش', category: 'ویژه', price: 150, oldPrice: 280, asset: 'assets/images/avatar_crimson.svg', icon: Icons.local_fire_department_rounded, frameColor: Color(0xFFFF4500), badge: 'محدود'),
  ];

  static List<StoreItem> get all => [...avatars, ...frames, ...stickers, ...bundles];
}
