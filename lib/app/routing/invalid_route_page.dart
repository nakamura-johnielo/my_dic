import 'package:flutter/material.dart';

class InvalidRoutePage extends StatelessWidget {
  const InvalidRoutePage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Invalid link')),
        body: Center(child: Text(message)),
      );
}
