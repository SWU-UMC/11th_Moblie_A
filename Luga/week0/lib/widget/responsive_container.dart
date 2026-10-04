import 'package:flutter/material.dart';

/// 화면이 넓어져도 콘텐츠가 전체 폭을 채우지 않고
/// maxWidth 기준으로 가운데 정렬되도록 감싸는 위젯
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 480,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 700 ? maxWidth : double.infinity;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: child,
          ),
        );
      },
    );
  }
}