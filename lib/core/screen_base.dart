import 'package:flutter/material.dart';

class ScreenBase extends StatelessWidget {
  const ScreenBase({
    super.key,
    required this.body,
    this.endDrawer,
    this.floatingActionButton,
  });

  final Widget body;
  final Drawer? endDrawer;
  final FloatingActionButton? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios_new),
          ),
        ),
        floatingActionButton: floatingActionButton,
        endDrawer: endDrawer,
        body: body,
      ),
    );
  }
}
