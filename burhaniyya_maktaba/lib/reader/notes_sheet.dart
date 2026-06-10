import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/arabic.dart';
import '../model/models.dart';
import '../widgets/app_snack.dart';
import '../widgets/ornamental_divider.dart';
import 'reader_controller.dart';

/// Write / browse personal notes for the current book. Notes are per-book.
Future<void> showNotesSheet(
  BuildContext context, {
  required int page,
  required ValueChanged<int> onSelectPage,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<ReaderController>(),
      child: _NotesSheet(page: page, onSelectPage: onSelectPage),
    ),
  );
}

class _NotesSheet extends StatefulWidget {
  const _NotesSheet({required this.page, required this.onSelectPage});
  final int page;
  final ValueChanged<int> onSelectPage;

  @override
  State<_NotesSheet> createState() => _NotesSheetState();
}

class _NotesSheetState extends State<_NotesSheet> {
  late final TextEditingController _text;

  @override
  void initState() {
    super.initState();
    final existing = context.read<ReaderController>().noteForPage(widget.page);
    _text = TextEditingController(text: existing?.text ?? '');
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _save() {
    final emptied = _text.text.trim().isEmpty;
    context.read<ReaderController>().saveNote(widget.page, _text.text);
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
    showAppSnack(
      context,
      emptied ? 'تم حذف الملاحظة' : 'تم حفظ الملاحظة',
      icon: emptied ? Icons.delete_outline_rounded : Icons.check_circle_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final book = context.read<ReaderController>().book;
    final printed = toArabicNumerals(book.toPrinted(widget.page));

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Text(
                    'ملاحظة على صفحة $printed',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontUi,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _text,
                maxLines: 5,
                minLines: 3,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                cursorColor: AppColors.gold,
                style: const TextStyle(
                  fontFamily: AppTheme.fontScripture,
                  fontSize: 18,
                  height: 1.8,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'اكتب ملاحظتك هنا لتعود إليها لاحقًا…',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('حفظ'),
                ),
              ),
              const SizedBox(height: 14),
              Consumer<ReaderController>(
                builder: (context, c, _) {
                  final notes = c.notes;
                  if (notes.isEmpty) return const SizedBox.shrink();
                  return Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const OrnamentalDivider(),
                      const SizedBox(height: 8),
                      const Text(
                        'كل الملاحظات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontUi,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: notes.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) => _NoteTile(
                            book: c.book,
                            note: notes[i],
                            onTap: () {
                              Navigator.pop(context);
                              widget.onSelectPage(notes[i].page);
                            },
                            onDelete: () => c.deleteNote(notes[i].page),
                          ),
                        ),
                      ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    required this.book,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final dynamic book;
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppTheme.rSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.rSm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'صفحة ${toArabicNumerals(book.toPrinted(note.page))}',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontUi,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note.label,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppTheme.fontUi,
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontScripture,
                        fontSize: 15,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded,
                    size: 19, color: AppColors.danger.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
