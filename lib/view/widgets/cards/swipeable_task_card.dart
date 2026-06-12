import 'package:flutter/material.dart';

import 'task_card.dart';

class SwipeableTaskCard extends StatelessWidget {
  final String dismissKey;
  final String title;
  final String subject;
  final String deadline;
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;
  final Future<bool> Function() onConfirmDelete;
  final VoidCallback onDismissed;

  const SwipeableTaskCard({
    super.key,
    required this.dismissKey,
    required this.title,
    required this.subject,
    required this.deadline,
    required this.onConfirmDelete,
    required this.onDismissed,
    this.isChecked = false,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(dismissKey),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onConfirmDelete(),
      onDismissed: (_) => onDismissed(),
      background: const _TaskDeleteBackground(),
      child: TaskCard(
        title: title,
        subject: subject,
        deadline: deadline,
        isChecked: isChecked,
        onChanged: onChanged,
        onTap: onTap,
      ),
    );
  }
}

class _TaskDeleteBackground extends StatelessWidget {
  const _TaskDeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8989),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66587DBD),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset(
        'lib/view/assets/image_discipline_trash.png',
        width: 28,
        height: 28,
        fit: BoxFit.contain,
      ),
    );
  }
}
