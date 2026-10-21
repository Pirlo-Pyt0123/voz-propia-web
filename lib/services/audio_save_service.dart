import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Guarda audio generado en el almacenamiento del dispositivo, en una
/// carpeta propia de la app (visible con cualquier explorador de archivos).
class AudioSaveService {
  static Future<String> saveAudio(Uint8List bytes, String filename) async {
    final baseDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final vozPropiaDir = Directory('${baseDir.path}/VozPropia');
    if (!await vozPropiaDir.exists()) {
      await vozPropiaDir.create(recursive: true);
    }
    final file = File('${vozPropiaDir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
