import 'package:flutter/material.dart';
import '.../widget/profile_header.dart';
import '.../widget/stat_item.dart';

class ProfileScreen extends StatelessWidget {
    const ProfileScreen({super.key});
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const ProfileHeader(),
                            const SizedBox(height: 24),
                            const StatItem(label: '본 영화', value: '24'),
                        ],
                    ),
                ),
            ),
        );
}