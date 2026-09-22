import '../widgets/avatar_frame_widget.dart';

class FrameMetadata {
  final FrameType type;
  final String titleFa;
  final String description;
  final List<int> gradientColors;
  final bool hasParticleEffect;
  final double animationSpeed;

  const FrameMetadata({
    required this.type,
    required this.titleFa,
    required this.description,
    required this.gradientColors,
    this.hasParticleEffect = false,
    this.animationSpeed = 1.0,
  });
}

class FrameCatalog {
  static const Map<FrameType, FrameMetadata> frames = {
    FrameType.none: FrameMetadata(
      type: FrameType.none,
      titleFa: 'ساده',
      description: 'حالت پیش‌فرض بدون حاشیه خاص',
      gradientColors: [0xFF424242, 0xFF212121],
    ),
    FrameType.gold: FrameMetadata(
      type: FrameType.gold,
      titleFa: 'طلای سلطنتی (VIP)',
      description: 'فریم درخشان طلایی برای بزرگان شهر و مافیا',
      gradientColors: [0xFFFFD700, 0xFFFFA000, 0xFFFFE082],
      hasParticleEffect: true,
      animationSpeed: 1.2,
    ),
    FrameType.fire: FrameMetadata(
      type: FrameType.fire,
      titleFa: 'شعله‌های دوزخ (Hellfire)',
      description: 'افکت آتشین رادیکال برای گیمرهای خشن و پدرخوانده‌ها',
      gradientColors: [0xFFFF3D00, 0xFFFF9100, 0xFFDD2C00],
      hasParticleEffect: true,
      animationSpeed: 2.0,
    ),
    FrameType.lightning: FrameMetadata(
      type: FrameType.lightning,
      titleFa: 'صاعقه و پلاسما (Cyber Storm)',
      description: 'انرژی خالص و جرقه‌های برقی پرسرعت',
      gradientColors: [0xFF00E5FF, 0xFF2979FF, 0xFF7C4DFF],
      hasParticleEffect: true,
      animationSpeed: 2.5,
    ),
    FrameType.neon: FrameMetadata(
      type: FrameType.neon,
      titleFa: 'سایبرپانک نئون (Night City)',
      description: 'درخشش امواج رنگی سایبر با پالس زنده',
      gradientColors: [0xFFFF007F, 0xFF00F0FF, 0xFF7928CA],
      hasParticleEffect: false,
      animationSpeed: 1.5,
    ),
  };
}
