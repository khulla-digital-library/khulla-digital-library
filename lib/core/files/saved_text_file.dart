/// Result of saving a text file, so a toast can name the path on native.
class SavedTextFile {
  const SavedTextFile({required this.filename, this.path});

  final String filename;

  /// Absolute path on native. Null on web, where the browser chose the folder.
  final String? path;
}
