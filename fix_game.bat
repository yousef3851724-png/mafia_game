@echo off
chcp 65001 > nul
echo 🛠️ در حال ساخت فایل‌های لایه Presentation...

:: 1. Game Notifier
(
echo import 'dart:async';
echo import 'package:flutter_riverpod/flutter_riverpod';
echo import '../../domain/usecases/join_room_usecase.dart';
echo import '../../domain/usecases/submit_vote_usecase.dart';
echo import '../../domain/repositories/i_game_repository.dart';
echo import 'game_state.dart';
echo.
echo class GameNotifier extends StateNotifier^<GameState^> {
echo   final IGameRepository _repository;
echo   final JoinRoomUseCase _joinRoomUseCase;
echo   final SubmitVoteUseCase _submitVoteUseCase;
echo   StreamSubscription? _playersSub;
echo   StreamSubscription? _phaseSub;
echo.
echo   GameNotifier({
echo     required IGameRepository repository,
echo     required JoinRoomUseCase joinRoomUseCase,
echo     required SubmitVoteUseCase submitVoteUseCase,
echo   }^)  : _repository = repository,
echo         _joinRoomUseCase = joinRoomUseCase,
echo         _submitVoteUseCase = submitVoteUseCase,
echo         super(const GameState(^)^);
echo.
echo   Future^<void^> startGame(String roomId, String playerId, String playerName^) async {
echo     state = state.copyWith(status: GameStatus.loading^);
echo     try {
echo       await _repository.connectToGame(roomId, playerId^);
echo       await _joinRoomUseCase(roomId: roomId, playerName: playerName^);
echo       
echo       _playersSub = _repository.playersStream.listen((players^) {
echo         state = state.copyWith(status: GameStatus.active, players: players^);
echo       }^);
echo       
echo       _phaseSub = _repository.phaseStream.listen((phase^) {
echo         state = state.copyWith(currentPhase: phase^);
echo       }^);
echo     } catch (e^) {
echo       state = state.copyWith(status: GameStatus.error, errorMessage: e.toString(^)^);
echo     }
echo   }
echo.
echo   void selectPlayer(String playerId^) {
echo     state = state.copyWith(selectedPlayerId: playerId^);
echo   }
echo.
echo   Future^<void^> voteForSelected(String roomId, String voterId^) async {
echo     if (state.selectedPlayerId == null^) return;
echo     await _submitVoteUseCase(
echo       roomId: roomId,
echo       voterId: voterId,
echo       targetPlayerId: state.selectedPlayerId!,
echo     ^);
echo     state = state.copyWith(selectedPlayerId: null^);
echo   }
echo.
echo   @override
echo   void dispose(^) {
echo     _playersSub?.cancel(^);
echo     _phaseSub?.cancel(^);
echo     _repository.disconnect(^);
echo     super.dispose(^);
echo   }
echo }
) > lib\features\game\presentation\state\game_notifier.dart

:: 2. Player Card
(
echo import 'package:flutter/material';
echo import '../../domain/entities/player.dart';
echo.
echo class PlayerCard extends StatelessWidget {
echo   final Player player;
echo   final bool isSelected;
echo   final VoidCallback onTap;
echo.
echo   const PlayerCard({
echo     super.key,
echo     required this.player,
echo     required this.isSelected,
echo     required this.onTap,
echo   }^);
echo.
echo   @override
echo   Widget build(BuildContext context^) {
echo     return GestureDetector(
echo       onTap: player.isAlive ? onTap : null,
echo       child: Card(
echo         color: !player.isAlive ? Colors.grey : (isSelected ? Colors.red : Colors.grey^),
echo         shape: RoundedRectangleBorder(
echo           side: BorderSide(color: isSelected ? Colors.red : Colors.transparent, width: 2^),
echo           borderRadius: BorderRadius.circular(12^),
echo         ^),
echo         child: Padding(
echo           padding: const EdgeInsets.all(12.0^),
echo           child: Column(
echo             mainAxisAlignment: MainAxisAlignment.center,
echo             children: [
echo               Text(player.name, style: TextStyle(color: player.isAlive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold^)^),
echo               const SizedBox(height: 8^),
echo               Text(player.isAlive ? player.role : 'حذف شده', style: TextStyle(color: player.isAlive ? Colors.white70 : Colors.red, fontSize: 12^)^),
echo               if (player.votesReceived ^> 0^) ...[
echo                 const SizedBox(height: 8^),
echo                 CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Text(player.votesReceived.toString(^), style: const TextStyle(color: Colors.white, fontSize: 12^)^)^),
echo               ],
echo             ],
echo           ^),
echo         ^),
echo       ^),
echo     ^);
echo   }
echo }
) > lib\features\game\presentation\widgets\player_card.dart

:: 3. Game Screen
(
echo import 'package:flutter/material';
echo import '../../domain/entities/player.dart';
echo.
echo class GameScreen extends StatelessWidget {
echo   final List^<Player^> players;
echo   final String currentPhase;
echo   final String? selectedPlayerId;
echo   final Function(String^) onPlayerSelected;
echo   final VoidCallback onVoteSubmitted;
echo.
echo   const GameScreen({
echo     super.key,
echo     required this.players,
echo     required this.currentPhase,
echo     required this.selectedPlayerId,
echo     required this.onPlayerSelected,
echo     required this.onVoteSubmitted,
echo   }^);
echo.
echo   @override
echo   Widget build(BuildContext context^) {
echo     return Scaffold(
echo       backgroundColor: Colors.black,
echo       appBar: AppBar(title: Text('فاز بازی: $currentPhase'^), backgroundColor: Colors.grey, centerTitle: true^),
echo       body: Column(
echo         children: [
echo           Expanded(
echo             child: GridView.builder(
echo               padding: const EdgeInsets.all(16^),
echo               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12^),
echo               itemCount: players.length,
echo               itemBuilder: (context, index^) {
echo                 final player = players[index];
echo                 return GestureDetector(
echo                   onTap: (^) =^> onPlayerSelected(player.id^),
echo                   child: Container(
echo                     decoration: BoxDecoration(color: selectedPlayerId == player.id ? Colors.red : Colors.grey, borderRadius: BorderRadius.circular(12^)^),
echo                     child: Center(child: Text(player.name, style: const TextStyle(color: Colors.white^)^),^),
echo                   ^),
echo                 ^);
echo               },
echo             ^),
echo           ^),
echo           if (selectedPlayerId != null^)
echo             Padding(
echo               padding: const EdgeInsets.all(16.0^),
echo               child: ElevatedButton(
echo                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red^),
echo                 onTap: onVoteSubmitted,
echo                 child: const Text('ثبت رای نهایی', style: TextStyle(color: Colors.white^)^),
echo               ^),
echo             ^),
echo         ],
echo       ^),
echo     ^);
echo   }
echo }
) > lib\features\game\presentation\screens\game_screen.dart

echo 🗑️ در حال حذف فایل‌های موقت تکراری...
del /q lib\features\game\presentation\widgets\.gitkeep 2>nul

echo 📤 در حال ثبت در گیت و ارسال به گیت‌هاب...
git add lib/features/game/
git commit -m "Complete Presentation layer files perfectly"
git push origin main
if %errorlevel% neq 0 (
    git push origin master
)

echo 🎉 فرآیند ترمیم و آپلود با موفقیت به پایان رسید!
pause
