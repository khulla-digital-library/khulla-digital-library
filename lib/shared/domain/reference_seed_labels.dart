/// English seed labels matching `app_en.arb` — bootstrap has no l10n context.
String seedFormatName(String code) => switch (code) {
  'book' => 'Book',
  'journal' => 'Journal',
  'magazine' => 'Magazine',
  'audiobook' => 'Audiobook',
  'video' => 'Video',
  'ebook' => 'E-book',
  'other' => 'Other',
  _ => code,
};

String seedMemberTypeName(String code) => switch (code) {
  'student' => 'Student',
  'teacher' => 'Teacher',
  'public' => 'Public',
  'child' => 'Child',
  'other' => 'Other',
  _ => code,
};
