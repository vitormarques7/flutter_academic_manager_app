import 'package:flutter/material.dart';

import '../../config/theme/app_theme_colors.dart';
import '../../models/subject_note.dart';
import '../../repositories/subject_note_repository.dart';
import 'subject_details_page.dart';

class SubjectNoteDetailsPage extends StatefulWidget {
  final SubjectNote note;
  final Color accentColor;
  final Future<void> Function(SubjectNote note) onDelete;

  const SubjectNoteDetailsPage({
    super.key,
    required this.note,
    required this.accentColor,
    required this.onDelete,
  });

  @override
  State<SubjectNoteDetailsPage> createState() => _SubjectNoteDetailsPageState();
}

class _SubjectNoteDetailsPageState extends State<SubjectNoteDetailsPage> {
  late SubjectNote _currentNote;
  bool _isDeleting = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/${dt.year} às $hour:$minute';
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir anotação?'),
          content: Text('Isso removerá "${_currentNote.title}".'),
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
      await widget.onDelete(_currentNote);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anotação excluída.'),
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
    final result = await showDialog<SubjectNoteDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => SubjectNoteDialog(initialNote: _currentNote),
    );

    if (result == null || !mounted) return;

    setState(() => _isSaving = true);

    try {
      final input = SubjectNoteInput(
        studyCycleId: _currentNote.studyCycleId,
        disciplineId: _currentNote.disciplineId,
        disciplineName: _currentNote.disciplineName,
        title: result.title,
        content: result.content,
      );

      await SubjectNoteRepository().updateNote(
        id: _currentNote.id,
        input: input,
      );

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _currentNote = SubjectNote(
          id: _currentNote.id,
          studyCycleId: _currentNote.studyCycleId,
          disciplineId: _currentNote.disciplineId,
          disciplineName: _currentNote.disciplineName,
          title: result.title,
          content: result.content,
          createdAt: _currentNote.createdAt,
          updatedAt: DateTime.now(),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anotação atualizada com sucesso.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível salvar a anotação: ${error.toString()}'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final disciplineLabel = _currentNote.disciplineName.isEmpty
        ? 'Sem disciplina'
        : _currentNote.disciplineName;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: widget.accentColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Anotação',
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
            tooltip: 'Editar anotação',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.accentColor,
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sticky_note_2_outlined, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            const Text(
                              'ANOTAÇÃO',
                              style: TextStyle(
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
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _currentNote.title,
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
            Expanded(
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
                              Icon(Icons.notes_rounded, color: widget.accentColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Conteúdo',
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
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: widget.accentColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    _currentNote.content.isEmpty
                                        ? 'Nenhum conteúdo cadastrado para esta anotação.'
                                        : _currentNote.content,
                                    style: TextStyle(
                                      color: _currentNote.content.isEmpty
                                          ? colors.textMuted
                                          : colors.textDark,
                                      fontSize: 15,
                                      fontFamily: 'Roboto',
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_currentNote.createdAt != null || _currentNote.updatedAt != null) ...[
                            const SizedBox(height: 20),
                            Divider(color: colors.divider, height: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.access_time_rounded, color: colors.textSubtle, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _currentNote.updatedAt != null
                                      ? 'Atualizada em ${_formatDateTime(_currentNote.updatedAt!)}'
                                      : 'Criada em ${_formatDateTime(_currentNote.createdAt!)}',
                                  style: TextStyle(
                                    color: colors.textSubtle,
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                              Icon(Icons.info_outline_rounded, color: widget.accentColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Informações',
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
                            icon: Icons.menu_book_rounded,
                            title: 'Disciplina',
                            value: disciplineLabel,
                            iconColor: widget.accentColor,
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
                        onPressed: _isDeleting || _isSaving ? null : _confirmDelete,
                        tooltip: 'Excluir anotação',
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
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
