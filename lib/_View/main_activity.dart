import 'package:flutter/material.dart';
import 'package:my_dic/_View/search_fragment.dart';
import 'package:my_dic/_View/word_page_fragment.dart';

class MainActivity extends StatefulWidget {
  const MainActivity({super.key, required this.title});
  final String title;

  @override
  State<MainActivity> createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        //child: WordPageFragment(),
        child: SearchFragment(),
      ),

      /* floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),  */ // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
