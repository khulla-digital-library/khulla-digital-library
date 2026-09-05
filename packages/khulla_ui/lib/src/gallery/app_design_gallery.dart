import 'dart:async';

import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_design_gallery}
/// The design system's own reference screen: every component, in every state
/// that matters, on one page.
///
/// It exists to be *looked at*. When a component is retuned, this is where the
/// change is checked — side by side with its neighbours, at both densities,
/// in both themes — rather than by opening whichever product screen happens
/// to use it. A component that cannot be shown here without a special case is
/// usually a component that has grown a screen-specific behaviour it should
/// not have.
///
/// Development only. It is registered on a route the release build does not
/// declare, and its copy is intentionally not localized: the labels name
/// tokens and variants, not product concepts.
/// {@endtemplate}
class AppDesignGallery extends StatefulWidget {
  /// {@macro app_design_gallery}
  const AppDesignGallery({super.key});

  @override
  State<AppDesignGallery> createState() => _AppDesignGalleryState();
}

class _AppDesignGalleryState extends State<AppDesignGallery> {
  final _searchController = TextEditingController();
  final _textController = TextEditingController(text: 'Ursula K. Le Guin');

  _GallerySection _section = _GallerySection.foundations;
  bool _checkbox = true;
  bool _switch = true;
  String _radio = 'spine';
  String? _dropdown = 'Fiction';
  bool _filter = true;
  int _page = 2;
  bool _loading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final metrics = context.appMetrics;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.page,
                spacing.pageVertical,
                spacing.page,
                spacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Design system',
                          style: context.appTextStyles.pageHeader.copyWith(
                            color: colors.ink100,
                          ),
                        ),
                        Text(
                          'Density: ${metrics.density.name} · '
                          'body ${context.appTextStyles.body.fontSize?.round()}px · '
                          'field ${metrics.fieldHeight.round()}px',
                          style: context.appTextStyles.body.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSegmentedControl<_GallerySection>(
                    value: _section,
                    items: _GallerySection.values,
                    itemLabel: (value) => value.label,
                    onChanged: (value) => setState(() => _section = value),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  spacing.page,
                  spacing.lg,
                  spacing.page,
                  spacing.xxlg,
                ),
                child: switch (_section) {
                  _GallerySection.foundations => _foundations(context),
                  _GallerySection.controls => _controls(context),
                  _GallerySection.surfaces => _surfaces(context),
                  _GallerySection.data => _data(context),
                  _GallerySection.states => _states(context),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Foundations ─────────────────────────────────────────────────────────

  Widget _foundations(BuildContext context) {
    final colors = context.appColors;
    final type = context.appTextStyles;
    final radius = context.appRadius;
    final spacing = context.appSpacing;

    return _Stack(
      children: [
        AppGallerySection(
          title: 'Type',
          note:
              'Every size is a pair — the second value applies from 1600px. '
              'There are no rungs between them.',
          children: [
            for (final (name, style) in <(String, TextStyle)>[
              ('displayMedium', type.displayMedium),
              ('displaySmall', type.displaySmall),
              ('formTitle', type.formTitle),
              ('pageHeader', type.pageHeader),
              ('title', type.title),
              ('sectionTitle', type.sectionTitle),
              ('columnHeader', type.columnHeader),
              ('bodyLarge', type.bodyLarge),
              ('body', type.body),
              ('label', type.label),
              ('caption', type.caption),
              ('micro', type.micro),
            ])
              Padding(
                padding: EdgeInsets.only(bottom: spacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        '$name ${style.fontSize?.round()}',
                        style: type.micro.copyWith(color: colors.ink600),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'The catalogue holds 12,480 titles',
                        style: style.copyWith(color: colors.ink100),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        AppGallerySection(
          title: 'Color',
          note:
              'One saturated hue. Everything else is ink, a hairline, or an '
              'alpha tint of one of them.',
          children: [
            AppGalleryRow(
              label: 'brand and status',
              children: [
                _Swatch(name: 'brand', color: colors.brand),
                _Swatch(name: 'success', color: colors.success),
                _Swatch(name: 'warning', color: colors.warning),
                _Swatch(name: 'info', color: colors.info),
                _Swatch(name: 'danger', color: colors.danger),
                _Swatch(name: 'premium', color: colors.premium),
              ],
            ),
            AppGalleryRow(
              label: 'ink ramp',
              children: [
                _Swatch(name: 'ink100', color: colors.ink100),
                _Swatch(name: 'ink200', color: colors.ink200),
                _Swatch(name: 'ink300', color: colors.ink300),
                _Swatch(name: 'ink400', color: colors.ink400),
                _Swatch(name: 'ink500', color: colors.ink500),
                _Swatch(name: 'ink600', color: colors.ink600),
                _Swatch(name: 'hairline', color: colors.hairline),
              ],
            ),
            AppGalleryRow(
              label: 'tints — every interactive surface in the product',
              children: [
                _Swatch(name: 'navRow', color: colors.tints.navRow),
                _Swatch(name: 'rowSelected', color: colors.tints.rowSelected),
                _Swatch(name: 'rowZebra', color: colors.tints.rowZebra),
                _Swatch(name: 'rowHover', color: colors.tints.rowHover),
                _Swatch(name: 'tableHeader', color: colors.tints.tableHeader),
                _Swatch(name: 'filterActive', color: colors.tints.filterActive),
              ],
            ),
          ],
        ),
        AppGallerySection(
          title: 'Shape and depth',
          note:
              'Controls are rounder than containers, and items inside a '
              'container are sharper than it. Shadows stay shallow.',
          children: [
            AppGalleryRow(
              label: 'radius',
              children: [
                _RadiusSpecimen(name: 'item', value: radius.item),
                _RadiusSpecimen(name: 'container', value: radius.container),
                _RadiusSpecimen(name: 'control', value: radius.control),
                _RadiusSpecimen(name: 'sheet', value: radius.sheet),
              ],
            ),
            AppGalleryRow(
              label: 'elevation',
              children: [
                _ShadowSpecimen(name: 'card', shadow: context.appShadows.card),
                _ShadowSpecimen(
                  name: 'raised',
                  shadow: context.appShadows.raised,
                ),
                _ShadowSpecimen(
                  name: 'overlay',
                  shadow: context.appShadows.overlay,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ── Controls ────────────────────────────────────────────────────────────

  Widget _controls(BuildContext context) {
    return _Stack(
      children: [
        AppGallerySection(
          title: 'Buttons',
          note:
              'Default is 36px. Destructive is outlined, never filled. Press '
              'one to see the ripple and the 0.95 dip.',
          children: [
            AppGalleryRow(
              label: 'variants',
              children: [
                AppButton(onPressed: () {}, child: const Text('Primary')),
                AppButton(
                  onPressed: () {},
                  variant: AppButtonVariant.destructive,
                  child: const Text('Delete copy'),
                ),
                AppButton(
                  onPressed: () {},
                  variant: AppButtonVariant.outline,
                  child: const Text('Cancel'),
                ),
                AppButton(
                  onPressed: () {},
                  variant: AppButtonVariant.secondary,
                  child: const Text('Secondary'),
                ),
                AppButton(
                  onPressed: () {},
                  variant: AppButtonVariant.ghost,
                  child: const Text('Clear filters'),
                ),
                AppButton(
                  onPressed: () {},
                  variant: AppButtonVariant.success,
                  child: const Text('Mark returned'),
                ),
                AppButton(
                  onPressed: () {},
                  variant: AppButtonVariant.link,
                  child: const Text('View all'),
                ),
              ],
            ),
            AppGalleryRow(
              label: 'sizes and glyphs',
              children: [
                AppButton(
                  onPressed: () {},
                  icon: AppIcons.add,
                  child: const Text('Add title'),
                ),
                AppButton(
                  onPressed: () {},
                  size: AppButtonSize.medium,
                  child: const Text('Medium'),
                ),
                AppButton(
                  onPressed: () {},
                  size: AppButtonSize.large,
                  trailingIcon: AppIcons.arrowRight,
                  child: const Text('Large'),
                ),
              ],
            ),
            AppGalleryRow(
              label: 'states',
              children: [
                AppButton(
                  onPressed: () => setState(() => _loading = !_loading),
                  isLoading: _loading,
                  child: const Text('Save changes'),
                ),
                const AppButton(onPressed: null, child: Text('Disabled')),
                const AppButton(
                  onPressed: null,
                  variant: AppButtonVariant.outline,
                  child: Text('Disabled outline'),
                ),
              ],
            ),
            AppGalleryRow(
              label: 'icon buttons',
              children: [
                AppIconButton(
                  icon: AppIcons.edit,
                  tooltip: 'Edit',
                  size: AppIconButtonSize.small,
                  onPressed: () {},
                ),
                AppIconButton(
                  icon: AppIcons.printer,
                  tooltip: 'Print labels',
                  onPressed: () {},
                ),
                AppIconButton(
                  icon: AppIcons.notifications,
                  tooltip: 'Notifications',
                  size: AppIconButtonSize.large,
                  badge: true,
                  onPressed: () {},
                ),
                AppMenuButton(
                  tooltip: 'More actions',
                  actions: [
                    AppMenuAction(
                      label: 'View',
                      icon: AppIcons.preview,
                      onSelected: () {},
                    ),
                    AppMenuAction(
                      label: 'Edit',
                      icon: AppIcons.edit,
                      onSelected: () {},
                    ),
                    AppMenuAction(
                      label: 'Delete',
                      icon: AppIcons.delete,
                      isDestructive: true,
                      onSelected: () {},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        AppGallerySection(
          title: 'Fields',
          note:
              'Focus a field: the text nudges 2px right over 300ms and no ring '
              'appears. On error the label turns red, not the border.',
          children: [
            _FieldGrid(
              children: [
                AppTextField(
                  label: 'Author',
                  controller: _textController,
                  required: true,
                  onChanged: (_) {},
                ),
                AppTextField(
                  label: 'ISBN',
                  hintText: '978-0-000-00000-0',
                  errorText: 'That ISBN is already on another title.',
                  onChanged: (_) {},
                ),
                AppDropdownField<String>(
                  label: 'Collection',
                  value: _dropdown,
                  items: const ['Fiction', 'Reference', 'Periodicals'],
                  itemLabel: (value) => value,
                  onChanged: (value) => setState(() => _dropdown = value),
                ),
                AppSearchField(
                  hintText: 'Search titles, authors, ISBNs',
                  controller: _searchController,
                  clearTooltip: 'Clear',
                  onChanged: (_) {},
                ),
              ],
            ),
            AppGalleryRow(
              label: 'toggles',
              children: [
                SizedBox(
                  width: 260,
                  child: AppCheckboxField(
                    value: _checkbox,
                    label: 'Reservable',
                    description: 'Members may place a hold on this title.',
                    onChanged: (value) =>
                        setState(() => _checkbox = value ?? false),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: AppSwitchField(
                    value: _switch,
                    label: 'Overdue notices',
                    description: 'Send a notice the morning a loan falls due.',
                    onChanged: (value) => setState(() => _switch = value),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: Column(
                    children: [
                      for (final option in const ['spine', 'pocket'])
                        AppRadioField<String>(
                          value: option,
                          groupValue: _radio,
                          label:
                              '${option[0].toUpperCase()}${option.substring(1)} label',
                          onChanged: (value) => setState(() => _radio = value),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            AppGalleryRow(
              label: 'filters — dashed at rest, tinted when set',
              children: [
                AppFilterChip(
                  label: 'Overdue',
                  count: 12,
                  selected: _filter,
                  tone: AppStatusTone.danger,
                  onSelected: (value) => setState(() => _filter = value),
                ),
                AppFilterChip(
                  label: 'On loan',
                  count: 48,
                  selected: false,
                  onSelected: (_) {},
                ),
                AppFilterChip(
                  label: 'Reserved',
                  selected: false,
                  onSelected: (_) {},
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ── Surfaces ────────────────────────────────────────────────────────────

  Widget _surfaces(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;

    return _Stack(
      children: [
        AppGallerySection(
          title: 'Cards',
          note:
              'The default card is a bordered block: hairline, 6px corners, no '
              'fill and no shadow. `filled` is the rarer variant.',
          children: [
            AppGalleryRow(
              label: 'variants',
              children: [
                SizedBox(
                  width: 260,
                  child: AppCard(child: _cardBody(context, 'Bordered block')),
                ),
                SizedBox(
                  width: 260,
                  child: AppCard(
                    filled: true,
                    child: _cardBody(context, 'Filled'),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: AppCard(
                    onTap: () {},
                    child: _cardBody(context, 'Tappable — hover it'),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: AppCard(
                    tone: AppStatusTone.warning,
                    child: _cardBody(context, 'Toned'),
                  ),
                ),
              ],
            ),
          ],
        ),
        AppGallerySection(
          title: 'Badges',
          note:
              'One hue, three ways: an 8% wash, the hue for the text, a '
              'hairline between. 10px semibold, deliberately small.',
          children: [
            AppGalleryRow(
              label: 'tones',
              children: [
                for (final (label, tone) in const <(String, AppStatusTone)>[
                  ('Available', AppStatusTone.success),
                  ('Due today', AppStatusTone.warning),
                  ('Reserved', AppStatusTone.info),
                  ('Overdue', AppStatusTone.danger),
                  ('Draft', AppStatusTone.neutral),
                  ('Featured', AppStatusTone.brand),
                ])
                  AppStatusBadge(label: label, tone: tone),
              ],
            ),
            const AppGalleryRow(
              label: 'dense, and with a dot',
              children: [
                AppStatusBadge(
                  label: 'On loan',
                  tone: AppStatusTone.info,
                  dense: true,
                ),
                AppStatusBadge(
                  label: 'Lost',
                  tone: AppStatusTone.danger,
                  showDot: true,
                ),
                AppStatusBadge(
                  label: 'Returned',
                  tone: AppStatusTone.success,
                  icon: AppIcons.check,
                ),
              ],
            ),
          ],
        ),
        AppGallerySection(
          title: 'Overlays',
          note:
              'Open the dialog and hover its close chip — it drifts outward and '
              'turns the glyph a quarter turn.',
          children: [
            AppGalleryRow(
              label: 'open one',
              children: [
                AppButton(
                  onPressed: () => _showDialog(context),
                  variant: AppButtonVariant.outline,
                  child: const Text('Confirmation dialog'),
                ),
                AppButton(
                  onPressed: () => _showSideSheet(context),
                  variant: AppButtonVariant.outline,
                  child: const Text('Side sheet'),
                ),
                AppButton(
                  onPressed: () => _showBottomSheet(context),
                  variant: AppButtonVariant.outline,
                  child: const Text('Bottom sheet'),
                ),
                Tooltip(
                  message: 'A light tooltip with a hairline, not a dark slab',
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.hairline),
                      borderRadius: BorderRadius.circular(
                        context.appRadius.container,
                      ),
                    ),
                    child: Text(
                      'Hover for a tooltip',
                      style: context.appTextStyles.body.copyWith(
                        color: colors.ink500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ── Data ────────────────────────────────────────────────────────────────

  Widget _data(BuildContext context) {
    final colors = context.appColors;

    return _Stack(
      children: [
        AppGallerySection(
          title: 'Table',
          note:
              'Zebra on even rows, a tint on hover, a warmer tint on the '
              'selected one. Hover a sortable header to reveal its chevron.',
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: colors.hairline),
                borderRadius: BorderRadius.circular(
                  context.appRadius.container,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  context.appRadius.container,
                ),
                child: AppTable<_Loan>(
                  items: _demoLoans,
                  onRowTap: (_) {},
                  isSelected: (loan) =>
                      loan.title.startsWith('The Dispossessed'),
                  sort: const AppTableSort(columnId: 'due'),
                  onSort: (_) {},
                  columns: [
                    AppTableColumn<_Loan>(
                      id: 'title',
                      label: 'Title',
                      flex: 3,
                      sortable: true,
                      cellBuilder: (context, loan) => Text(loan.title),
                    ),
                    AppTableColumn<_Loan>(
                      id: 'member',
                      label: 'Member',
                      flex: 2,
                      cellBuilder: (context, loan) => Text(loan.member),
                    ),
                    AppTableColumn<_Loan>(
                      id: 'due',
                      label: 'Due',
                      sortable: true,
                      cellBuilder: (context, loan) => Text(loan.due),
                    ),
                    AppTableColumn<_Loan>(
                      id: 'status',
                      label: 'Status',
                      width: 120,
                      cellBuilder: (context, loan) =>
                          AppStatusBadge(label: loan.status, tone: loan.tone),
                    ),
                  ],
                ),
              ),
            ),
            AppPagination(
              rangeLabel: 'Showing 1–4 of 128 loans',
              previousTooltip: 'Previous page',
              nextTooltip: 'Next page',
              pageCount: 12,
              currentPage: _page,
              onPageSelected: (page) => setState(() => _page = page),
              onPrevious: _page == 0 ? null : () => setState(() => _page--),
              onNext: _page == 11 ? null : () => setState(() => _page++),
            ),
          ],
        ),
      ],
    );
  }

  // ── States ──────────────────────────────────────────────────────────────

  Widget _states(BuildContext context) {
    final spacing = context.appSpacing;

    return _Stack(
      children: [
        AppGallerySection(
          title: 'Loading',
          note:
              'Two spinners with two jobs, and a skeleton that pulses opacity '
              'rather than sweeping a gradient.',
          children: [
            const AppGalleryRow(
              label: 'spinners',
              children: [
                AppSpinner(size: AppSpinner.buttonSize),
                AppSpinner(),
              ],
            ),
            AppGalleryRow(
              label: 'skeletons',
              children: [
                SizedBox(
                  width: 320,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppSkeleton(width: 200, height: 20),
                      SizedBox(height: spacing.xs),
                      const AppSkeleton(height: 14),
                      SizedBox(height: spacing.xs),
                      const AppSkeleton(width: 240, height: 14),
                    ],
                  ),
                ),
                const AppSkeleton(
                  width: 40,
                  height: 40,
                  shape: BoxShape.circle,
                ),
              ],
            ),
          ],
        ),
        const AppGallerySection(
          title: 'Empty',
          note:
              '96px of vertical room, one glyph, an 18px bold heading, one '
              'line of copy, one action.',
          children: [
            AppEmptyView(
              icon: AppIcons.inventory,
              title: 'No copies yet',
              message:
                  'Add the first copy and it will show up here with its '
                  'barcode and shelf location.',
              actionLabel: 'Add copy',
              onAction: _noop,
            ),
          ],
        ),
        const AppGallerySection(
          title: 'Error',
          note: 'A failed read, with the retry beside it.',
          children: [
            AppErrorView(
              message: 'The catalogue could not be opened.',
              retryLabel: 'Try again',
              onRetry: _noop,
            ),
          ],
        ),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  static void _noop() {}

  Widget _cardBody(BuildContext context, String label) {
    final spacing = context.appSpacing;
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.appTextStyles.sectionTitle.copyWith(
            color: colors.ink100,
          ),
        ),
        SizedBox(height: spacing.xxs),
        Text(
          'Depth here comes from the hairline, not from a drop shadow.',
          style: context.appTextStyles.body.copyWith(
            color: colors.mutedForeground,
          ),
        ),
      ],
    );
  }

  void _showDialog(BuildContext context) {
    unawaited(
      AppDialog.confirmDestructive(
        context: context,
        title: 'Delete this copy?',
        message:
            'Copy C-00841 will be removed from the catalogue. Its loan history '
            'stays on the member record.',
        confirmLabel: 'Delete copy',
        cancelLabel: 'Keep it',
      ),
    );
  }

  void _showSideSheet(BuildContext context) {
    unawaited(
      AppSideSheet.show<void>(
        context: context,
        title: 'Edit title',
        caption: 'Changes are saved to the catalogue immediately.',
        closeTooltip: 'Close',
        builder: (sheetContext) => Column(
          children: [
            AppTextField(
              label: 'Title',
              initialValue: 'The Dispossessed',
              onChanged: (_) {},
            ),
            SizedBox(height: sheetContext.appMetrics.formRowGap),
            AppTextField(
              label: 'Author',
              initialValue: 'Ursula K. Le Guin',
              onChanged: (_) {},
            ),
          ],
        ),
        actionsBuilder: (sheetContext) => AppDialogActions(
          children: [
            AppDialog.secondaryAction(
              context: sheetContext,
              label: 'Cancel',
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
            AppDialog.primaryAction(
              context: sheetContext,
              label: 'Save',
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    unawaited(
      AppBottomSheet.show<void>(
        context: context,
        title: 'Label size',
        caption: 'Applies to every label in this print run.',
        builder: (sheetContext) => Column(
          children: [
            for (final option in const ['spine', 'pocket'])
              AppRadioField<String>(
                value: option,
                groupValue: _radio,
                label: '${option[0].toUpperCase()}${option.substring(1)} label',
                onChanged: (value) {
                  setState(() => _radio = value);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// The gallery's own sections.
enum _GallerySection {
  foundations('Foundations'),
  controls('Controls'),
  surfaces('Surfaces'),
  data('Data'),
  states('States');

  _GallerySection(this.label);

  final String label;
}

/// Vertical rhythm between gallery sections.
class _Stack extends StatelessWidget {
  const _Stack({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, child) in children.indexed) ...[
          if (index > 0) ...[
            SizedBox(height: spacing.xlg),
            const Divider(),
            SizedBox(height: spacing.xlg),
          ],
          child,
        ],
      ],
    );
  }
}

/// Two fields per row, which is the form layout the product uses.
class _FieldGrid extends StatelessWidget {
  const _FieldGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final gap = context.appMetrics.formRowGap;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final child in children) SizedBox(width: 280, child: child),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;

    return SizedBox(
      width: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(context.appRadius.container),
              border: Border.all(color: context.appColors.hairline),
            ),
          ),
          SizedBox(height: spacing.xxs),
          Text(
            name,
            style: context.appTextStyles.micro.copyWith(
              color: context.appColors.ink500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadiusSpecimen extends StatelessWidget {
  const _RadiusSpecimen({required this.name, required this.value});

  final String name;
  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: BorderRadius.circular(value),
              border: Border.all(color: colors.hairline),
            ),
          ),
          SizedBox(height: context.appSpacing.xxs),
          Text(
            '$name ${value.round()}',
            style: context.appTextStyles.micro.copyWith(color: colors.ink500),
          ),
        ],
      ),
    );
  }
}

class _ShadowSpecimen extends StatelessWidget {
  const _ShadowSpecimen({required this.name, required this.shadow});

  final String name;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(context.appRadius.container),
              border: Border.all(color: colors.hairline),
              boxShadow: shadow,
            ),
          ),
          SizedBox(height: context.appSpacing.xxs),
          Text(
            name,
            style: context.appTextStyles.micro.copyWith(color: colors.ink500),
          ),
        ],
      ),
    );
  }
}

/// A row in the gallery's demo table.
class _Loan {
  const _Loan(this.title, this.member, this.due, this.status, this.tone);

  final String title;
  final String member;
  final String due;
  final String status;
  final AppStatusTone tone;
}

const _demoLoans = <_Loan>[
  _Loan(
    'A Wizard of Earthsea',
    'R. Shrestha',
    '12 Sep',
    'On loan',
    AppStatusTone.info,
  ),
  _Loan(
    'The Dispossessed',
    'K. Tamang',
    '9 Sep',
    'Due today',
    AppStatusTone.warning,
  ),
  _Loan(
    'The Left Hand of Darkness',
    'S. Gurung',
    '2 Sep',
    'Overdue',
    AppStatusTone.danger,
  ),
  _Loan(
    'Always Coming Home',
    'P. Rai',
    '20 Sep',
    'On loan',
    AppStatusTone.info,
  ),
];
