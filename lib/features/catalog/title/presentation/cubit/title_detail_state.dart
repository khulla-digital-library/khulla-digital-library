import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/features/catalog/copy/domain/models/copy.dart';
import 'package:khulla/features/catalog/title/domain/models/title.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan.dart';
import 'package:khulla/shared/models/load_status.dart';

part 'title_detail_state.freezed.dart';

@freezed
abstract class TitleDetailState with _$TitleDetailState {
  const factory TitleDetailState({
    @Default(LoadStatus.initial) LoadStatus status,
    Title? title,
    @Default(<Copy>[]) List<Copy> copies,
    @Default(<Loan>[]) List<Loan> historyLoans,
    AppException? error,
  }) = _TitleDetailState;

  const TitleDetailState._();

  bool get isLoading => status.isLoading;
  bool get hasError => status.hasError;
}
