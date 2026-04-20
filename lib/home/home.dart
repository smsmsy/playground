import 'package:flutter/material.dart';
import 'package:playground/core/screen_kind.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ページ選択')),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          spacing: 8,
          children: [...ScreenKindEx.generateNavigatorButtons(context)],
        ),
      ),
    );
  }
}

extension ScreenKindEx on ScreenKind {
  static List<Widget> generateNavigatorButtons(BuildContext context) {
    return ScreenKind.values
        .map(
          (e) => FilledButton.icon(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => e.widget));
            },
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 36),
            ),
            label: Text(e.titleString),
            icon: Icon(Icons.arrow_forward_ios, size: 36),
          ),
        )
        .toList();
  }
}
