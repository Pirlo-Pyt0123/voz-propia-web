class SynthesizedPhraseModel {
  final int id;
  final int voiceProfileId;
  final String inputText;
  final double? durationSeconds;
  final DateTime generatedAt;
  final int? rating;

  SynthesizedPhraseModel({
    required this.id,
    required this.voiceProfileId,
    required this.inputText,
    required this.durationSeconds,
    required this.generatedAt,
    required this.rating,
  });

  factory SynthesizedPhraseModel.fromJson(Map<String, dynamic> json) {
    return SynthesizedPhraseModel(
      id: json['id'] as int,
      voiceProfileId: json['voice_profile_id'] as int,
      inputText: json['input_text'] as String,
      durationSeconds: json['duration_seconds'] == null
          ? null
          : double.parse(json['duration_seconds'].toString()),
      generatedAt: DateTime.parse(json['generated_at'] as String),
      rating: json['rating'] as int?,
    );
  }

  SynthesizedPhraseModel copyWith({int? rating}) {
    return SynthesizedPhraseModel(
      id: id,
      voiceProfileId: voiceProfileId,
      inputText: inputText,
      durationSeconds: durationSeconds,
      generatedAt: generatedAt,
      rating: rating ?? this.rating,
    );
  }
}
