import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/synthesized_phrase.dart';
import '../models/voice_profile.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../services/app_preferences.dart';
import '../services/audio_save_service.dart';
import '../services/auth_controller.dart';
import '../theme/brutal_theme.dart';
import '../widgets/brutal_background.dart';
import '../widgets/brutal_button.dart';
import '../widgets/brutal_card.dart';
import '../widgets/brutal_icon_button.dart';
import '../widgets/brutal_text_field.dart';

class SynthesisScreen extends StatefulWidget {
  final VoiceProfile profile;

  const SynthesisScreen({super.key, required this.profile});

  @override
  State<SynthesisScreen> createState() => _SynthesisScreenState();
}

class _SynthesisScreenState extends State<SynthesisScreen> {
  final _textController = TextEditingController();
  final _player = AudioPlayer();

  List<SynthesizedPhraseModel> _phrases = [];
  bool _loading = true;
  bool _generating = false;
  int? _playingId;
  String? _error;

  ApiClient get _api => context.read<AuthController>().api;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _textController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final raw = await _api.listPhrases(widget.profile.id);
      _phrases = raw
          .map((e) => SynthesizedPhraseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _generate() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _generating = true);
    try {
      final taskId = await _api.synthesizePhrase(widget.profile.id, text);
      final phraseId = await _pollSynthesis(taskId);
      _textController.clear();
      await _load();
      if (phraseId != null && await AppPreferences.getAutoSaveAudio()) {
        await _autoSaveAudio(phraseId);
      }
    } on ApiException catch (e) {
      _showSnack(e.message);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<int?> _pollSynthesis(String taskId) async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 1));
      final status = await _api.getSynthesisStatus(taskId);
      final state = status['status'] as String;
      if (state == 'SUCCESS') {
        final phrase = status['phrase'] as Map<String, dynamic>?;
        return phrase?['id'] as int?;
      }
      if (state == 'FAILURE') {
        throw ApiException((status['error'] as String?) ?? 'Falló la síntesis de voz.');
      }
    }
    return null;
  }

  Future<void> _autoSaveAudio(int phraseId) async {
    try {
      final bytes = await _api.fetchAudioBytes(
        '/voice-profiles/${widget.profile.id}/phrases/$phraseId/audio',
      );
      final path = await AudioSaveService.saveAudio(bytes, 'frase_$phraseId.mp3');
      if (mounted) _showSnack('Audio guardado en $path');
    } catch (_) {
      if (mounted) _showSnack('No se pudo guardar el audio en el dispositivo.');
    }
  }

  Future<void> _play(SynthesizedPhraseModel phrase) async {
    setState(() => _playingId = phrase.id);
    try {
      final bytes = await _api.fetchAudioBytes(
        '/voice-profiles/${widget.profile.id}/phrases/${phrase.id}/audio',
      );
      await _player.play(BytesSource(bytes, mimeType: 'audio/mpeg'));
    } on ApiException catch (e) {
      _showSnack(e.message);
    } finally {
      if (mounted) setState(() => _playingId = null);
    }
  }

  Future<void> _ratePhrase(SynthesizedPhraseModel phrase, int rating) async {
    final previous = _phrases;
    setState(() {
      _phrases = _phrases
          .map((p) => p.id == phrase.id ? p.copyWith(rating: rating) : p)
          .toList();
    });
    try {
      await _api.ratePhrase(widget.profile.id, phrase.id, rating);
    } on ApiException catch (e) {
      setState(() => _phrases = previous);
      _showSnack(e.message);
    }
  }

  Future<void> _deletePhrase(SynthesizedPhraseModel phrase) async {
    final previous = _phrases;
    setState(() => _phrases = _phrases.where((p) => p.id != phrase.id).toList());
    try {
      await _api.deletePhrase(widget.profile.id, phrase.id);
    } on ApiException catch (e) {
      setState(() => _phrases = previous);
      _showSnack(e.message);
    }
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: BrutalColors.ink.withValues(alpha: 0.55),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: brutalDecoration(
              fill: BrutalColors.cream,
              radius: 20,
              borderWidth: 3,
              shadowOffset: const Offset(7, 7),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Vaciar todo el historial?',
                  style: TextStyle(color: BrutalColors.ink, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  'Se van a borrar las ${_phrases.length} frases generadas para este perfil. No se puede deshacer.',
                  style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.7), fontSize: 13.5),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: BrutalColors.ink, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text(
                        'Vaciar',
                        style: TextStyle(color: BrutalColors.red, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final previous = _phrases;
    setState(() => _phrases = []);
    try {
      await _api.deleteAllPhrases(widget.profile.id);
    } on ApiException catch (e) {
      setState(() => _phrases = previous);
      _showSnack(e.message);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.profile.profileName,
                  style: const TextStyle(color: BrutalColors.ink, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Escribí un texto y escuchalo con tu voz clonada.',
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
                      const Text(
                        'Texto a sintetizar',
                        style: TextStyle(color: BrutalColors.ink, fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      BrutalTextField(
                        controller: _textController,
                        hintText: 'Escribí acá lo que querés escuchar con tu voz...',
                        icon: Icons.edit_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      BrutalButton(
                        label: _generating ? 'Generando…' : 'Generar audio',
                        onPressed: _generating ? null : _generate,
                        loading: _generating,
                        color: BrutalColors.pink,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Historial',
                      style: TextStyle(color: BrutalColors.ink, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    if (_phrases.isNotEmpty)
                      GestureDetector(
                        onTap: _confirmClearHistory,
                        child: Row(
                          children: [
                            Icon(Icons.delete_sweep_rounded, color: BrutalColors.ink.withValues(alpha: 0.7), size: 18),
                            const SizedBox(width: 4),
                            Text(
                              'Vaciar todo',
                              style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.7), fontSize: 12.5, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator(color: BrutalColors.ink)),
                  )
                else if (_phrases.isEmpty)
                  BrutalCard(
                    child: Text(
                      'Todavía no generaste ninguna frase.',
                      style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.7)),
                    ),
                  )
                else
                  ..._phrases.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PhraseRow(
                        phrase: p,
                        playing: _playingId == p.id,
                        onPlay: () => _play(p),
                        onDelete: () => _deletePhrase(p),
                        onRate: (rating) => _ratePhrase(p, rating),
                      ),
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

class _PhraseRow extends StatelessWidget {
  final SynthesizedPhraseModel phrase;
  final bool playing;
  final VoidCallback onPlay;
  final VoidCallback onDelete;
  final ValueChanged<int> onRate;

  const _PhraseRow({
    required this.phrase,
    required this.playing,
    required this.onPlay,
    required this.onDelete,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: playing ? null : onPlay,
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: BrutalColors.pink,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: BrutalColors.ink, width: 2),
                  ),
                  child: playing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: BrutalColors.ink),
                        )
                      : const Icon(Icons.play_arrow_rounded, color: BrutalColors.ink, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '"${phrase.inputText}"',
                  style: const TextStyle(color: BrutalColors.ink, fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
              ),
              if (phrase.durationSeconds != null)
                Text(
                  '${phrase.durationSeconds!.toStringAsFixed(1)}s',
                  style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.6), fontSize: 12),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.delete_outline_rounded, color: BrutalColors.ink.withValues(alpha: 0.55), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '¿Qué tan bien salió?',
                style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.55), fontSize: 11.5),
              ),
              const SizedBox(width: 8),
              _StarRating(rating: phrase.rating, onRate: onRate),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int? rating;
  final ValueChanged<int> onRate;

  const _StarRating({required this.rating, required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final filled = rating != null && starValue <= rating!;
        return GestureDetector(
          onTap: () => onRate(starValue),
          child: Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: filled ? BrutalColors.yellow : BrutalColors.ink.withValues(alpha: 0.35),
              size: 20,
            ),
          ),
        );
      }),
    );
  }
}
