import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/catalog/shared/domain/catalog_format.dart';
import 'package:khulla/features/catalog/shared/domain/copy_condition.dart';
import 'package:khulla/features/catalog/shared/domain/copy_status.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_author.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_copy.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_title.dart';

/// Stand-in records for every catalogue screen.
///
/// One file, so the swap to real queries is one deletion: each page reads a
/// cubit's state instead of calling these, and this file goes with the
/// `placeholder/` folder around it. The lists are `final`, not `const`,
/// because [Money.major] is not a const constructor.
///
/// The rows are deliberately uneven — a lost copy, a reference-only work, a
/// title with no copies left on the shelf — so the screens are laid out
/// against the states a real catalogue produces rather than a tidy sample.
final List<CatalogTitle> placeholderTitles = [
  CatalogTitle(
    id: 't-1',
    title: 'Palpasa Café',
    author: 'Narayan Wagle',
    isbn: '978-9937-2-1234-5',
    publisher: 'Nepalaya',
    year: '2005',
    format: CatalogFormat.book,
    shelf: 'NEP 891.5',
    copies: 4,
    available: 2,
    addedOn: '12 Mar 2024',
    replacementCost: Money.major(650),
    language: 'Nepali',
    pages: 232,
    subjects: const ['Nepali fiction', 'Contemporary'],
    description:
        'A novel following an artist through the years of the conflict, told '
        'in the voice of a friend who survives him.',
  ),
  CatalogTitle(
    id: 't-2',
    title: 'Things Fall Apart',
    author: 'Chinua Achebe',
    isbn: '978-0-385-47454-2',
    publisher: 'Anchor Books',
    year: '1958',
    format: CatalogFormat.book,
    shelf: 'FIC ACH',
    copies: 3,
    available: 0,
    addedOn: '02 Feb 2024',
    replacementCost: Money.major(1200),
    edition: '2nd',
    pages: 209,
    subjects: const ['African literature', 'Classics'],
    description:
        "Okonkwo's standing in Umuofia, and what colonial administration does "
        'to the world that granted it.',
  ),
  CatalogTitle(
    id: 't-3',
    title: 'Introduction to Algorithms',
    subtitle: 'Fourth edition',
    author: 'Thomas H. Cormen',
    isbn: '978-0-262-04630-5',
    publisher: 'MIT Press',
    year: '2022',
    format: CatalogFormat.book,
    shelf: 'CS 005.1',
    copies: 6,
    available: 5,
    addedOn: '18 Jan 2025',
    replacementCost: Money.major(4800),
    edition: '4th',
    pages: 1312,
    subjects: const ['Computer science', 'Reference'],
    description:
        'The standard algorithms text, held as a reference set for the '
        'reading room.',
  ),
  CatalogTitle(
    id: 't-4',
    title: 'The Himalayan Journal',
    author: 'Himalayan Club',
    isbn: '0018-1439',
    publisher: 'Himalayan Club',
    year: '2024',
    format: CatalogFormat.journal,
    shelf: 'PER 796.5',
    copies: 2,
    available: 2,
    addedOn: '30 Nov 2024',
    replacementCost: Money.major(900),
    subjects: const ['Mountaineering', 'Periodical'],
    lendable: false,
    description: 'Annual volume. Reference only — reading room use.',
  ),
  CatalogTitle(
    id: 't-5',
    title: 'Sapiens',
    subtitle: 'A brief history of humankind',
    author: 'Yuval Noah Harari',
    isbn: '978-0-06-231609-7',
    publisher: 'Harper',
    year: '2015',
    format: CatalogFormat.book,
    shelf: 'HIS 909',
    copies: 5,
    available: 1,
    addedOn: '21 Sep 2024',
    replacementCost: Money.major(1450),
    pages: 443,
    subjects: const ['History', 'Anthropology'],
  ),
  CatalogTitle(
    id: 't-6',
    title: 'Muna Madan',
    author: 'Laxmi Prasad Devkota',
    isbn: '978-9937-8-5566-1',
    publisher: 'Sajha Prakashan',
    year: '1936',
    format: CatalogFormat.book,
    shelf: 'NEP 891.4',
    copies: 8,
    available: 6,
    addedOn: '05 Aug 2023',
    replacementCost: Money.major(220),
    language: 'Nepali',
    pages: 64,
    subjects: const ['Poetry', 'Nepali literature'],
  ),
  CatalogTitle(
    id: 't-7',
    title: 'The Kathmandu Post Archive 2023',
    author: 'Kantipur Publications',
    isbn: '2091-0091',
    publisher: 'Kantipur',
    year: '2023',
    format: CatalogFormat.magazine,
    shelf: 'PER 070',
    copies: 1,
    available: 0,
    addedOn: '14 Jan 2024',
    replacementCost: Money.major(300),
    subjects: const ['Newspapers'],
    lendable: false,
  ),
  CatalogTitle(
    id: 't-8',
    title: 'Everest: Beyond the Limit',
    author: 'Discovery Channel',
    isbn: 'DVD-0091',
    publisher: 'Discovery',
    year: '2007',
    format: CatalogFormat.video,
    shelf: 'AV 796.522',
    copies: 2,
    available: 1,
    addedOn: '19 Jun 2024',
    replacementCost: Money.major(1800),
    subjects: const ['Documentary', 'Mountaineering'],
  ),
  CatalogTitle(
    id: 't-9',
    title: 'A Brief History of Time',
    author: 'Stephen Hawking',
    isbn: '978-0-553-38016-3',
    publisher: 'Bantam',
    year: '1998',
    format: CatalogFormat.book,
    shelf: 'SCI 523.1',
    copies: 3,
    available: 2,
    addedOn: '11 Apr 2024',
    replacementCost: Money.major(1100),
    pages: 212,
    subjects: const ['Physics', 'Popular science'],
  ),
  CatalogTitle(
    id: 't-10',
    title: 'Learning Nepali',
    subtitle: 'A course for beginners',
    author: 'Banu Oja',
    isbn: '978-9937-0-0111-2',
    publisher: 'Ratna Pustak',
    year: '2019',
    format: CatalogFormat.audio,
    shelf: 'LAN 491.49',
    copies: 4,
    available: 4,
    addedOn: '08 Feb 2025',
    replacementCost: Money.major(980),
    language: 'Nepali',
    subjects: const ['Language learning'],
  ),
];

