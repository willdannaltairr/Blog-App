import 'package:flutter/material.dart';
import 'theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final String? label;
  final bool obscure;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool light;
  final bool readOnly;

  const AppTextField({
    super.key,
    required this.controller,
    this.hint,
    this.label,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.suffix,
    this.validator,
    this.onChanged,
    this.light = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = light ? AppColors.accentFg : AppColors.textPrimary;
    Color borderColor =
        light ? AppColors.inputFillLight : AppColors.surfaceBorder;
    Color focusColor = light ? AppColors.accentFg : AppColors.accent;
    Color errorColor = light ? AppColors.background : AppColors.danger;

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          readOnly: readOnly,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            filled: true,
            fillColor: light ? AppColors.inputFillLight : AppColors.inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            errorStyle: TextStyle(color: errorColor, fontSize: 12),
            border: border(borderColor),
            enabledBorder: border(borderColor),
            focusedBorder: border(focusColor, 1.2),
            errorBorder: border(errorColor),
            focusedErrorBorder: border(errorColor, 1.2),
          ),
        ),
      ],
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String message;

  const EmptyView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 44,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

class FormErrorBanner extends StatelessWidget {
  final String message;
  final bool light;

  const FormErrorBanner({super.key, required this.message, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: light ? AppColors.inputFillLight : AppColors.surface,
        border: Border.all(
          color: light ? AppColors.background : AppColors.danger,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: light ? AppColors.background : AppColors.danger,
          fontSize: 13,
        ),
      ),
    );
  }
}
