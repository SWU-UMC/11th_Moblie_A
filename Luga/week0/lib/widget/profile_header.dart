import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            width: 96, height: 96,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
            ),

            child: ClipOval(
                child: Image.asset(
                    'assets/images/profile/profile_movielog.jpg',
                    fit: BoxFit.cover,
                ),
            ),
        ),
        const SizedBox(height: 16),

        Text('무비러버', style: textTheme.titleLarge),
        const SizedBox(height: 8),

        Text('매주 주말엔 영화관으로 출근하는 프로 관람객.\n좋은 영화를 보고 기록하는 것을 좋아합니다.',
        textAlign: TextAlign.center, style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        ElevatedButton(
            onPressed: () {}, // 1주차에는 기능 연결하지 않음
            child: Text('프로필 수정', style: textTheme.labelLarge?.copyWith(color: AppColors.primary)),
        ),
      ],
    );
  }
}