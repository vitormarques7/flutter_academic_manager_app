import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_design_tokens.dart';
import '../../models/subject_event.dart';
import '../widgets/common/app_surface.dart';
import '../widgets/common/metadata_chip.dart';

class SubjectEventDetailsPage extends StatefulWidget {
  final SubjectEvent event;
  final Color accentColor;
  final Future<void> Function(SubjectEvent event) onDelete;

  const SubjectEventDetailsPage({
    super.key,
    required this.event,
    required this.accentColor,
    required this.onDelete,
  });

  @override
  State<SubjectEventDetailsPage> createState() =>
      _SubjectEventDetailsPageState();
}

class _SubjectEventDetailsPageState extends State<SubjectEventDetailsPage> {
  bool _isDeleting = false;

  IconData get _eventIcon {
    return switch (widget.event.type) {
      SubjectEventType.exam => Icons.edit_square,
      SubjectEventType.lecture => Icons.record_voice_over_outlined,
      SubjectEventType.seminar => Icons.co_present_outlined,
      SubjectEventType.deadline => Icons.assignment_turned_in_outlined,
      SubjectEventType.extraClass => Icons.school_outlined,
      SubjectEventType.other => Icons.event_note_outlined,
    };
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir evento?'),
          content: Text('Isso removerá "${widget.event.title}".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      await widget.onDelete(widget.event);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento excluído.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final disciplineLabel = widget.event.disciplineName.isEmpty
        ? 'Sem disciplina'
        : widget.event.disciplineName;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _EventDetailsHeader(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EventHeroCard(
                      title: widget.event.title,
                      disciplineName: disciplineLabel,
                      typeLabel: widget.event.type.label,
                      dateLabel: widget.event.displayDateLabel,
                      icon: _eventIcon,
                      accentColor: widget.accentColor,
                    ),
                    const SizedBox(height: 24),
                    _EventInfoSection(
                      title: 'Descrição',
                      icon: Icons.notes_outlined,
                      accentColor: widget.accentColor,
                      child: Text(
                        widget.event.description.isEmpty
                            ? 'Nenhuma descrição cadastrada para este evento.'
                            : widget.event.description,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _EventInfoSection(
                      title: 'Detalhes',
                      icon: Icons.info_outline,
                      accentColor: widget.accentColor,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          MetadataChip(
                            icon: Icons.calendar_today_outlined,
                            label: widget.event.displayDateLabel,
                            maxWidth: 170,
                          ),
                          MetadataChip(
                            icon: _eventIcon,
                            label: widget.event.type.label,
                            maxWidth: 170,
                          ),
                          MetadataChip(
                            icon: Icons.menu_book_outlined,
                            label: disciplineLabel,
                            maxWidth: 260,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: _isDeleting ? null : _confirmDelete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: _isDeleting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.red.shade700,
                                ),
                              )
                            : const Text('Excluir evento'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventDetailsHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _EventDetailsHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE4E4FF), width: 1)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Voltar',
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark,
              size: 28,
            ),
          ),
          const Expanded(
            child: Text(
              'Detalhes do evento',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 25,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(width: 18),
        ],
      ),
    );
  }
}

class _EventHeroCard extends StatelessWidget {
  final String title;
  final String disciplineName;
  final String typeLabel;
  final String dateLabel;
  final IconData icon;
  final Color accentColor;

  const _EventHeroCard({
    required this.title,
    required this.disciplineName,
    required this.typeLabel,
    required this.dateLabel,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(16),
      gradient: AppGradients.softSurface,
      border: Border.all(color: AppColors.outline),
      shadows: AppShadows.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EventIconTile(icon: icon, color: accentColor, size: 58),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    MetadataChip(
                      icon: Icons.calendar_today_outlined,
                      label: dateLabel,
                      maxWidth: 160,
                    ),
                    MetadataChip(icon: icon, label: typeLabel, maxWidth: 160),
                    if (disciplineName.isNotEmpty)
                      MetadataChip(
                        icon: Icons.menu_book_outlined,
                        label: disciplineName,
                        maxWidth: 230,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventInfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final Widget child;

  const _EventInfoSection({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface.card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _EventIconTile(icon: icon, color: accentColor, size: 38),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _EventIconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _EventIconTile({
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Icon(icon, color: color, size: size * 0.50),
    );
  }
}
