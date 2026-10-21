class AdminUserModel {
  final int id;
  final String name;
  final String email;
  final String roleName;
  final DateTime createdAt;
  final int voiceProfileCount;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roleName,
    required this.createdAt,
    required this.voiceProfileCount,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      roleName: json['role_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      voiceProfileCount: json['voice_profile_count'] as int,
    );
  }
}

class AdminStatsModel {
  final int totalUsers;
  final int totalVoiceProfiles;
  final Map<String, int> profilesByStatus;
  final int totalRecordings;
  final int totalSynthesizedPhrases;
  final int totalRatings;
  final double? averageMos;

  AdminStatsModel({
    required this.totalUsers,
    required this.totalVoiceProfiles,
    required this.profilesByStatus,
    required this.totalRecordings,
    required this.totalSynthesizedPhrases,
    required this.totalRatings,
    required this.averageMos,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['total_users'] as int,
      totalVoiceProfiles: json['total_voice_profiles'] as int,
      profilesByStatus: Map<String, int>.from(json['profiles_by_status'] as Map),
      totalRecordings: json['total_recordings'] as int,
      totalSynthesizedPhrases: json['total_synthesized_phrases'] as int,
      totalRatings: json['total_ratings'] as int,
      averageMos: json['average_mos'] == null ? null : (json['average_mos'] as num).toDouble(),
    );
  }
}
