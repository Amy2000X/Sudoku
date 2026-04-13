import 'package:flutter/material.dart';
import '../services/sudoku_generator.dart';
import 'home_screen.dart';

class CompletionScreen extends StatelessWidget {
  final Difficulty difficulty;
  final String time;

  const CompletionScreen({
    super.key,
    required this.difficulty,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "🎉 Congratulations!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("You completed: ${difficulty.name}"),
            SizedBox(height: 10),
            Text("Time: $time"),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                  (route) => false,
                );
              },
              child: Text("Back to Home"),
            )
          ],
        ),
      ),
    );
  }
}