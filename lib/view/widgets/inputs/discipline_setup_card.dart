import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../buttons/discipline_delete_button.dart';

class DisciplineSetupCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isConfirmed;
  final VoidCallback onConfirm;
  final VoidCallback onDelete;

  const DisciplineSetupCard({
    super.key,
    required this.controller,
    required this.isConfirmed,
    required this.onConfirm,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isConfirmed ? 58 : 112,
      padding: isConfirmed
          ? const EdgeInsets.fromLTRB(18, 11, 10, 12)
          : const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowPrimary,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: isConfirmed ? _buildConfirmedContent() : _buildActiveContent(),
    );
  }

  Widget _buildConfirmedContent() {
    return Row(
      children: [
        Expanded(
          child: _DisciplineNameField(
            controller: controller,
            textPadding: const EdgeInsets.symmetric(horizontal: 24),
            textHeight: 1,
          ),
        ),
        const SizedBox(width: 10),
        _ReactiveDisciplineDeleteButton(
          controller: controller,
          onPressed: onDelete,
          buttonSize: 34,
        ),
      ],
    );
  }

  Widget _buildActiveContent() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: _DisciplineNameField(controller: controller),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: _ReactiveConfirmButton(
              controller: controller,
              onPressed: onConfirm,
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: -8,
          child: _ReactiveDisciplineDeleteButton(
            controller: controller,
            onPressed: onDelete,
            buttonSize: 38,
          ),
        ),
      ],
    );
  }
}

class _ReactiveConfirmButton extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPressed;

  const _ReactiveConfirmButton({
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.trim().isNotEmpty;

        return SizedBox(
          width: 149,
          height: 24,
          child: Opacity(
            opacity: hasText ? 1 : 0.45,
            child: TextButton(
              onPressed: hasText ? onPressed : null,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white,
                disabledForegroundColor: Colors.black,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Ok',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReactiveDisciplineDeleteButton extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPressed;
  final double buttonSize;

  const _ReactiveDisciplineDeleteButton({
    required this.controller,
    required this.onPressed,
    required this.buttonSize,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.trim().isNotEmpty;

        return DisciplineDeleteButton(
          onPressed: hasText ? onPressed : null,
          color: Colors.white,
          buttonSize: buttonSize,
          opacity: hasText ? 1 : 0.45,
        );
      },
    );
  }
}

class _DisciplineNameField extends StatelessWidget {
  final TextEditingController controller;
  final EdgeInsets textPadding;
  final double? textHeight;

  const _DisciplineNameField({
    required this.controller,
    this.textPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
    this.textHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextFormField(
        controller: controller,
        cursorColor: Colors.white,
        textAlignVertical: TextAlignVertical.center,
        style: AppTextStyles.bodyRegular.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          height: textHeight,
        ),
        decoration: InputDecoration(
          hintText: 'Digite o nome da disciplina',
          hintStyle: AppTextStyles.bodyRegular.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
            fontWeight: FontWeight.w500,
            height: textHeight,
          ),
          filled: true,
          fillColor: const Color(0xFF7B79BF),
          contentPadding: textPadding,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0x7FE0E0E0), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xBFE0E0E0), width: 2),
          ),
        ),
      ),
    );
  }
}
