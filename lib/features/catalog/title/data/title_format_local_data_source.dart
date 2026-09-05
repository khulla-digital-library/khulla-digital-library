import 'package:khulla/features/catalog/title/domain/models/title_format.dart';

abstract interface class TitleFormatLocalDataSource {
  Future<int> countFormats();

  Future<List<TitleFormat>> findActiveFormats();

  Future<TitleFormat> insertFormat(TitleFormat format);
}
