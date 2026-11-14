import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
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
                                const SizedBox(height: 24),
                                Material(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(
                                            color: AppColors.primaryContainer,
                                            width: 1.2,
                                        ),
                                    ),
                                    child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () => context.push('/my/ratings'),
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 22,
                                            ),
                                            child: Row(
                                                children: [
                                                    Expanded(
                                                        child: Text(
                                                            '내가 등록한 평점',
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .titleMedium
                                                                ?.copyWith(
                                                                    fontWeight: FontWeight.w700,
                                                                    color: AppColors.textPrimary,
                                                                ),
                                                        ),
                                                    ),
                                                    const Icon(
                                                        Icons.chevron_right,
                                                        color: AppColors.primary,
                                                    ),
                                                ],
                                            ),
                                        ),
                                    ),
                                ),
                                const SizedBox(height: 32),
                                const Align(
                                    alignment: Alignment.centerLeft,
                                    child: GenreSection(),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}