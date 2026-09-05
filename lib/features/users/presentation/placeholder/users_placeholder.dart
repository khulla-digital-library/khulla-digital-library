import 'package:khulla/features/users/domain/user_role.dart';
import 'package:khulla/features/users/domain/user_status.dart';
import 'package:khulla/features/users/presentation/placeholder/staff_record.dart';

/// The staff register the screens are designed against.
///
/// Six accounts covering every role and every standing, so the table, the
/// filters and the empty state can all be seen before the feature has a
/// database behind it.
const List<StaffRecord> placeholderStaff = [
  StaffRecord(
    id: 'stf-01',
    name: 'Sangam Adhikari',
    email: 'sangam@khulla.library',
    role: UserRole.administrator,
    status: UserStatus.active,
    lastActive: 'Today, 09:12',
  ),
  StaffRecord(
    id: 'stf-02',
    name: 'Anita Shrestha',
    email: 'anita@khulla.library',
    role: UserRole.librarian,
    status: UserStatus.active,
    lastActive: 'Today, 08:40',
  ),
  StaffRecord(
    id: 'stf-03',
    name: 'Bikash Rai',
    email: 'bikash@khulla.library',
    role: UserRole.librarian,
    status: UserStatus.active,
    lastActive: 'Yesterday, 17:05',
  ),
  StaffRecord(
    id: 'stf-04',
    name: 'Prakriti Karki',
    email: 'prakriti@khulla.library',
    role: UserRole.assistant,
    status: UserStatus.active,
    lastActive: '3 days ago',
  ),
  StaffRecord(
    id: 'stf-05',
    name: 'Rojina Tamang',
    email: 'rojina@khulla.library',
    role: UserRole.assistant,
    status: UserStatus.invited,
    lastActive: null,
  ),
  StaffRecord(
    id: 'stf-06',
    name: 'Deepak Gurung',
    email: 'deepak@khulla.library',
    role: UserRole.readOnly,
    status: UserStatus.disabled,
    lastActive: 'Last month',
  ),
];
