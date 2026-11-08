import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widget/profile_header.dart';
import '../widget/genre_section.dart';
import '../widget/stat_row.dart';
import '../widget/common_app_bar.dart';
import '../widget/responsive_container.dart';

class ProfileScreen extends StatelessWidget {
    const ProfileScreen({super.key});
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: const CommonAppBar(title: '내 프로필', centerTitle: false),
            body: SafeArea(
                child: ResponsiveContainer(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                const ProfileHeader(),
                                const SizedBox(height: 32),
                                const StatRow(),
                                const SizedBox(height: 32),
                                const Align(
                                    alignment: Alignment.centerLeft,
                                    child: GenreSection(),
                                    ),
                                const SizedBox(height: 32),
                                ListTile(
                                    title: const Text('내가 등록한 평점'),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () => context.push('/my/ratings'),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}