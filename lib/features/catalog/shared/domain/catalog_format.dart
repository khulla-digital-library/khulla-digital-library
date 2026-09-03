/// The media a title is held in.
///
/// A catalogue that only knows about books stops being useful the first time
/// a library accessions a journal run or a DVD, so the format is on the title
/// from the start rather than bolted on later.
enum CatalogFormat { book, journal, magazine, audio, video, digital }
