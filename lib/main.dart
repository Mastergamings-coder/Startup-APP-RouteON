import 'package:flutter/material.dart';
import 'theme/miffy_style.dart';
import 'screens/home_screen.dart';
import 'screens/assistant_screen.dart';

void main() {
  runApp(const ButuanTransitApp());
}

class ButuanTransitApp extends StatelessWidget {
  const ButuanTransitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BUTUAN TRANSIT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // These are the 4 tabs at the bottom of your app
  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('ROUTES (Coming Soon)', style: MiffyStyle.headerBlack)),
    const Center(child: Text('FARES (Coming Soon)', style: MiffyStyle.headerBlack)), 
    const AssistantScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 24,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: Colors.black, height: 2.0),
        ),
        title: Row(
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.directions_bus, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'BUTUAN TRANSIT',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w900,
                color: Colors.black,
                fontSize: 18,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black, width: 2)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            _buildNavItem(Icons.home, 'HOME', 0),
            _buildNavItem(Icons.directions_bus, 'ROUTES', 1),
            _buildNavItem(Icons.info_outline, 'FARES', 2),
            _buildNavItem(Icons.help_outline, 'AI ASK', 3),
          ],
        ),
      ),
    );
  }

 BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        width: double.infinity,
        height: 64, 
        // THE FIX: We moved the color inside the BoxDecoration!
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: index != 3 
              ? const Border(right: BorderSide(color: Colors.black, width: 2))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.5,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
      label: label,
    );
  }
}