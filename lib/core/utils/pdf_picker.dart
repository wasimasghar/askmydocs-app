import 'package:file_picker/file_picker.dart';

/// A PDF chosen by the user, loaded into memory.
typedef PickedPdf = ({String name, List<int> bytes});

/// Opens the system file picker restricted to PDFs.
abstract final class PdfPicker {
  /// Returns the picked PDF, or null if the user cancelled.
  ///
  /// Uses `withData: true` so the bytes are available on web, where files
  /// have no path. Throws [StateError] if the file could not be read.
  static Future<PickedPdf?> pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) throw StateError('No data for ${file.name}');
    return (name: file.name, bytes: bytes);
  }
}
