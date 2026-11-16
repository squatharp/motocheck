import 'package:flutter/material.dart';

void main() {
  runApp(const MotoCheckApp());
}

class MotoCheckApp extends StatelessWidget {
  const MotoCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoCheck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
      home: const Scaffold(
        body: Center(child: Text('MotoCheck - Etapa 0')),
      ),
    );
  }
}