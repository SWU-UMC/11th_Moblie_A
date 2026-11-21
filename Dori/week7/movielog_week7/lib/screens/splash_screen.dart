import 'package:flutter/material.dart';
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.message, this.onRetry});
  final String? message;
  final VoidCallback? onRetry;
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.movie_filter_outlined, size: 72), const SizedBox(height: 20),
    const Text('MovieLog · Week 7', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
    const SizedBox(height: 24),
    if (onRetry == null) const CircularProgressIndicator() else ...[
      Text(message ?? '로그인 상태를 확인하지 못했어요.'), const SizedBox(height: 12),
      FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
    ],
  ])));
}
