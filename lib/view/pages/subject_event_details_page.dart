import 'package:flutter/material.dart';

import '../../config/theme/app_theme_colors.dart';
import '../../models/subject_event.dart';
import '../../repositories/subject_event_repository.dart';
import 'subject_details_page.dart';

Color _darkModeDetailsAccent(BuildContext context, Color accentColor) {
  if (Theme.of(context).brightness != Brightness.dark) return accentColor;

  final hsl = HSLColor.fromColor(accentColor);
  final lightness = hsl.lightness > 0.48 ? 0.48 : hsl.lightness;
  final saturation = hsl.saturation > 0.72 ? 0.72 : hsl.saturation;

  return hsl.withLightness(lightness).withSaturation(saturation).toColor();
}

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
  late SubjectEvent _currentEvent;
  bool _isDeleting = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
  }

  IconData get _eventIcon {
    return switch (_currentEvent.type) {
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
          content: Text('Isso removerá "${_currentEvent.title}".'),
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
      await widget.onDelete(_currentEvent);
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

  Future<void> _openEditDialog() async {
    final result = await showDialog<SubjectEventDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => SubjectEventDialog(initialEvent: _currentEvent),
    );

    if (result == null || !mounted) return;

    setState(() => _isSaving = true);

    try {
      final input = SubjectEventInput(
        studyCycleId: _currentEvent.studyCycleId,
        disciplineId: _currentEvent.disciplineId,
        disciplineName: _currentEvent.disciplineName,
        title: result.title,
        type: result.type,
        eventDate: result.eventDate,
        startTimeMinutes: result.startTimeMinutes,
        endTimeMinutes: result.endTimeMinutes,
        description: result.description,
      );

      await SubjectEventRepository().updateEvent(
        id: _currentEvent.id,
        input: input,
      );

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _currentEvent = SubjectEvent(
          id: _currentEvent.id,
          studyCycleId: _currentEvent.studyCycleId,
          disciplineId: _currentEvent.disciplineId,
          disciplineName: _currentEvent.disciplineName,
          title: result.title,
          type: result.type,
          eventDate: result.eventDate,
          startTimeMinutes: result.startTimeMinutes,
          endTimeMinutes: result.endTimeMinutes,
          description: result.description,
          createdAt: _currentEvent.createdAt,
          updatedAt: DateTime.now(),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento atualizado com sucesso.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível salvar o evento: ${error.toString()}',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accentColor = _darkModeDetailsAccent(context, widget.accentColor);
    final disciplineLabel = _currentEvent.disciplineName.isEmpty
        ? 'Sem disciplina'
        : _currentEvent.disciplineName;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: accentColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Evento',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: _isDeleting || _isSaving ? null : _openEditDialog,
            tooltip: 'Editar evento',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _EntranceSlideFade(
              beginOffset: const Offset(0, -28),
              fade: false,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: colors.subtleShadows,
                ),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_eventIcon, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                _currentEvent.type.label.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (_currentEvent.isUpcoming)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Pendente',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 11,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _currentEvent.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      disciplineLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _EntranceSlideFade(
                beginOffset: const Offset(0, 32),
                start: 0.14,
                duration: const Duration(milliseconds: 880),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: colors.outline),
                          boxShadow: colors.subtleShadows,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  color: accentColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Descrição',
                                  style: TextStyle(
                                    color: colors.textDark,
                                    fontSize: 16,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _currentEvent.description.isEmpty
                                  ? 'Nenhuma descrição cadastrada para este evento.'
                                  : _currentEvent.description,
                              style: TextStyle(
                                color: _currentEvent.description.isEmpty
                                    ? colors.textMuted
                                    : colors.textMedium,
                                fontSize: 15,
                                fontFamily: 'Roboto',
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: colors.outline),
                          boxShadow: colors.subtleShadows,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: accentColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Detalhes do Evento',
                                  style: TextStyle(
                                    color: colors.textDark,
                                    fontSize: 16,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _DetailRow(
                              icon: Icons.calendar_today_rounded,
                              title: 'Data',
                              value: _currentEvent.displayDateLabel,
                              iconColor: accentColor,
                            ),
                            Divider(height: 24, color: colors.divider),
                            _DetailRow(
                              icon: Icons.schedule_rounded,
                              title: 'Horário',
                              value: _currentEvent.timeRangeLabel,
                              iconColor: accentColor,
                            ),
                            Divider(height: 24, color: colors.divider),
                            _DetailRow(
                              icon: _eventIcon,
                              title: 'Tipo de Evento',
                              value: _currentEvent.type.label,
                              iconColor: accentColor,
                            ),
                            Divider(height: 24, color: colors.divider),
                            _DetailRow(
                              icon: Icons.menu_book_rounded,
                              title: 'Disciplina',
                              value: disciplineLabel,
                              iconColor: accentColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: IconButton(
                          icon: _isDeleting
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.textSubtle,
                                  ),
                                )
                              : Icon(
                                  Icons.delete_outline_rounded,
                                  color: colors.textSubtle,
                                  size: 28,
                                ),
                          onPressed: _isDeleting || _isSaving
                              ? null
                              : _confirmDelete,
                          tooltip: 'Excluir evento',
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntranceSlideFade extends StatelessWidget {
  final Widget child;
  final Offset beginOffset;
  final Duration duration;
  final double start;
  final bool fade;

  const _EntranceSlideFade({
    required this.child,
    required this.beginOffset,
    this.duration = const Duration(milliseconds: 760),
    this.start = 0,
    this.fade = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.linear,
      builder: (context, value, child) {
        final progress = Interval(
          start,
          1,
          curve: Curves.easeOutQuart,
        ).transform(value);

        final translatedChild = Transform.translate(
          offset: Offset.lerp(beginOffset, Offset.zero, progress)!,
          child: child,
        );

        if (!fade) return translatedChild;

        return Opacity(opacity: progress, child: translatedChild);
      },
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.textSubtle,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: colors.textDark,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
