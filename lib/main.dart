import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/screen/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // color: const Color(0xFFE64D3D),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE64D3D),
        primaryColor: const Color(0xFFE64D3D),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
