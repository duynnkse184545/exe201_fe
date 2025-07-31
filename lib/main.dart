import 'package:exe201/ui/extra/nav_bar.dart';
import 'package:exe201/ui/login/login_ui.dart';
import 'package:exe201/ui/test/budget_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(
  ProviderScope(
    child: TvFApp(),
  ),
);

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
      //home: BudgetTabTest(userId: 'F29EA8B0-E604-47F6-B048-EA28D74D9529'),
      home: BottomTab(),
      debugShowCheckedModeBanner: false,
    );
  }
}