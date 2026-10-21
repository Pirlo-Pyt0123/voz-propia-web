import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../models/audio_recording.dart';
import '../models/voice_profile.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../services/auth_controller.dart';
import '../services/recorded_audio_reader.dart';
import '../theme/brutal_theme.dart';
import '../widgets/brutal_background.dart';
import '../widgets/brutal_button.dart';
import '../widgets/brutal_card.dart';
import '../widgets/brutal_icon_button.dart';
import 'synthesis_screen.dart';

/// Guion de frases fonéticamente variadas para guiar la grabación del banco
/// de voz. Se van pidiendo en orden, ciclando si el usuario graba más de las
/// que hay acá. Frases largas (8-10s leídas a ritmo normal) a propósito: XTTS-v2
/// clona mucho mejor con grabaciones largas que con frases cortas de 2-3s.
const _kScript = <String>[
  'La voz propia es una forma de identidad que nos acompaña desde la infancia, '
      'y que a veces olvidamos lo importante que es hasta que corremos el riesgo de perderla.',
  'Hoy el cielo está despejado y hace bastante frío, así que me puse una chaqueta '
      'gruesa antes de salir a caminar temprano por el barrio.',
  'Necesito que me ayudes con esto, por favor, porque solo no voy a poder terminarlo '
      'a tiempo y la fecha de entrega ya está bastante cerca.',
  'El café de la mañana me despierta lentamente mientras escucho las noticias '
      'y pienso en todo lo que tengo que hacer durante el día.',
  'Quiero volver a escuchar mi propia voz contando historias, cantando canciones '
      'y diciendo cosas simples como buenos días o te quiero mucho.',
  'Gracias por acompañarme en este proceso tan importante para mí, de verdad '
      'no sé qué habría hecho sin la paciencia y el apoyo de toda mi familia.',
  'La tecnología puede devolver lo que se pierde cuando se usa con cuidado, '
      'con respeto y pensando siempre en las personas que más la necesitan.',
  'Mañana vamos a caminar por el parque si el clima ayuda un poco, y de paso '
      'aprovechamos para comprar pan fresco en la panadería de la esquina.',
];

const _kMinDurationHint = 6.0;

/// Debe coincidir con MIN_VALIDATED_DURATION_SECONDS_FOR_TRAINING del backend
/// (solo se usa acá para mostrar el progreso; el backend valida el umbral real).
const _kMinTotalDurationForTraining = 15.0;

class RecordingsScreen extends StatefulWidget {
  final VoiceProfile profile;

  const RecordingsScreen({super.key, required this.profile});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> with SingleTickerProviderStateMixin {
  final _recorder = AudioRecorder();
  late final AnimationController _readingController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  late VoiceProfile _profile;
  List<AudioRecordingModel> _recordings = [];
  bool _loading = true;
  bool _isRecording = false;
  bool _uploading = false;
  bool _importingFile = false;
  bool _training = false;
  String? _error;

  ApiClient get _api => context.read<AuthController>().api;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _load();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _readingController.dispose();
    super.dispose();
  }

  int get _validatedCount => _recordings.where((r) => r.qualityValidated).length;

  double get _validatedDuration => _recordings
      .where((r) => r.qualityValidated)
      .fold(0.0, (sum, r) => sum + r.durationSeconds);

