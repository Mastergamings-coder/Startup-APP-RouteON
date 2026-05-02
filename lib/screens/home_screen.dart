import 'package:flutter/material.dart';
import '../theme/miffy_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                      const SizedBox(width: 8),
                      Text('AI-CALCULATED TRANSIT', style: MiffyStyle.overline.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Big Title
                const Text(
                  'BUTUAN\nTRANSIT\nHUB', 
                  style: TextStyle(
                    fontFamily: 'Inter', 
                    fontSize: 60, 
                    height: 0.9, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: -2,
                    color: Colors.black,
                  )
                ),
                const SizedBox(height: 32),
                
                // Subtitle with left border
                Container(
                  padding: const EdgeInsets.only(left: 24),
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.black, width: 4)),
                  ),
                  child: const Text(
                    'Real-time distances. Local Butuan fare math. Minimalist urban guidance.',
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MiffyButton(text: 'BROWSE ROUTES', onPressed: () {}),
                    const SizedBox(height: 16),
                    MiffyButton(text: 'AI ASSISTANT', isOutline: true, onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
          
          // 4-Step Explanation Section
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildStepItem('01', 'EXTRACT INTENT', 'AI identifies where you are and where you want to go.'),
                const SizedBox(height: 32),
                _buildStepItem('02', 'MAP DISTANCE', 'Live API calculates the precise distance in KM.'),
                const SizedBox(height: 32),
                _buildStepItem('03', 'APPLY MATH', 'Local ₱14 base fare logic is applied to the distance.'),
                const SizedBox(height: 32),
                _buildStepItem('04', 'FINAL OUTPUT', 'You get the ride details and exact fare estimate.'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(number, style: const TextStyle(fontFamily: 'Inter', fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white30)),
        const SizedBox(height: 8),
        Text(title, style: MiffyStyle.overline.copyWith(color: Colors.white)),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(fontFamily: 'Inter', color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}