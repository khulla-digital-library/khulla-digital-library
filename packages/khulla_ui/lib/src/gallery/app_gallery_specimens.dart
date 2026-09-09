import 'package:khulla_ui/khulla_ui.dart';

/// Vertical rhythm between gallery sections.
class AppGalleryStack extends StatelessWidget {
  const AppGalleryStack({required this.children, super.key});

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
class AppGalleryFieldGrid extends StatelessWidget {
  const AppGalleryFieldGrid({required this.children, super.key});

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

/// A color chip with its token name.
class AppGallerySwatch extends StatelessWidget {
  const AppGallerySwatch({
    required this.name,
    required this.color,
    super.key,
  });

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

/// A radius token rendered as a block.
class AppGalleryRadiusSpecimen extends StatelessWidget {
  const AppGalleryRadiusSpecimen({
    required this.name,
    required this.value,
    super.key,
  });

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

/// A shadow token rendered as a block.
class AppGalleryShadowSpecimen extends StatelessWidget {
  const AppGalleryShadowSpecimen({
    required this.name,
    required this.shadow,
    super.key,
  });

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
