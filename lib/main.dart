import 'package:dart_hw8/screens/swipe_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const TinderApiApp());
}

class TinderApiApp extends StatelessWidget {
  const TinderApiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HW8 Swipe API',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SwipeScreen(),
    );
  }
}
