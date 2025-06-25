import 'package:exe201/Extra/nav_bar.dart';
import 'package:exe201/login/login_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(TvFApp());

class TvFApp extends StatelessWidget {
  const TvFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Management',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: BottomTab(),
      debugShowCheckedModeBanner: false,
    );
  }
}