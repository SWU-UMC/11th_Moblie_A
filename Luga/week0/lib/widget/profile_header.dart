import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        const CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage('assets/images/profile.png'),
            ),
        const SizedBox(width: 16),

        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '무비러버',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '좋아하는 영화를 기록하고 있어요',
                    style: textTheme.bodyMedium,
                  ),
                ],
            ),
        ),

        SvgPicture.asset(
          'assets/icons/bookmark.svg',
          width: 24,
          height: 24,
          ),
      ],
    );
  }
}