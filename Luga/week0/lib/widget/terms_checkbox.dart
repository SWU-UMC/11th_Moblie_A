import 'package:flutter/material.dart';

class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
        maxAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            Checkbox(value: value, onChanged: onChanged),
            const Expanded(
                child: Text('(필수) 이용약관 및 개인정보 처리방침에 동의합니다.'),
            ),
        ],
    );
  }
}