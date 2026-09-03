import 'package:go_router/go_router.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/copy/presentation/label_size.dart';
import 'package:khulla/features/catalog/copy/presentation/placeholder/label_queue_entry.dart';
import 'package:khulla/features/catalog/copy/presentation/placeholder/labels_placeholder.dart';
import 'package:khulla/features/catalog/copy/presentation/widgets/label_preview.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_placeholder.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The label desk: scan a copy, queue its sticker, print the sheet.
///
/// The scan field keeps focus and clears itself on submit, because a handheld
/// scanner is a keyboard that types a barcode and presses enter — anything
/// that steals focus between two scans turns a tray of new books into a
/// hunt-and-click job.
class LabelPrintPage extends StatefulWidget {
  const LabelPrintPage({super.key});

  @override
  State<LabelPrintPage> createState() => _LabelPrintPageState();
}

class _LabelPrintPageState extends State<LabelPrintPage> with DisposeBag {
  late final TextEditingController _scanController = textController();
  late final FocusNode _scanFocus = focusNode();

  late List<LabelQueueEntry> _queue = initialLabelQueue();
  LabelSize _size = LabelSize.medium;
  bool _includeTitle = true;
  bool _includeAuthor = true;
  bool _includeShelf = true;
  bool _includeLibrary = false;

  int get _labelCount => _queue.fold(0, (total, entry) => total + entry.count);

  /// Queues the copy whose barcode was scanned, or bumps its count when it is
  /// already in the queue — a second scan of the same book means a second
  /// sticker, not a duplicate row.
  void _queueBarcode(String raw) {
    final barcode = raw.trim();
    _scanController.clear();
    _scanFocus.requestFocus();
    if (barcode.isEmpty) return;

    final needle = barcode.toLowerCase();
    final match = placeholderCopies
        .where((copy) => copy.barcode.toLowerCase() == needle)
        .firstOrNull;
    if (match == null) {
      showNotWiredToast(context);
      return;
    }

    setState(() {
      final index = _queue.indexWhere((entry) => entry.copy.id == match.id);
      if (index == -1) {
        _queue = [..._queue, LabelQueueEntry(copy: match)];
      } else {
        _queue = [
          for (final (position, entry) in _queue.indexed)
            if (position == index) entry.withCount(entry.count + 1) else entry,
        ];
      }
    });
  }

  void _setCount(LabelQueueEntry entry, int count) => setState(() {
    _queue = [
      for (final queued in _queue)
        if (queued.copy.id == entry.copy.id)
          queued.withCount(count)
        else
          queued,
    ];
  });

  void _remove(LabelQueueEntry entry) => setState(() {
    _queue = [
      for (final queued in _queue)
        if (queued.copy.id != entry.copy.id) queued,
    ];
  });

  Widget _scanCard(AppLocalizations l10n) => SectionCard(
    title: l10n.labelsScanTitle,
    subtitle: l10n.labelsScanSubtitle,
    child: AppTextField(
      controller: _scanController,
      focusNode: _scanFocus,
      autofocus: true,
      hintText: l10n.labelsScanHint,
      prefixIcon: const Icon(Icons.barcode_reader),
      textInputAction: TextInputAction.done,
      onChanged: (_) {},
      onSubmitted: _queueBarcode,
    ),
  );

  Widget _queueCard(AppLocalizations l10n) {
    final colors = context.appColors;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: colors.textMuted,
    );

