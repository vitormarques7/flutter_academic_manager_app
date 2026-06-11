import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../models/subject_note.dart';
import '../widgets/common/metadata_chip.dart';

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
  bool _isDeleting = false;

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir anotação?'),
          content: Text('Isso removerá "${widget.note.title}".'),
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
      await widget.onDelete(widget.note);
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

  @override
  Widget build(BuildContext context) {
    final disciplineLabel = widget.note.disciplineName.isEmpty
        ? 'Sem disciplina'
        : widget.note.disciplineName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _NoteDetailsHeader(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _NoteHeroCard(
                      title: widget.note.title,
                      disciplineName: disciplineLabel,
                      accentColor: widget.accentColor,
                    ),
                    const SizedBox(height: 24),
                    _NoteInfoSection(
                      title: 'Anotação',
                      icon: Icons.notes_outlined,
                      accentColor: widget.accentColor,
                      child: Text(
                        widget.note.content.isEmpty
                            ? 'Nenhum conteúdo cadastrado para esta anotação.'
                            : widget.note.content,
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
                    _NoteInfoSection(
                      title: 'Detalhes',
                      icon: Icons.info_outline,
                      accentColor: widget.accentColor,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
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
                            : const Text('Excluir anotação'),
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

class _NoteDetailsHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _NoteDetailsHeader({required this.onBack});

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
              'Detalhes da anotação',
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

class _NoteHeroCard extends StatelessWidget {
  final String title;
  final String disciplineName;
  final Color accentColor;

  const _NoteHeroCard({
    required this.title,
    required this.disciplineName,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E4F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22587DBD),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NoteIconTile(
            icon: Icons.sticky_note_2_outlined,
            color: accentColor,
            size: 58,
          ),
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
                MetadataChip(
                  icon: Icons.menu_book_outlined,
                  label: disciplineName,
                  maxWidth: 230,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteInfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final Widget child;

  const _NoteInfoSection({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E4F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _NoteIconTile(icon: icon, color: accentColor, size: 38),
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

class _NoteIconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _NoteIconTile({
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
