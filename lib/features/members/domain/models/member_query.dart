import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:khulla/features/members/domain/models/member.dart';

part 'member_query.freezed.dart';

@freezed
abstract class MemberQuery with _$MemberQuery {
  const factory MemberQuery({
    @Default('') String search,
    @Default(false) bool withLoans,
    @Default(false) bool owesFines,
    @Default(false) bool suspended,
    @Default(false) bool expiring,
    @Default('name') String sortColumn,
    @Default(true) bool sortAscending,
    @Default(0) int offset,
    @Default(8) int limit,
  }) = _MemberQuery;
}

typedef MemberListResult = ({List<Member> items, int totalCount});
