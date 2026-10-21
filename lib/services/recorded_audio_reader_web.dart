import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// En Flutter Web, AudioRecorder.stop() devuelve una blob URL con el audio
/// ya grabado en memoria del navegador; hay que bajarla para obtener los
/// bytes reales.
Future<Uint8List> readRecordedAudio(String path) async {
  final res = await http.get(Uri.parse(path));
  return res.bodyBytes;
}
