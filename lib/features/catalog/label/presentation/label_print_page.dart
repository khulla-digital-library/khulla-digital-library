import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/feedback/app_toast.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/features/catalog/label/domain/models/label_queue_entry.dart';
import 'package:khulla/features/catalog/label/domain/models/label_size.dart';
import 'package:khulla/features/catalog/label/presentation/cubit/label_cubit.dart';
import 'package:khulla/features/catalog/label/presentation/cubit/label_state.dart';
import 'package:khulla/features/catalog/label/presentation/label_labels.dart';
import 'package:khulla/features/catalog/label/presentation/widgets/label_bulk_queue_dialog.dart';
import 'package:khulla/features/catalog/label/presentation/widgets/label_preview.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla/shared/utils/app_exception_l10n.dart';
import 'package:khulla/shared/widgets/error_retry_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The label desk: scan a copy, queue its sticker, print the sheet.
///
/// The scan field keeps focus and clears itself on submit, because a handheld
/// scanner is a keyboard that types a barcode and presses enter — anything
/// that steals focus between two scans turns a tray of new books into a
/// hunt-and-click job.
///
/// [LabelCubit] owns the queue and the layout; a scan that matches nothing
/// answers as a toast, not as a screen state.
class LabelPrintPage extends StatefulWidget {
  const LabelPrintPage({super.key});

  @override
  State<LabelPrintPage> createState() => _LabelPrintPageState();
}

class _LabelPrintPageState extends State<LabelPrintPage> with DisposeBag {
  late final TextEditingController _scanController = textController();
  late final FocusNode _scanFocus = focusNode();

  Future<void> _queueBarcode(String raw) async {
    final cubit = context.read<LabelCubit>();
    final l10n = context.l10n;
    try {
      await cubit.queueBarcode(raw);
      if (!mounted) return;
      _scanController.clear();
      _scanFocus.requestFocus();
    } on AppException catch (error) {
      if (!mounted) return;
      _scanController.clear();
      _scanFocus.requestFocus();
      AppToast.error(context, message: error.localizedMessage(l10n));
    }
  }

  Future<void> _printSheet() async {
    final cubit = context.read<LabelCubit>();
    final l10n = context.l10n;
    final count = cubit.state.labelCount;
    try {
      final printed = await cubit.printSheet();
      if (!mounted || !printed) return;
      AppToast.success(
        context,
        message: l10n.labelsPrintSuccess('$count'),
      );
    } on AppException catch (error) {
      if (!mounted) return;
      AppToast.error(context, message: error.localizedMessage(l10n));
    }
  }

  Future<void> _bulkQueue() async {
    final l10n = context.l10n;
    final result = await LabelBulkQueueDialog.show(context);
    if (result == null || !mounted) return;
    _scanFocus.requestFocus();
    if (result.isComplete) {
      if (result.queuedCount == 0) return;
      AppToast.success(
        context,
        message: l10n.labelsBulkAllQueued('${result.queuedCount}'),
      );
    } else {
      AppToast.warning(
        context,
        message: l10n.labelsBulkPartial(
          '${result.queuedCount}',
          '${result.notFound.length}',
        ),
      );
    }
  }

  Widget _scanCard(AppLocalizations l10n) => SectionCard(
    title: l10n.labelsScanTitle,
    subtitle: l10n.labelsScanSubtitle,
    trailing: AppTextButton(
      icon: AppIcons.bulkEntry,
      onPressed: () => unawaited(_bulkQueue()),
      child: Text(l10n.labelsBulkAction),
    ),
    child: AppTextField(
      controller: _scanController,
      focusNode: _scanFocus,
      autofocus: true,
      hintText: l10n.labelsScanHint,
      prefixIcon: const AppIcon(AppIcons.barcode),
      textInputAction: TextInputAction.done,
      onChanged: (_) {},
      onSubmitted: (value) => unawaited(_queueBarcode(value)),
    ),
  );

  Widget _queueCard(AppLocalizations l10n, LabelState state) {
    final cubit = context.read<LabelCubit>();
    final colors = context.appColors;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: colors.textMuted,
    );

