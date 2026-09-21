import 'package:flutter/material.dart';

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
        return TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
            ),
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: (_) {
                if (nextFocusNode != null) {
                    FocusScope.of(context).requestFocus(nextFocusNode);
                } else {
                    FocusScope.of(context).unfocus();
                }
            },
        )
    }
}