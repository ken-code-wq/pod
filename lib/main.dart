import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'screens/home/home_screen.dart';
import 'screens/documents/documents_screen.dart';
import 'screens/settings/settings_screen.dart';
// Document model will be used later

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  
  // Open the recordings box
  await Hive.openBox('recordings');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pod',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFE53935), // Red
          onPrimary: Colors.white,
          secondary: Colors.black,
          background: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [const HomeScreen(), const DocumentsScreen(), const SettingsScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Documents'), BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
