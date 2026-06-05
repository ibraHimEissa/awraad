import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/book_data.dart';
import '../data/models.dart';
import '../state/book_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic.dart';
import 'app_snack.dart';
import 'ornamental_divider.dart';

/// Opens the notes sheet: write/save a personal note for the current page,
/// and browse / jump back to every saved note.
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
      value: context.read<BookController>(),
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
    final existing = context.read<BookController>().noteForPage(widget.page);
    _text = TextEditingController(text: existing?.text ?? '');
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _save() {
    final emptied = _text.text.trim().isEmpty;
    context.read<BookController>().saveNote(widget.page, _text.text);
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
    final printed = toArabicNumerals(BookData.toPrinted(widget.page));

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.86,
        ),
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
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _text,
              autofocus: false,
              maxLines: 5,
              minLines: 3,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: AppTheme.fontScripture,
                fontSize: 18,
                height: 1.8,
                color: AppColors.textPrimary,
              ),
              cursorColor: AppColors.gold,
              decoration: InputDecoration(
                hintText: 'اكتب دعاءك أو ملاحظتك هنا لتعود إليها لاحقًا…',
                hintStyle: const TextStyle(
                  fontFamily: AppTheme.fontUi,
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.background.withValues(alpha: 0.5),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.gold.withValues(alpha: 0.35),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.save_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'حفظ',
                      style: TextStyle(
                        fontFamily: AppTheme.fontUi,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Consumer<BookController>(
              builder: (context, c, _) {
                final notes = c.notes;
                if (notes.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
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
                          'صفحة ${toArabicNumerals(BookData.toPrinted(note.page))}',
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
                            note.sectionTitle,
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
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 19,
                  color: AppColors.danger.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
