import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'widgets/common_app_bar.dart';
import 'widgets/stat_item.dart';

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
        centerTitle: false, // 제목을 왼쪽 정렬하기 위해 false 지정
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView( 
          // 추가 화면 내용이 세로로 길어져 기기 크기를 초과할 때 픽셀 깨짐 방지를 위해 스크롤 기능 추가
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 내부 위젯들을 왼쪽 기준으로 정렬
            children: [
              const SizedBox(height: 24), // 위젯 간의 수직 간격 조절
              
              // 프로필 이미지
              Center(
                child: const CircleAvatar(
                  radius: 52, 
                  backgroundColor: AppColors.gray,
                  backgroundImage: AssetImage('assets/images/profile_movielog.jpg'),
                ),
              ),
              const SizedBox(height: 16),

              // 닉네임 및 소개 글(가운데 정렬)
              Center(
                child: Column(
                  children: [
                    const Text('무비러버', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 8),
                    const Text(
                      '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은\n영화를 보고 기록하는 것을 좋아합니다.',
                      textAlign: TextAlign.center, // 텍스트 문단 가운데 정렬
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 프로필 수정 버튼
              Center(
                child: ElevatedButton( // 버튼 수정
                  onPressed: () {}, // 클릭 기능은 비워둠
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

              // 통계 카드 3개(본 영화, 평점, 즐겨찾기)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: stats.map((stat) {
                  return Expanded(
                    //추가 Row 안에서 각 카드가 남은 가로 공간을 유연하게 나누어 갖도록 Expanded 사용
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

              // 선호하는 장르
              const Text('선호하는 장르', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: genres.map((genre) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      //label: Text(genre, style: AppTextStyles.bodySmall),
                      label: Text(
                      genre, 
                      style: AppTextStyles.bodySmall.copyWith(
                        //color: Theme.of(context).colorScheme.primary, // 보라색으로 텍스트 색상 변경
                        color: AppColors.violet,
                      ),
                    ),
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2), // 배경색을 연한 보라색으로 변경
                      //backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)), // 테두리 색상을 연한 보라색으로 변경
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