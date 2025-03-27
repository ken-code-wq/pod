import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Settings', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, foregroundColor: Theme.of(context).colorScheme.onPrimary), body: const Center(child: Text('App settings will go here')));
  }
}
