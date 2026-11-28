import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/app_providers.dart';

class FramePngState {
  final Set<String> owned;
  final String? equipped;
  final String? error;
  const FramePngState({this.owned = const {}, this.equipped, this.error});
}

class FramePngController extends StateNotifier<FramePngState> {
  final Ref ref;
  FramePngController(this.ref) : super(const FramePngState()) {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = FramePngState(
      owned: (p.getStringList('png_owned') ?? []).toSet(),
      equipped: p.getString('png_equipped'),
    );
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('png_owned', state.owned.toList());
    if (state.equipped == null) {
      await p.remove('png_equipped');
    } else {
      await p.setString('png_equipped', state.equipped!);
    }
  }

  Future<bool> buy(String id, int price) async {
    final w = ref.read(walletProvider);
    if (w.diamonds < price) {
      state = FramePngState(owned: state.owned, equipped: state.equipped, error: 'الماس کافی نیست');
      return false;
    }
    ref.read(walletProvider.notifier).state =
        RadicalWallet(coins: w.coins, diamonds: w.diamonds - price);
    state = FramePngState(owned: {...state.owned, id}, equipped: id);
    await _save();
    return true;
  }

  Future<void> equip(String? id) async {
    state = FramePngState(owned: state.owned, equipped: id);
    await _save();
  }
}

final framePngProvider =
    StateNotifierProvider<FramePngController, FramePngState>((ref) => FramePngController(ref));
