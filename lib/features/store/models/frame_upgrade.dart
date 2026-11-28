enum FrameUpgradeType { rarity, glow, animation, special }

class FrameUpgrade {
  final String id;
  final String name;
  final FrameUpgradeType type;
  final int diamondCost;
  final String description;
  final bool isOwned;

  const FrameUpgrade({
    required this.id,
    required this.name,
    required this.type,
    required this.diamondCost,
    required this.description,
    this.isOwned = false,
  });
}

const frameUpgrades = <FrameUpgrade>[
  FrameUpgrade(
    id: 'upgrade_glow_1',
    name: 'درخشش روشن',
    type: FrameUpgradeType.glow,
    diamondCost: 50,
    description: 'فریم کو روشن اثر شامل کریں',
  ),
  FrameUpgrade(
    id: 'upgrade_spin',
    name: 'گھومتا ہوا اثر',
    type: FrameUpgradeType.animation,
    diamondCost: 100,
    description: 'فریم کو گھومتا ہوا متحرک بنائیں',
  ),
  FrameUpgrade(
    id: 'upgrade_rare',
    name: 'نادر طراز',
    type: FrameUpgradeType.rarity,
    diamondCost: 200,
    description: 'فریم کو نادر میں تبدیل کریں',
  ),
  FrameUpgrade(
    id: 'upgrade_mythic',
    name: 'افسانوی طراز',
    type: FrameUpgradeType.special,
    diamondCost: 500,
    description: 'خصوصی افسانوی اثر شامل کریں',
  ),
];