    return SectionCard(
      title: l10n.labelsQueueTitle,
      subtitle: l10n.labelsQueueSubtitle('$_labelCount'),
      trailing: _queue.isEmpty
          ? null
          : AppTextButton(
              onPressed: () => setState(() => _queue = const []),
              child: Text(l10n.labelsClearQueue),
            ),
      child: _queue.isEmpty
          ? AppEmptyView(
              icon: Icons.qr_code_2_rounded,
              title: l10n.labelsQueueEmptyTitle,
              message: l10n.labelsQueueEmptyBody,
              variant: AppFeedbackVariant.inline,
            )
          : AppTable<LabelQueueEntry>(
              items: _queue,
              rowHeight: 52,
              columns: [
                AppTableColumn<LabelQueueEntry>(
                  id: 'barcode',
                  label: l10n.labelsColumnBarcode,
                  flex: 2,
                  cellBuilder: (context, entry) => Text(entry.copy.barcode),
                ),
                AppTableColumn<LabelQueueEntry>(
                  id: 'title',
                  label: l10n.labelsColumnTitle,
                  flex: 4,
                  showFrom: FormFactor.medium,
                  cellBuilder: (context, entry) => Text(
                    entry.copy.titleName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppTableColumn<LabelQueueEntry>(
                  id: 'shelf',
                  label: l10n.labelsColumnShelf,
                  flex: 2,
                  showFrom: FormFactor.expanded,
                  cellBuilder: (context, entry) =>
                      Text(entry.copy.shelf, style: muted),
                ),
                AppTableColumn<LabelQueueEntry>(
                  id: 'count',
                  label: l10n.labelsColumnCopies,
                  width: 116,
                  alignment: Alignment.centerRight,
                  cellBuilder: (context, entry) => _CountStepper(
                    count: entry.count,
                    onChanged: (next) => _setCount(entry, next),
                  ),
                ),
                AppTableColumn<LabelQueueEntry>(
                  id: 'actions',
                  label: l10n.commonActions,
                  width: 56,
                  alignment: Alignment.centerRight,
                  cellBuilder: (context, entry) => AppIconButton(
                    icon: Icons.close_rounded,
                    tooltip: l10n.labelsRemove,
                    onPressed: () => _remove(entry),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _layoutCard(AppLocalizations l10n) {
    final spacing = context.appSpacing;

    return SectionCard(
      title: l10n.labelsLayoutTitle,
      subtitle: l10n.labelsLayoutSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDropdownField<LabelSize>(
            label: l10n.labelsSizeTitle,
            value: _size,
            items: LabelSize.values,
            itemLabel: (size) => size.label(l10n),
            onChanged: (size) => setState(() => _size = size ?? _size),
          ),
          SizedBox(height: spacing.md),
          AppCheckboxField(
            label: l10n.labelsIncludeTitle,
            value: _includeTitle,
            onChanged: (value) =>
                setState(() => _includeTitle = value ?? false),
          ),
          AppCheckboxField(
            label: l10n.labelsIncludeAuthor,
            value: _includeAuthor,
            onChanged: (value) =>
                setState(() => _includeAuthor = value ?? false),
          ),
          AppCheckboxField(
            label: l10n.labelsIncludeShelf,
            value: _includeShelf,
            onChanged: (value) =>
                setState(() => _includeShelf = value ?? false),
          ),
          AppCheckboxField(
            label: l10n.labelsIncludeLibrary,
            value: _includeLibrary,
            onChanged: (value) =>
                setState(() => _includeLibrary = value ?? false),
          ),
        ],
      ),
    );
  }

  Widget _previewCard(AppLocalizations l10n) {
    final spacing = context.appSpacing;
    final sample = _queue.isEmpty ? placeholderCopies.first : _queue.first.copy;
    final title = placeholderTitleById(sample.titleId);

    return SectionCard(
      title: l10n.labelsPreviewTitle,
      subtitle: l10n.labelsPreviewSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: LabelPreview(
              barcode: sample.barcode,
              width: _size.width,
              height: _size.height,
              title: _includeTitle ? sample.titleName : null,
              author: _includeAuthor ? title.author : null,
              shelf: _includeShelf ? sample.shelf : null,
              libraryName: _includeLibrary ? placeholderLabelLibrary : null,
            ),
          ),
          SizedBox(height: spacing.md),
          AppButton(
            icon: Icons.print_outlined,
            onPressed: _queue.isEmpty ? null : () => showNotWiredToast(context),
            child: Text(l10n.labelsPrint),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final sideBySide = context.formFactor.isAtLeast(FormFactor.expanded);

    final main = [_scanCard(l10n), _queueCard(l10n)];
    final side = [_layoutCard(l10n), _previewCard(l10n)];

    return AppPageBody(
      wide: true,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              spacing.page,
              spacing.lg,
              spacing.page,
              spacing.xlg,
            ),
            sliver: SliverList.list(
              children: [
                AppPageHeader(
                  title: l10n.labelsHeading,
                  onBackPressed: () => context.go(Routes.catalogCopies),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  l10n.labelsSubtitle,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.textMuted,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: spacing.lg),
                if (sideBySide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _Stack(gap: spacing.md, children: main),
                      ),
                      SizedBox(width: spacing.md),
                      SizedBox(
                        width: 360,
                        child: _Stack(gap: spacing.md, children: side),
                      ),
                    ],
                  )
                else
                  _Stack(gap: spacing.md, children: [...main, ...side]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A column of cards with one gap between them.
class _Stack extends StatelessWidget {
  const _Stack({required this.gap, required this.children});

  final double gap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final (index, child) in children.indexed) ...[
        if (index > 0) SizedBox(height: gap),
        child,
      ],
    ],
  );
}

/// How many stickers this copy gets: minus, the number, plus.
class _CountStepper extends StatelessWidget {
  const _CountStepper({required this.count, required this.onChanged});

  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconButton(
          icon: Icons.remove_rounded,
          tooltip: l10n.commonDecrease,
          onPressed: count <= 1 ? null : () => onChanged(count - 1),
        ),
        Text('$count', style: context.textTheme.bodyMedium),
        AppIconButton(
          icon: Icons.add_rounded,
          tooltip: l10n.commonIncrease,
          onPressed: () => onChanged(count + 1),
        ),
      ],
    );
  }
}
