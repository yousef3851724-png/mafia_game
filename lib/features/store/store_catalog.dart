import '../../core/models/app_models.dart' as app;
import '../lobbies/lobby_system.dart';

/// Data-only store catalog. UI is intentionally untouched.
const avatarStoreItems = <app.AvatarItem>[
  app.AvatarItem(id: 'avatar_shadow', name: 'سایه شب', priceDiamonds: 100, assetPath: 'assets/images/avatar_shadow.svg', currency: app.DiamondType.blue),
  app.AvatarItem(id: 'avatar_detective', name: 'بازرس', priceDiamonds: 200, assetPath: 'assets/images/avatar_detective.svg', currency: app.DiamondType.blue),
  app.AvatarItem(id: 'avatar_crimson', name: 'قرمز مرموز', priceDiamonds: 500, assetPath: 'assets/images/avatar_crimson.svg', currency: app.DiamondType.adult),
  app.AvatarItem(id: 'avatar_gold', name: 'طلایی رادیکال', priceDiamonds: 200, assetPath: 'assets/images/avatar_gold.svg', currency: app.DiamondType.radical, vipOnly: true),
  app.AvatarItem(id: 'avatar_noir', name: 'نوآر', priceDiamonds: 500, assetPath: 'assets/images/avatar_noir.svg', currency: app.DiamondType.radical, vipOnly: true),
  app.AvatarItem(id: 'avatar_teen', name: 'نوجوان رادیکال', priceDiamonds: 150, assetPath: 'assets/images/avatar_gold.svg', currency: app.DiamondType.teen),
];

const radicalDiamondStoreItems = <LobbyStoreItem>[
  LobbyStoreItem(id: 'radical_avatar_gold', name: 'آواتار طلایی رادیکال', price: 200, currency: DiamondType.radical, vip: true),
  LobbyStoreItem(id: 'radical_vip_lobby', name: 'دسترسی لابی VIP', price: 250, currency: DiamondType.radical, vip: true),
  LobbyStoreItem(id: 'radical_special_scenario', name: 'سناریوی ویژه رادیکال', price: 500, currency: DiamondType.radical, vip: true),
];

const teenDiamondStoreItems = <LobbyStoreItem>[
  LobbyStoreItem(id: 'teen_sticker_pack', name: 'پک استیکر نوجوان', price: 75, currency: DiamondType.teen),
  LobbyStoreItem(id: 'teen_avatar_pack', name: 'پک آواتار نوجوان', price: 150, currency: DiamondType.teen),
];

const adultDiamondStoreItems = <LobbyStoreItem>[
  LobbyStoreItem(id: 'adult_scenario_pack', name: 'پک سناریوی بزرگسال', price: 450, currency: DiamondType.adult),
  LobbyStoreItem(id: 'adult_avatar_pack', name: 'پک آواتار بزرگسال', price: 300, currency: DiamondType.adult),
];
