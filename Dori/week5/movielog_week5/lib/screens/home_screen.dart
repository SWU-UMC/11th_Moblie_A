import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_outlined,
            size: 64,
            color: Color(0xFF6B52A3),
          ),
          SizedBox(height: 16),
          Text(
            'MovieLog 홈',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('오늘은 어떤 영화를 감상할까요?'),
        ],
      ),
    );
  }
}