/// The copies behind [placeholderTitles].
const List<CatalogCopy> placeholderCopies = [
  CatalogCopy(
    id: 'c-1',
    barcode: 'KH-000181',
    titleId: 't-1',
    titleName: 'Palpasa Café',
    shelf: 'NEP 891.5',
    condition: CopyCondition.good,
    status: CopyStatus.available,
    acquired: '12 Mar 2024',
  ),
  CatalogCopy(
    id: 'c-2',
    barcode: 'KH-000182',
    titleId: 't-1',
    titleName: 'Palpasa Café',
    shelf: 'NEP 891.5',
    condition: CopyCondition.fair,
    status: CopyStatus.onLoan,
    acquired: '12 Mar 2024',
    borrower: 'Anita Rai',
    dueDate: '14 Sep 2026',
  ),
  CatalogCopy(
    id: 'c-3',
    barcode: 'KH-000183',
    titleId: 't-1',
    titleName: 'Palpasa Café',
    shelf: 'NEP 891.5',
    condition: CopyCondition.good,
    status: CopyStatus.overdue,
    acquired: '12 Mar 2024',
    borrower: 'Bikash Thapa',
    dueDate: '18 Aug 2026',
  ),
  CatalogCopy(
    id: 'c-4',
    barcode: 'KH-000184',
    titleId: 't-1',
    titleName: 'Palpasa Café',
    shelf: 'NEP 891.5',
    condition: CopyCondition.asNew,
    status: CopyStatus.reserved,
    acquired: '20 Jul 2025',
  ),
  CatalogCopy(
    id: 'c-5',
    barcode: 'KH-000210',
    titleId: 't-2',
    titleName: 'Things Fall Apart',
    shelf: 'FIC ACH',
    condition: CopyCondition.poor,
    status: CopyStatus.damaged,
    acquired: '02 Feb 2024',
  ),
  CatalogCopy(
    id: 'c-6',
    barcode: 'KH-000211',
    titleId: 't-2',
    titleName: 'Things Fall Apart',
    shelf: 'FIC ACH',
    condition: CopyCondition.good,
    status: CopyStatus.onLoan,
    acquired: '02 Feb 2024',
    borrower: 'Sunita Gurung',
    dueDate: '09 Sep 2026',
  ),
  CatalogCopy(
    id: 'c-7',
    barcode: 'KH-000212',
    titleId: 't-2',
    titleName: 'Things Fall Apart',
    shelf: 'FIC ACH',
    condition: CopyCondition.good,
    status: CopyStatus.lost,
    acquired: '02 Feb 2024',
    borrower: 'Ramesh Shrestha',
  ),
  CatalogCopy(
    id: 'c-8',
    barcode: 'KH-000455',
    titleId: 't-3',
    titleName: 'Introduction to Algorithms',
    shelf: 'CS 005.1',
    condition: CopyCondition.asNew,
    status: CopyStatus.available,
    acquired: '18 Jan 2025',
  ),
  CatalogCopy(
    id: 'c-9',
    barcode: 'KH-000456',
    titleId: 't-3',
    titleName: 'Introduction to Algorithms',
    shelf: 'CS 005.1',
    condition: CopyCondition.asNew,
    status: CopyStatus.onLoan,
    acquired: '18 Jan 2025',
    borrower: 'Prakash Adhikari',
    dueDate: '22 Sep 2026',
  ),
  CatalogCopy(
    id: 'c-10',
    barcode: 'KH-000501',
    titleId: 't-5',
    titleName: 'Sapiens',
    shelf: 'HIS 909',
    condition: CopyCondition.good,
    status: CopyStatus.available,
    acquired: '21 Sep 2024',
  ),
  CatalogCopy(
    id: 'c-11',
    barcode: 'KH-000502',
    titleId: 't-5',
    titleName: 'Sapiens',
    shelf: 'HIS 909',
    condition: CopyCondition.fair,
    status: CopyStatus.overdue,
    acquired: '21 Sep 2024',
    borrower: 'Nisha Karki',
    dueDate: '25 Aug 2026',
  ),
  CatalogCopy(
    id: 'c-12',
    barcode: 'KH-000640',
    titleId: 't-8',
    titleName: 'Everest: Beyond the Limit',
    shelf: 'AV 796.522',
    condition: CopyCondition.good,
    status: CopyStatus.withdrawn,
    acquired: '19 Jun 2024',
  ),
];

