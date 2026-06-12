import 'package:flutter/material.dart';

import 'subject_card.dart';

class SwipeableSubjectCard extends StatelessWidget {
  final String dismissKey;
  final String name;
  final String teacher;
  final double frequency;
  final double average;
  final VoidCallback? onTap;
  final Future<bool> Function() onConfirmDelete;
  final VoidCallback onDismissed;

  const SwipeableSubjectCard({
    super.key,
    required this.dismissKey,
    required this.name,
    required this.teacher,
    required this.frequency,
    required this.average,
    required this.onConfirmDelete,
    required this.onDismissed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(dismissKey),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onConfirmDelete(),
      onDismissed: (_) => onDismissed(),
      background: const _SubjectDeleteBackground(),
      child: SubjectCard(
        name: name,
        teacher: teacher,
        frequency: frequency,
        average: average,
        onTap: onTap,
      ),
    );
  }
}

class _SubjectDeleteBackground extends StatelessWidget {
  const _SubjectDeleteBackground();

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
