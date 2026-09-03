/// What a staff account is allowed to do.
///
/// Roles are a fixed set rather than a table because a library's desk has
/// four jobs, not an arbitrary number: the person who owns the system, the
/// people who run the catalogue, the people who work the counter, and anyone
/// who may look but not touch. A custom role is a feature request, not a
/// default.
enum UserRole { administrator, librarian, assistant, readOnly }

/// One thing a role may or may not do.
///
/// The list is deliberately coarse — eight permissions a librarian can reason
/// about, not forty a developer can. Anything finer belongs to the screen
/// that enforces it.
enum StaffPermission {
  catalog,
  circulation,
  members,
  fines,
  reports,
  settings,
  users,
  backup,
}

/// The permissions each role carries.
///
/// Written out per role rather than derived from a hierarchy: a desk
/// assistant is not "a librarian with less", and the day that stops being
/// true this map is the one place that changes.
const Map<UserRole, Set<StaffPermission>> rolePermissions = {
  UserRole.administrator: {
    StaffPermission.catalog,
    StaffPermission.circulation,
    StaffPermission.members,
    StaffPermission.fines,
    StaffPermission.reports,
    StaffPermission.settings,
    StaffPermission.users,
    StaffPermission.backup,
  },
  UserRole.librarian: {
    StaffPermission.catalog,
    StaffPermission.circulation,
    StaffPermission.members,
    StaffPermission.fines,
    StaffPermission.reports,
  },
  UserRole.assistant: {
    StaffPermission.circulation,
    StaffPermission.members,
  },
  UserRole.readOnly: {StaffPermission.reports},
};
