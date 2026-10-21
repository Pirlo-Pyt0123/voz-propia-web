class AudioRecordingModel {
  final int id;
  final int voiceProfileId;
  final String phraseText;
  final double durationSeconds;
  final bool qualityValidated;
  final DateTime recordedAt;

  AudioRecordingModel({
    required this.id,
    required this.voiceProfileId,
    required this.phraseText,
    required this.durationSeconds,
    required this.qualityValidated,
    required this.recordedAt,
  });

  factory AudioRecordingModel.fromJson(Map<String, dynamic> json) {
    return AudioRecordingModel(
      id: json['id'] as int,
      voiceProfileId: json['voice_profile_id'] as int,
      phraseText: json['phrase_text'] as String,
      durationSeconds: double.parse(json['duration_seconds'].toString()),
      qualityValidated: json['quality_validated'] as bool,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }
}
