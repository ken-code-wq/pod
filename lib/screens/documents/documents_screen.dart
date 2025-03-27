import 'package:flutter/material.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, foregroundColor: Theme.of(context).colorScheme.onPrimary),
      body: const Center(child: Text('Your transcriptions will appear here')),
    );
  }
}
