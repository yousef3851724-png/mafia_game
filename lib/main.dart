
import 'package:flutter/material.dart'; 
import 'features/game/presentation/screens/game_room_screen.dart'; 
 
void main() { 
  runApp(const MyApp()); 
} 
 
class MyApp extends StatelessWidget { 
  const MyApp({super.key}); 
 
  @override 
  Widget build(BuildContext context) { 
    return MaterialApp( 
      title: 'Mafia Radical', 
      theme: ThemeData.dark(), 
      home: const GameRoomScreen(), 
    ); 
  } 