/// The authors credited across [placeholderTitles].
const List<CatalogAuthor> placeholderAuthors = [
  CatalogAuthor(
    id: 'a-1',
    name: 'Narayan Wagle',
    titleCount: 3,
    lifespan: 'b. 1968',
    nationality: 'Nepali',
    biography:
        'Journalist and novelist, long-time editor of a Kathmandu daily, whose '
        'first novel became one of the best-selling Nepali books of its decade.',
  ),
  CatalogAuthor(
    id: 'a-2',
    name: 'Chinua Achebe',
    titleCount: 5,
    lifespan: '1930 – 2013',
    nationality: 'Nigerian',
    biography:
        'Novelist, poet and critic, whose first novel is among the most widely '
        'read works of African literature.',
  ),
  CatalogAuthor(
    id: 'a-3',
    name: 'Laxmi Prasad Devkota',
    titleCount: 12,
    lifespan: '1909 – 1959',
    nationality: 'Nepali',
    biography:
        'Poet, essayist and playwright, known in Nepal as Mahakavi — the great '
        'poet — for a body of work written largely in the last decade of his life.',
  ),
  CatalogAuthor(
    id: 'a-4',
    name: 'Thomas H. Cormen',
    titleCount: 2,
    lifespan: 'b. 1956',
    nationality: 'American',
    biography:
        'Computer scientist and co-author of a standard algorithms text.',
  ),
  CatalogAuthor(
    id: 'a-5',
    name: 'Yuval Noah Harari',
    titleCount: 4,
    lifespan: 'b. 1976',
    nationality: 'Israeli',
  ),
  CatalogAuthor(
    id: 'a-6',
    name: 'Stephen Hawking',
    titleCount: 6,
    lifespan: '1942 – 2018',
    nationality: 'British',
    biography:
        'Theoretical physicist and cosmologist whose popular science writing '
        'reached an audience far beyond the field.',
  ),
];

/// Copies belonging to [titleId], as the title's detail pane needs them.
List<CatalogCopy> placeholderCopiesOf(String titleId) => [
  for (final copy in placeholderCopies)
    if (copy.titleId == titleId) copy,
];

/// The title behind an id, falling back to the first record so a deep link to
/// an id that no longer exists renders a page rather than a crash. The real
/// screen answers this with a not-found state from the query instead.
CatalogTitle placeholderTitleById(String id) => placeholderTitles.firstWhere(
  (title) => title.id == id,
  orElse: () => placeholderTitles.first,
);

/// The author behind an id, with the same fallback as [placeholderTitleById].
CatalogAuthor placeholderAuthorById(String id) => placeholderAuthors.firstWhere(
  (author) => author.id == id,
  orElse: () => placeholderAuthors.first,
);
