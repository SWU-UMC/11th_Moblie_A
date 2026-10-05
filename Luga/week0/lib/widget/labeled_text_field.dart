import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.validator,
    this.focusNode,
    this.nextFocusNode,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? Function(String?) validator;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        final hasError = field.hasError;
        final isFilled = controller.text.isNotEmpty;
        final isValid = isFilled && !hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labelText,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              onChanged: (value) {
                field.didChange(value);
                onChanged?.call(value);
              },
              onSubmitted: (_) {
                if (nextFocusNode != null) {
                  FocusScope.of(context).requestFocus(nextFocusNode);
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(fontSize: 14),
                isDense: false,
                filled: true,
                fillColor: hasError
                    ? AppColors.errorBackground
                    : AppColors.surfaceContainer,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: hasError
                    ? const Icon(Icons.error, color: AppColors.error)
                    : (isValid
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : null),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: hasError
                      ? const BorderSide(color: AppColors.error, width: 1.2)
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? AppColors.error : AppColors.primary,
                    width: 1.4,
                  ),
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  field.errorText ?? '',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.error, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}