    return SectionCard(
      title: l10n.labelsQueueTitle,
      subtitle: l10n.labelsQueueSubtitle('${state.labelCount}'),
      trailing: state.queue.isEmpty
          ? null
          : AppTextButton(
              onPressed: cubit.clearQueue,
              child: Text(l10n.labelsClearQueue),
            ),
      child: state.queue.isEmpty
          ? AppEmptyView(
              icon: AppIcons.qrCode,
              title: l10n.labelsQueueEmptyTitle,
              message: l10n.labelsQueueEmptyBody,
              variant: AppFeedbackVariant.inline,
            )
          : AppTable<LabelQueueEntry>(
              items: state.queue,
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
                  flex: 3,
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
                  flex: 3,
                  cellBuilder: (context, entry) => _CountStepper(
                    count: entry.count,
                    onChanged: (next) => cubit.setEntryCount(entry, next),
                  ),
                ),
                AppTableColumn<LabelQueueEntry>(
                  id: 'actions',
                  label: l10n.commonActions,
                  cellBuilder: (context, entry) => AppIconButton(
                    icon: AppIcons.close,
                    tooltip: l10n.labelsRemove,
                    size: AppIconButtonSize.small,
                    onPressed: () => cubit.removeEntry(entry),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _layoutCard(AppLocalizations l10n, LabelState state) {
    final cubit = context.read<LabelCubit>();
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
            value: state.size,
            items: LabelSize.values,
            itemLabel: (size) => size.label(l10n),
            onChanged: (size) {
              if (size != null) cubit.sizeChanged(size);
            },
          ),
          SizedBox(height: spacing.md),
          AppCheckboxField(
            label: l10n.labelsIncludeTitle,
            value: state.includeTitle,
            onChanged: (value) => cubit.includeTitleChanged(value ?? false),
          ),
          AppCheckboxField(
            label: l10n.labelsIncludeAuthor,
            value: state.includeAuthor,
            onChanged: (value) => cubit.includeAuthorChanged(value ?? false),
          ),
          AppCheckboxField(
            label: l10n.labelsIncludeShelf,
            value: state.includeShelf,
            onChanged: (value) => cubit.includeShelfChanged(value ?? false),
          ),
          AppCheckboxField(
            label: l10n.labelsIncludeLibrary,
            value: state.includeLibrary,
            onChanged: (value) => cubit.includeLibraryChanged(value ?? false),
          ),
        ],
      ),
    );
  }

  Widget _previewCard(AppLocalizations l10n, LabelState state) {
    final spacing = context.appSpacing;

    return SectionCard(
      title: l10n.labelsPreviewTitle,
      subtitle: l10n.labelsPreviewSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.queue.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.lg),
              child: Center(
                child: Text(
                  l10n.labelsPreviewEmpty,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.appColors.textMuted,
                  ),
                ),
              ),
            )
          else
            Center(
              child: Builder(
                builder: (context) {
                  final entry = state.queue.first;
                  return LabelPreview(
                    barcode: entry.copy.barcode,
                    width: state.size.width,
                    height: state.size.height,
                    title: state.includeTitle ? entry.copy.titleName : null,
                    author: state.includeAuthor ? entry.author : null,
                    shelf: state.includeShelf ? entry.copy.shelf : null,
                    libraryName: state.includeLibrary
                        ? state.libraryName
                        : null,
                  );
                },
              ),
            ),
          SizedBox(height: spacing.md),
          AppButton(
            icon: AppIcons.printer,
            onPressed: state.queue.isEmpty || state.isPrinting
                ? null
                : () => unawaited(_printSheet()),
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
    final cubit = context.read<LabelCubit>();
    final sideBySide = context.formFactor.isAtLeast(FormFactor.expanded);

    return BlocBuilder<LabelCubit, LabelState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: AppSpinner());
        }
        if (state.hasError) {
          return ErrorRetryView(
            error: state.error,
            onRetry: cubit.loadLabelDesk,
          );
        }

        final main = [_scanCard(l10n), _queueCard(l10n, state)];
        final side = [_layoutCard(l10n, state), _previewCard(l10n, state)];

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
      },
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
          icon: AppIcons.remove,
          tooltip: l10n.commonDecrease,
          size: AppIconButtonSize.small,
          onPressed: count <= 1 ? null : () => onChanged(count - 1),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium,
          ),
        ),
        AppIconButton(
          icon: AppIcons.add,
          tooltip: l10n.commonIncrease,
          size: AppIconButtonSize.small,
          onPressed: () => onChanged(count + 1),
        ),
      ],
    );
  }
}
