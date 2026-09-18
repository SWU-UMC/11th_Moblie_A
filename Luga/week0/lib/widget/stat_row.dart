import 'package:flutter/material.dart';
import 'stat_item.dart';

class StatRow extends StatelessWidget {
  const StatRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const[
        Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: StatItem(label: '본 영화', value: '342'),
            ),
        ),
        Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: StatItem(label: '평점', value: '4.2'),
            ),
        ),
        Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: StatItem(label: '즐겨찾기', value: '58'),
            ),
        ),
      ],
    );
  }
}