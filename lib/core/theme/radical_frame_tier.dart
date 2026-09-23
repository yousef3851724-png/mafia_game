import '../models/diamond_type.dart';
import 'radical_theme.dart';

enum RadicalFrameTier {
  none(0, 'نیست', '', 0, DiamondType.blue, 'فریم ندارید', 0xFF808080),
  bronze(1, 'برنز', 'ب', 50, DiamondType.blue, 'فریم برنز', 0xFF8B7355),
  silver(2, 'نقره', 'ن', 100, DiamondType.blue, 'فریم نقره', 0xFFC0C0C0),
  gold(3, 'طلا', 'ط', 250, DiamondType.radical, 'فریم طلا', 0xFFFFD700),
  platinum(4, 'پلاتین', 'پ', 500, DiamondType.teen, 'فریم پلاتین', 0xFFE5E4E2),
  diamond(5, 'الماس', 'ا', 1000, DiamondType.adult, 'فریم الماس', 0xFFB9F2FF),
  legendary(6, 'افسانوی', 'ا', 2500, DiamondType.adult, 'فریم افسانوی', 0xFFFF6B9D);

  final int tierIndex;
  final String name;
  final String displayName;
  final int diamondPrice;
  final DiamondType diamondType;
  final String description;
  final int color;

  const RadicalFrameTier(
    this.tierIndex,
    this.name,
    this.displayName,
    this.diamondPrice,
    this.diamondType,
    this.description,
    this.color,
  );
}
