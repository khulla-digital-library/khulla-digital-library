import 'package:khulla_ui/khulla_ui.dart';

/// The initials circle standing in for a person or a record.
///
/// It takes the initials rather than a name: deriving them is a locale
/// question — a Nepali name does not split the way an English one does — and
/// that belongs to the feature that owns the record, not to the design system.
///
/// [tone] is how a list of members stays scannable: passing a stable tone per
/// record (derived from its id) gives each person a consistent color without
/// anyone choosing one.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.initials,
    this.size = 40,
    this.tone = AppStatusTone.brand,
    this.badge,
    this.badgeTone = AppStatusTone.success,
    super.key,
  });

  /// One or two characters, already cased.
  final String initials;

  /// The circle's diameter.
  final double size;

  /// Which wash and ink to paint.
  final AppStatusTone tone;

  /// A glyph pinned to the bottom-trailing edge — a verified check, a
  /// suspended block. Null draws no badge.
  final IconData? badge;

  /// The badge's tone.
  final AppStatusTone badgeTone;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final glyph = badge;

    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tone.background(context),
        shape: BoxShape.circle,
        border: Border.all(color: tone.border(context)),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        maxLines: 1,
        style: context.textTheme.labelSmall?.copyWith(
          fontSize: size * 0.36,
          height: 1,
          color: tone.foreground(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (glyph == null) return circle;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          circle,
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: scheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                glyph,
                size: size * 0.36,
                color: badgeTone.foreground(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
