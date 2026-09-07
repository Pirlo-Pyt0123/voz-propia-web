class VoiceProfile {
  final int id;
  final String profileName;
  final String trainingStatus;
  final String? modelPath;
  final DateTime createdAt;

  VoiceProfile({
    required this.id,
    required this.profileName,
    required this.trainingStatus,
    required this.modelPath,
    required this.createdAt,
  });

  factory VoiceProfile.fromJson(Map<String, dynamic> json) {
    return VoiceProfile(
      id: json['id'] as int,
      profileName: json['profile_name'] as String,
      trainingStatus: json['training_status'] as String,
      modelPath: json['model_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
