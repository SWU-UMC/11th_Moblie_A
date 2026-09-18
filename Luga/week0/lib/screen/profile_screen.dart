import 'package:flutter/material.dart';
import '.../widget/profile_header.dart';
import '.../widget/genre_section.dart';
import '.../widget/stat_row.dart';
import '.../widget/common_app_bar.dart';

class ProfileScreen extends StatelessWidget {
    const ProfileScreen({super.key});
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: const CommonAppBar(title: '내 프로필'),
            body: SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                            ProfileHeader(),
                            SizedBox(height: 32),
                            StatRow(),
                            SizedBox(height: 32),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: GenreSection(),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}