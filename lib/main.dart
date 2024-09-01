import 'package:flutter/material.dart';

import 'game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '關聯_臺灣版',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: false,
      ),
      home: const BasePage(),
    );
  }
}

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  bool isGameScreen = true;
  @override
  Widget build(BuildContext context) {
    return isGameScreen ? const GameScreen(): Scaffold(
      appBar: AppBar(
        title: const Text('關聯'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.share_outlined, size: 128, color: Colors.amber),
              const Text(
                '關聯',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                '將有關連的字組合在一起。',
                style: TextStyle(fontSize: 32),
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isGameScreen = true;
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '開始',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
