import 'package:flutter/material.dart';

import 'core/constants/app_theme.dart';
import 'core/models/game_models.dart';
import 'features/setup/setup_screen.dart';
import 'features/pass_and_play/role_reveal_screen.dart';
import 'features/gameplay/gameplay_screen.dart';
import 'features/victory/victory_screen.dart';

void main() {
  runApp(const MafiaRadicalApp());
}

class MafiaRadicalApp extends StatelessWidget {
  const MafiaRadicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mafia Radical',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryRed,
          secondary: AppColors.accentCyan,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accentCyan),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white38),
        ),
      ),
      home: const MainCoordinator(),
    );
  }
}

enum AppStage {
  setup,
  roleReveal,
  gameplay,
  victory,
}

class MainCoordinator extends StatefulWidget {
  const MainCoordinator({super.key});

  @override
  State<MainCoordinator> createState() => _MainCoordinatorState();
}

class _MainCoordinatorState extends State<MainCoordinator> {
  AppStage _stage = AppStage.setup;
  List<Player> _players = [];
  Team? _winner;

  void _startGame(List<Player> players) {
    setState(() {
      _players = players;
      _stage = AppStage.roleReveal;
    });
  }

  void _goToGameplay() {
    setState(() {
      _stage = AppStage.gameplay;
    });
  }

  void _endGame(Team winner) {
    setState(() {
      _winner = winner;
      _stage = AppStage.victory;
    });
  }

  void _restartGame() {
    setState(() {
      _players = [];
      _winner = null;
      _stage = AppStage.setup;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case AppStage.setup:
        return SetupScreen(
          onStart: _startGame,
        );

      case AppStage.roleReveal:
        return RoleRevealScreen(
          players: _players,
          onFinished: _goToGameplay,
        );

      case AppStage.gameplay:
        return GameplayScreen(
          players: _players,
          onGameOver: _endGame,
        );

      case AppStage.victory:
        return VictoryScreen(
          winner: _winner ?? Team.citizen,
          players: _players,
          onRestart: _restartGame,
        );
    }
  }
}
