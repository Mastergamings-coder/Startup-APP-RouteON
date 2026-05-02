import 'package:flutter/material.dart';

class MiffyStyle {
  static const TextStyle headerBlack = TextStyle(
    fontFamily: 'Inter', 
    fontWeight: FontWeight.w900, 
    color: Colors.black,
  );
  
  static const TextStyle overline = TextStyle(
    fontFamily: 'Inter', 
    fontWeight: FontWeight.bold, 
    fontSize: 12, 
    letterSpacing: 1.5,
  );
  
  static const BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white, 
    border: Border.fromBorderSide(BorderSide(color: Colors.black, width: 2)),
  );
  
  static const BoxShadow hardShadow = BoxShadow(
    color: Colors.black, 
    offset: Offset(4, 4), 
    blurRadius: 0,
  );
}

class MiffyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutline;

  const MiffyButton({
    super.key, 
    required this.text, 
    required this.onPressed, 
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutline ? Colors.white : Colors.black,
        foregroundColor: isOutline ? Colors.black : Colors.white,
        elevation: 0,
        side: isOutline ? const BorderSide(color: Colors.black, width: 2) : null,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      onPressed: onPressed,
      child: Text(
        text, 
        style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, letterSpacing: 1.0),
      ),
    );
  }
}