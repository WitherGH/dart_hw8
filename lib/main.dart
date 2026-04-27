import 'package:dart_hw8/bloc/swipe/swipe_bloc.dart';
import 'package:dart_hw8/bloc/swipe/swipe_event.dart';
import 'package:dart_hw8/screens/swipe_screen.dart';
import 'package:dart_hw8/services/random_user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      home: BlocProvider(
        create: (_) =>
            SwipeBloc(service: RandomUserService())..add(const SwipeLoadRequested()),
        child: const SwipeScreen(),
      ),
    );
  }
}
