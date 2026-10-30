import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/stat_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': '본 영화', 'value': '342'},
      {'label': '평점', 'value': '4.2'},
      {'label': '즐겨찾기', 'value': '58'},
    ];
    final genres = ['드라마', 'SF', '애니메이션'];

    return Scaffold(
      appBar: const CommonAppBar(
        title: '내 프로필',
        centerTitle: false,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: const CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.gray,
                  backgroundImage: AssetImage('assets/images/profile_movielog.jpg'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    const Text('무비러버', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 8),
                    const Text(
                      '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은\n영화를 보고 기록하는 것을 좋아합니다.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.violet,
                    backgroundColor: AppColors.warmWhite,
                    elevation: 0,
                    side: const BorderSide(color: AppColors.violet),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '프로필 수정',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: stats.map((stat) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: StatItem(
                        label: stat['label']!,
                        value: stat['value']!,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              const Text('선호하는 장르', style: AppTextStyles.titleMediumB),
              const SizedBox(height: 12),
              Row(
                children: genres.map((genre) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text(
                        genre,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.violet,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
