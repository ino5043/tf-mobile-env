import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

import 'package:educards/core/usecases/usecase.dart';
import '../../data/services/deck_import_service.dart';

class ImportDeckParams extends Equatable {
  const ImportDeckParams();

  @override
  List<Object> get props => [];
}

class ImportDeckUseCase extends UseCase<List<Map<String, String>>, ImportDeckParams> {
  final DeckImportService importService;

  ImportDeckUseCase(this.importService);

  @override
  Future<List<Map<String, String>>> call(ImportDeckParams params) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return [];
    }

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      throw Exception('Could not read file contents');
    }

    final content = String.fromCharCodes(bytes);
    final fileName = file.name;

    return importService.parseFile(fileName, content);
  }
}
