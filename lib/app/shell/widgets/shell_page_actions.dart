import 'dart:async';

import 'package:khulla/core/di/injection.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/copy/presentation/copy_form_dialog.dart';
import 'package:khulla/features/catalog/copy/presentation/copy_list_refresh.dart';
import 'package:khulla/features/catalog/title/presentation/title_form_dialog.dart';
import 'package:khulla/features/catalog/title/presentation/title_format_list_dialog.dart';
import 'package:khulla/features/catalog/title/presentation/title_list_refresh.dart';
import 'package:khulla/features/circulation/reservation/presentation/place_hold_dialog.dart';
import 'package:khulla/features/circulation/reservation/presentation/reservation_list_refresh.dart';
import 'package:khulla/features/members/presentation/pages/member_form_dialog.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// What the top bar offers for a given location.
///
/// Resolved from the router's path for the same reason the title is (see
/// `shellPageTitle`): the bar lives in the shell, and a page that pushed its
/// own actions up through an inherited widget would have to do it on every
/// build and would leave the bar showing the last section's buttons whenever
/// a route was pushed on the root navigator.
///
/// The consequence is deliberate: a section's action must be expressible as
/// *go here* or *open this*, not as something that depends on the page's
/// state. An action that needs the cubit — bulk-editing the rows a table has
/// selected — belongs in that page's toolbar, above the table it acts on.
List<Widget> shellPageActions(
  BuildContext context,
  String location,
  AppLocalizations l10n,
) {
  AppButton primary(String label, AppIconSpec icon, VoidCallback onPressed) =>
      AppButton(icon: icon, onPressed: onPressed, child: Text(label));

  AppButton modal(
    String label,
    AppIconSpec icon,
    Future<void> Function() open,
  ) => primary(label, icon, open);

  // Longest path first: `/catalog/titles` must not be answered by `/catalog`.
  return switch (location) {
    _ when Routes.isUnder(location, Routes.catalogTitles) => [
      AppIconButton(
        icon: AppIcons.bookBookmark,
        tooltip: l10n.titlesManageFormats,
        onPressed: () => unawaited(TitleFormatListDialog.show(context)),
      ),
      modal(
        l10n.titlesAdd,
        AppIcons.add,
        () async {
          final saved = await TitleFormDialog.show(context);
          if (saved == true) {
            getIt<TitleListRefresh>().notifyChanged();
          }
        },
      ),
    ],
    _ when Routes.isUnder(location, Routes.catalogCopies) => [
      modal(
        l10n.copiesAdd,
        AppIcons.add,
        () async {
          final saved = await CopyFormDialog.show(context);
          if (saved == true) {
            getIt<CopyListRefresh>().notifyChanged();
          }
        },
      ),
    ],
    _ when Routes.isUnder(location, Routes.catalogAuthors) => [
      primary(l10n.authorsAdd, AppIcons.add, () => showNotWiredToast(context)),
    ],
    _ when Routes.isUnder(location, Routes.circulationReservations) => [
      modal(
        l10n.reservationsPlace,
        AppIcons.add,
        () async {
          final saved = await PlaceHoldDialog.show(context);
          if (saved == true) {
            getIt<ReservationListRefresh>().notifyChanged();
          }
        },
      ),
    ],
    _ when Routes.isUnder(location, Routes.circulationCheckOut) => const [],
    _ when Routes.isUnder(location, Routes.circulationReturn) => const [],
    _ when Routes.isUnder(location, Routes.members) => [
      modal(
        l10n.membersAdd,
        AppIcons.addPerson,
        () => MemberFormDialog.show(context),
      ),
    ],
    _ => const [],
  };
}
