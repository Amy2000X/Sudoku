import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: Consumer<GameProvider>(
        builder: (context, game, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
              scaffoldBackgroundColor: game.backgroundColor,

              appBarTheme: AppBarTheme(
                backgroundColor: game.backgroundColor,
                elevation: 0,
                foregroundColor: Colors.black,
              ),
            ),

            home: HomeScreen(),
          );
        },
      ),
    );
  }
}