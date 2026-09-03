import 'package:khulla_ui/khulla_ui.dart';

/// The bar pinned above every page in the shell.
///
/// It lives *outside* the page's scroll view, which is the whole point: the
/// page title, the global search and the account control stay put while a
/// ten-thousand-row catalogue scrolls under them. A header that scrolls away
/// is the single most common complaint about dashboards built as one long
/// column, and no amount of `SliverPersistentHeader` gymnastics inside each
/// page fixes it as simply as putting the bar in the shell.
///
/// Slots, in order: the leading control (a menu button on a phone), the title
/// block with its breadcrumb trail, the search field, then the trailing
/// actions and the account control. Everything but the title is optional; the
/// bar reflows to two rows when the window cannot hold search beside the
/// title.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    required this.title,
    this.breadcrumbs,
    this.search,
    this.actions = const [],
    this.trailing,
    this.leading,
    this.searchWidth = 320,
    super.key,
  });

  /// The page's name.
  final String title;

  /// The trail above the title. Null on a top-level section.
  final Widget? breadcrumbs;

  /// The global search field.
  final Widget? search;

  /// Icon-sized controls between search and [trailing] — notifications, help.
  final List<Widget> actions;

  /// The account control, pinned to the trailing edge.
  final Widget? trailing;

  /// A control before the title — the drawer button on a narrow window.
  final Widget? leading;

  /// How much room the search field takes when it fits on the title row.
  final double searchWidth;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final colors = context.appColors;
    final crumbs = breadcrumbs;
    final searchField = search;
    final account = trailing;
    final lead = leading;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appTextStyles.pageHeader.copyWith(
            color: colors.ink100,
          ),
        ),
        if (crumbs != null) ...[
          const SizedBox(height: 2),
          crumbs,
        ],
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: colors.hairline)),
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tight = constraints.maxWidth < 900;
            final trailingRow = <Widget>[
              for (final action in actions) ...[
                action,
                SizedBox(width: spacing.xxs),
              ],
              if (account != null) ...[
                SizedBox(width: spacing.xs),
                account,
              ],
            ];

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.page,
                vertical: spacing.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: context.appMetrics.topBarHeight,
                    ),
                    child: Row(
                      children: [
                        if (lead != null) ...[
                          lead,
                          SizedBox(width: spacing.xs),
                        ],
                        Expanded(child: titleBlock),
                        if (searchField != null && !tight) ...[
                          SizedBox(width: spacing.md),
                          SizedBox(width: searchWidth, child: searchField),
                          SizedBox(width: spacing.xs),
                        ],
                        ...trailingRow,
                      ],
                    ),
                  ),
                  if (searchField != null && tight) ...[
                    SizedBox(height: spacing.sm),
                    searchField,
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