  String get _currentPhrase => _kScript[_recordings.length % _kScript.length];

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final raw = await _api.listRecordings(_profile.id);
      _recordings = raw
          .map((e) => AudioRecordingModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final profileData = await _api.getVoiceProfile(_profile.id);
      _profile = VoiceProfile.fromJson(profileData);
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      _readingController.stop();
      _readingController.reset();
      setState(() => _isRecording = false);
      if (path != null) {
        await _uploadRecording(path);
      }
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        _showSnack('Necesitamos permiso del micrófono para grabar.');
      }
      return;
    }

    // En Android/iOS/desktop, `path` tiene que ser una ruta real y escribible
    // (si no, falla con "EROFS: Read-only file system"). En web se ignora,
    // así que usar el directorio temporal de la app funciona en todos lados.
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(const RecordConfig(encoder: AudioEncoder.wav), path: path);
    setState(() => _isRecording = true);

    // Guía de lectura tipo "karaoke": resalta las palabras de a poco a un
    // ritmo de lectura pausado, para ayudar a leer la frase mientras se graba.
    const wordsPerSecond = 2.3;
    final wordCount = _currentPhrase.split(' ').length;
    final estimatedSeconds = (wordCount / wordsPerSecond).clamp(3.0, 60.0);
    _readingController.duration = Duration(milliseconds: (estimatedSeconds * 1000).round());
    _readingController.forward(from: 0);
  }

  Future<void> _uploadRecording(String path) async {
    setState(() => _uploading = true);
    try {
      final bytes = await readRecordedAudio(path);
      await _api.uploadRecording(
        profileId: _profile.id,
        phraseText: _currentPhrase,
        bytes: bytes,
        filename: 'recording.wav',
      );
      await _load();
    } on ApiException catch (e) {
      _showSnack(e.message);
    } catch (_) {
      _showSnack('No se pudo subir la grabación. Probá de nuevo.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _pickAndUploadFile() async {
    final file = await FilePicker.pickFile(type: FileType.audio);
    if (file == null) return;

    final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      _showSnack('No se pudo leer el archivo seleccionado.');
      return;
    }

    setState(() => _importingFile = true);
    try {
      await _api.uploadRecording(
        profileId: _profile.id,
        phraseText: 'Audio importado: ${file.name}',
        bytes: bytes,
        filename: file.name,
      );
      await _load();
    } on ApiException catch (e) {
      _showSnack(e.message);
    } catch (_) {
      _showSnack('No se pudo subir el archivo. Probá de nuevo.');
    } finally {
      if (mounted) setState(() => _importingFile = false);
    }
  }

  Future<void> _train() async {
    setState(() => _training = true);
    try {
      await _api.trainVoiceProfile(_profile.id);
      await _pollTrainingStatus();
    } on ApiException catch (e) {
      _showSnack(e.message);
      setState(() => _training = false);
    }
  }

  Future<void> _pollTrainingStatus() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      try {
        final data = await _api.getVoiceProfile(_profile.id);
        final profile = VoiceProfile.fromJson(data);
        if (!mounted) return;
        setState(() => _profile = profile);
        if (profile.trainingStatus != 'training') {
          setState(() => _training = false);
          if (profile.trainingStatus == 'error') {
            _showSnack('Falló el entrenamiento del perfil. Probá de nuevo.');
          }
          return;
        }
      } on ApiException catch (e) {
        _showSnack(e.message);
        if (mounted) setState(() => _training = false);
        return;
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _profile.trainingStatus == 'ready';
    final isTraining = _training || _profile.trainingStatus == 'training';

    return Scaffold(
      body: BrutalBackground(
        child: SafeArea(
          child: RefreshIndicator(
            color: BrutalColors.ink,
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    BrutalIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    if (isReady)
                      BrutalIconButton(
                        icon: Icons.record_voice_over_rounded,
                        fill: BrutalColors.pink,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => SynthesisScreen(profile: _profile)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _profile.profileName,
                  style: const TextStyle(color: BrutalColors.ink, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Grabá las muestras de tu voz para armar tu banco de voz.',
                  style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.7), fontSize: 14),
                ),
                const SizedBox(height: 20),
                if (_error != null)
                  BrutalCard(
                    fill: BrutalColors.red,
                    child: Text(_error!, style: const TextStyle(color: BrutalColors.cream, fontWeight: FontWeight.w700)),
                  ),
                BrutalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Estado del entrenamiento',
                            style: TextStyle(color: BrutalColors.ink, fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          _StatusBadge(status: _profile.trainingStatus, isTraining: isTraining),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _loading
                              ? 0
                              : (_validatedDuration / _kMinTotalDurationForTraining).clamp(0, 1),
                          minHeight: 14,
                          backgroundColor: BrutalColors.cream,
                          valueColor: const AlwaysStoppedAnimation(BrutalColors.green),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_validatedDuration.toStringAsFixed(1)}s de audio validado '
                        '($_validatedCount ${_validatedCount == 1 ? "grabación" : "grabaciones"}) '
                        '· mínimo ${_kMinTotalDurationForTraining.toStringAsFixed(0)}s para entrenar',
                        style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.65), fontSize: 12.5),
                      ),
                      const SizedBox(height: 14),
                      BrutalButton(
                        label: isReady ? 'Volver a entrenar' : 'Entrenar mi voz',
                        onPressed: isTraining ? null : _train,
                        loading: isTraining,
                        color: BrutalColors.purple,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                BrutalCard(
                  fill: _isRecording ? BrutalColors.red : BrutalColors.green,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isRecording ? 'Grabando…' : 'Frase a grabar',
                        style: const TextStyle(color: BrutalColors.ink, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      _ReadingGuideText(
                        phrase: _currentPhrase,
                        controller: _readingController,
                        active: _isRecording,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Grabá al menos ${_kMinDurationHint}s con voz clara.',
                        style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.6), fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                BrutalButton(
                  label: _isRecording ? 'Detener y subir' : 'Grabar nueva frase',
                  onPressed: _uploading || _importingFile ? null : _toggleRecording,
                  loading: _uploading,
                  color: _isRecording ? BrutalColors.red : BrutalColors.ink,
                ),
                const SizedBox(height: 10),
                BrutalButton(
                  label: 'Subir un audio existente',
                  onPressed: _isRecording || _uploading || _importingFile ? null : _pickAndUploadFile,
                  loading: _importingFile,
                  color: BrutalColors.purple,
                ),
                const SizedBox(height: 6),
                Text(
                  'Podés subir una nota de voz o grabación vieja en vez de leer el guion.',
                  style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.55), fontSize: 11.5),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tus grabaciones',
                  style: TextStyle(color: BrutalColors.ink, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator(color: BrutalColors.ink)),
                  )
                else if (_recordings.isEmpty)
                  BrutalCard(
                    child: Text(
                      'Todavía no grabaste ninguna frase.',
                      style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.7)),
                    ),
                  )
                else
                  ..._recordings.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RecordingRow(recording: r),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isTraining;

  const _StatusBadge({required this.status, required this.isTraining});

  @override
  Widget build(BuildContext context) {
    final effective = isTraining ? 'training' : status;
    final Color color;
    final String label;
    switch (effective) {
      case 'ready':
        color = BrutalColors.green;
        label = 'Listo';
        break;
      case 'training':
        color = BrutalColors.yellow;
        label = 'Entrenando';
        break;
      case 'error':
        color = BrutalColors.red;
        label = 'Error';
        break;
      default:
        color = BrutalColors.gray;
        label = 'Pendiente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrutalColors.ink, width: 1.5),
      ),
      child: Text(label, style: const TextStyle(color: BrutalColors.ink, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

class _RecordingRow extends StatelessWidget {
  final AudioRecordingModel recording;

  const _RecordingRow({required this.recording});

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 16,
      child: Row(
        children: [
          Icon(Icons.graphic_eq_rounded, color: BrutalColors.ink.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recording.phraseText,
              style: const TextStyle(color: BrutalColors.ink, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: recording.qualityValidated ? BrutalColors.green : BrutalColors.gray,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: BrutalColors.ink, width: 1.5),
            ),
            child: Text(
              recording.qualityValidated ? 'Validada' : 'Pendiente',
              style: const TextStyle(color: BrutalColors.ink, fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

/// Muestra la frase a leer resaltando las palabras de a poco en amarillo
/// (estilo karaoke) a medida que pasa el tiempo, para guiar el ritmo de
/// lectura mientras se graba.
class _ReadingGuideText extends StatelessWidget {
  final String phrase;
  final AnimationController controller;
  final bool active;

  const _ReadingGuideText({
    required this.phrase,
    required this.controller,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final words = phrase.split(' ');
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final highlightedCount = active
            ? (controller.value * words.length).ceil().clamp(0, words.length)
            : 0;
        return Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: '"'),
              for (var i = 0; i < words.length; i++)
                TextSpan(
                  text: i == words.length - 1 ? words[i] : '${words[i]} ',
                  style: TextStyle(
                    color: i < highlightedCount ? BrutalColors.cream : BrutalColors.ink.withValues(alpha: 0.35),
                  ),
                ),
              const TextSpan(text: '"'),
            ],
          ),
          style: const TextStyle(color: BrutalColors.ink, fontSize: 16, fontWeight: FontWeight.w800),
        );
      },
    );
  }
}
