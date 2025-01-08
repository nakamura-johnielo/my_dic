import 'package:flutter/material.dart';

class NoteFragment extends StatelessWidget {
  const NoteFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note'),
      ),
      body: Center(
        child: Text('This is note screen'),
      ),
    );
  }
}
