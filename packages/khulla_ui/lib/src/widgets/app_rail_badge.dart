// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla_ui/khulla_ui.dart';

/// A count pinned to a rail row, e.g. overdue loans on Circulation.
class AppRailBadge extends StatelessWidget {
  const AppRailBadge({
    required this.label,
    required this.selected,
    super.key,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? colors.brandSoft : colors.secondary,
        borderRadius: BorderRadius.circular(context.appRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Text(
          label,
          style: context.appTextStyles.micro.copyWith(
            color: selected ? colors.brand : colors.ink500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
