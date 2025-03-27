import 'package:flutter/material.dart';
import 'recording_screen.dart';
import '../../utils/circular_reveal_route.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, foregroundColor: Theme.of(context).colorScheme.onPrimary),
      body: const Center(child: Text('Record new audio here')),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              // Get the position of the FAB in global coordinates
              final RenderBox renderBox = context.findRenderObject() as RenderBox;
              final fabPosition = renderBox.localToGlobal(Offset.zero);
              final fabSize = renderBox.size;
              
              // Calculate the center of the FAB
              final fabCenter = Offset(
                fabPosition.dx + fabSize.width / 2,
                fabPosition.dy + fabSize.height / 2,
              );
              
              // Navigate with the custom circular reveal animation
              Navigator.push(
                context, 
                CircularRevealRoute(
                  page: const RecordingScreen(),
                  center: fabCenter,
                  color: const Color(0xFFE53935), // Red color matching FAB
                ),
              );
            },
            backgroundColor: const Color(0xFFE53935), // Red color
            foregroundColor: Colors.white, // White icon
            shape: const CircleBorder(),
            child: const Icon(Icons.mic, size: 36),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
