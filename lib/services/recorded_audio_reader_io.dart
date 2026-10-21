import 'dart:io';
import 'dart:typed_data';

/// En Android/iOS/desktop, AudioRecorder.stop() devuelve una ruta de archivo
/// real en el almacenamiento del dispositivo.
Future<Uint8List> readRecordedAudio(String path) => File(path).readAsBytes();
