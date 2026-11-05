import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Color(0xFF6B52A3),
          ),
          SizedBox(height: 16),
          Text(
            '마이페이지',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('내 영화 기록을 확인해 보세요.'),
        ],
      ),
    );
  }
}