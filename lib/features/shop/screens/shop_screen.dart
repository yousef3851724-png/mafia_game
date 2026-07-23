import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../widgets/currency_badge.dart';
import '../widgets/shop_item_card.dart';

enum ShopCategory { special, avatars, frames, tombstones, effects, stickers, gifs, emojis, bundles }

class ShopScreen extends StatefulWidget {
  const ShopScreen({
    super.key,
    this.coinBalance = 254850,
    this.diamondBalance = 1250,
    this.vipLevel = 3,
  });

  final int coinBalance;
  final int diamondBalance;
  final int vipLevel;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  ShopCategory _category = ShopCategory.frames;

  static const Map<ShopCategory, String> _labels = {
    ShopCategory.special: 'ویژه',
    ShopCategory.avatars: 'آواتارها',
    ShopCategory.frames: 'قاب‌ها',
    ShopCategory.tombstones: 'سنگ قبرها',
    ShopCategory.effects: 'افکت‌ها',
    ShopCategory.stickers: 'استیکرها',
    ShopCategory.gifs: 'گیف‌ها',
    ShopCategory.emojis: 'ایموجی‌ها',
    ShopCategory.bundles: 'بسته‌ها',
  };

  static const Map<ShopCategory, IconData> _icons = {
    ShopCategory.special: Icons.star,
    ShopCategory.avatars: Icons.person,
    ShopCategory.frames: Icons.circle_outlined,
    ShopCategory.tombstones: Icons.church,
    ShopCategory.effects: Icons.auto_awesome,
    ShopCategory.stickers: Icons.emoji_emotions_outlined,
    ShopCategory.gifs: Icons.gif_box_outlined,
    ShopCategory.emojis: Icons.sentiment_satisfied_alt,
    ShopCategory.bundles: Icons.card_giftcard,
  };

  // نمونه‌داده‌ی نام قاب‌ها مطابق موکاپ - در نسخه‌ی نهایی از دیتابیس/سرور می‌آید
  static const List<Map<String, dynamic>> _frames = [
    {'name': 'برنزی', 'price': 1000, 'gem': false},
    {'name': 'نقره‌ای', 'price': 3000, 'gem': false},
    {'name': 'طلایی', 'price': 8000, 'gem': false},
    {'name': 'الماسی', 'price': 120, 'gem': true},
    {'name': 'بنفش افسانه‌ای', 'price': 250, 'gem': true},
    {'name': 'سرخ آتشی', 'price': 500, 'gem': true},
    {'name': 'زمردی', 'price': 15000, 'gem': false},
    {'name': 'خدایی', 'price': 1200, 'gem': true},
  ];

  static const List<String> _stickerLabels = [
    'هاهاها!', 'ساکت باش!', 'بی‌گناهم', 'به تو اطمینان ندارم',
    'من رأی می‌دم', 'خداحافظ', 'کار تمام است', 'مشکوکم',
  ];

  static const List<String> _gifLabels = [
    'دست‌ها بالا', 'هاهاها!', 'من می‌میرم', 'آفرین!',
    'فکر کنم...', 'خیلی خوبه!', 'عصبانی‌ام!', 'به سلامتی!',
  ];

  static const List<String> _freeEmojis = ['😂', '😭', '😍', '😎', '😡', '😱', '👍', '👏', '🙏', '🎉', '💀', '👻'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            const SizedBox(height: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSideTabs(),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary)),
          Text('فروشگاه', style: AppTextStyles.titleLarge),
          const Spacer(),
          CurrencyBadge(type: CurrencyType.coin, value: _format(widget.coinBalance), onAddTap: () {}),
          const SizedBox(width: 8),
          CurrencyBadge(type: CurrencyType.diamond, value: _format(widget.diamondBalance), onAddTap: () {}),
          const SizedBox(width: 8),
          CurrencyBadge(type: CurrencyType.vip, value: 'VIP ${widget.vipLevel}'),
        ],
      ),
    );
  }

  Widget _buildSideTabs() {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(left: 8),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: _labels.entries.map((e) {
          final selected = e.key == _category;
          return InkWell(
            onTap: () => setState(() => _category = e.key),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.secondary.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: selected ? Border.all(color: AppColors.secondary.withOpacity(0.5)) : null,
              ),
              child: Column(
                children: [
                  Icon(_icons[e.key], size: 18, color: selected ? AppColors.secondary : AppColors.textSecondary),
                  const SizedBox(height: 4),
                  Text(e.value, style: AppTextStyles.caption.copyWith(color: selected ? AppColors.secondary : AppColors.textSecondary, fontSize: 10)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      children: [
        _buildPromoBanners(),
        const SizedBox(height: 16),
        _sectionTitle('قاب‌ها'),
        _buildFramesGrid(),
        const SizedBox(height: 16),
        _sectionTitle('استیکرها (هر استیکر ۷۵۰ سکه)'),
        _buildHorizontalCards(_stickerLabels, price: 750, gem: false, icon: Icons.emoji_emotions),
        const SizedBox(height: 16),
        _sectionTitle('گیف‌ها (هر گیف ۱۵۰۰ سکه)'),
        _buildHorizontalCards(_gifLabels, price: 1500, gem: false, icon: Icons.gif_box, square: true),
        const SizedBox(height: 16),
        _sectionTitle('ایموجی‌ها (رایگان)'),
        _buildFreeEmojiRow(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPromoBanners() {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _promoBanner('بسته ویژه سکه', 'مقدار زیادی سکه دریافت کن!', Icons.inventory_2, AppColors.coinColor),
          _promoBanner('بسته ویژه الماس', 'الماس بیشتر، جایزه بیشتر!', Icons.diamond, AppColors.diamondColor),
          _promoBanner('آواتار لجندری ویژه', 'محدود و بسیار خاص', Icons.person, AppColors.primary),
        ],
      ),
    );
  }

  Widget _promoBanner(String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10), maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          Text('همه', style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _buildFramesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: _frames.length,
      itemBuilder: (context, i) {
        final f = _frames[i];
        return ShopItemCard(
          name: f['name'] as String,
          price: f['price'] as int,
          priceIsGem: f['gem'] as bool,
          icon: Icons.circle_outlined,
          onTap: () {},
        );
      },
    );
  }

  Widget _buildHorizontalCards(List<String> labels, {required int price, required bool gem, required IconData icon, bool square = false}) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => ShopItemCard(
          name: labels[i],
          price: price,
          priceIsGem: gem,
          icon: icon,
          isCircular: !square,
          onTap: () {},
        ),
      ),
    );
  }

  Widget _buildFreeEmojiRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        spacing: 14,
        runSpacing: 10,
        children: _freeEmojis.map((e) => Text(e, style: const TextStyle(fontSize: 26))).toList(),
      ),
    );
  }

  String _format(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
