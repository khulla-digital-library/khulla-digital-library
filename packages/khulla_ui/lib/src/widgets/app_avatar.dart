import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_avatar}
/// A circular initials badge for a person or an organisation.
///
/// Takes ready-made [initials] rather than a name: deriving two letters from
/// a name is locale-sensitive, and the design system does not do locale. The
/// caller trims and cases them.
/// {@endtemplate}
class AppAvatar extends StatelessWidget {
  /// {@macro app_avatar}
  const AppAvatar({
    required this.initials,
    this.size = 40,
    this.tone = AppStatusTone.brand,
    super.key,
  });

  /// One or two characters, already cased by the caller.
  final String initials;

  /// Diameter in logical pixels.
  final double size;

  /// Which semantic family the badge draws from. Vary it to tell record
  /// kinds apart — staff from borrowers — never to encode identity.
  final AppStatusTone tone;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tone.background(context),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials,
            maxLines: 1,
            style: context.textTheme.labelMedium?.copyWith(
              color: tone.foreground(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
