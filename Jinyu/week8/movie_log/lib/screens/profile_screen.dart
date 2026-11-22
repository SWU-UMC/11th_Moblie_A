import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movielog_button.dart';
import '../widgets/stat_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final member = auth.member;

    final stats = [
      {'label': '본 영화', 'value': '342'},
      {'label': '평점', 'value': '4.2'},
      {'label': '즐겨찾기', 'value': '58'},
    ];
    final genres = ['드라마', 'SF', '애니메이션'];

    return Scaffold(
      appBar: CommonAppBar(
        title: '내 프로필',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: auth.storageCleanupInProgress
                ? null
                : () => context.read<AuthViewModel>().logout(),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: auth.memberStatus == MemberLoadStatus.loading && member == null
            ? const Center(child: CircularProgressIndicator())
            : auth.memberStatus == MemberLoadStatus.error && member == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(auth.message ?? '내 정보를 불러오지 못했어요.'),
                        const SizedBox(height: 12),
                        MovieLogButton(
                          label: '다시 시도',
                          onPressed: () =>
                              context.read<AuthViewModel>().loadMember(force: true),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        const Center(
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: AppColors.gray,
                            backgroundImage: AssetImage(
                              'assets/images/profile_movielog.jpg',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                member?.nickname ?? '무비러버',
                                style: AppTextStyles.titleLarge,
                              ),
                              if (member?.email != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  member!.email,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                              const SizedBox(height: 8),
                              const Text(
                                '매주 주말 영화관으로 출근하는 프로 관객. 좋은\n영화를 보고 기록하는 것을 좋아합니다.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: member == null
                                ? null
                                : () => context.push('/my/profile/edit'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppColors.violet,
                              backgroundColor: AppColors.warmWhite,
                              elevation: 0,
                              side: const BorderSide(color: AppColors.violet),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '프로필 수정',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: stats.map((stat) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: StatItem(
                                  label: stat['label']!,
                                  value: stat['value']!,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: () => context.push('/my/ratings'),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.violet.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '내가 등록한 평점',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.violet,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          '선호하는 장르',
                          style: AppTextStyles.titleMediumB,
                        ),
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
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2),
                                side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3),
                                ),
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