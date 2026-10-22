enum SolvePenalty {
  none,
  plusTwo,
  dnf,
}

/// Represents an individual recorded solve attempt.
class SolveModel {
  final String id;
  final String userId;
  final String profileId;
  final int rawTimeMs;
  final SolvePenalty penalty;
  final String scramble;
  final DateTime recordedAt;

  const SolveModel({
    required this.id,
    required this.userId,
    required this.profileId,
    required this.rawTimeMs,
    this.penalty = SolvePenalty.none,
    required this.scramble,
    required this.recordedAt,
  });

  /// Effective duration accounting for WCA penalties (+2s or DNF).
  int? get effectiveTimeMs {
    if (penalty == SolvePenalty.dnf) return null;
    if (penalty == SolvePenalty.plusTwo) return rawTimeMs + 2000;
    return rawTimeMs;
  }

  bool get isDnf => penalty == SolvePenalty.dnf;
  bool get isPlusTwo => penalty == SolvePenalty.plusTwo;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'profileId': profileId,
        'rawTimeMs': rawTimeMs,
        'penalty': penalty.name,
        'scramble': scramble,
        'recordedAt': recordedAt.toIso8601String(),
      };

  factory SolveModel.fromJson(Map<String, dynamic> json) => SolveModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        profileId: json['profileId'] as String,
        rawTimeMs: json['rawTimeMs'] as int,
        penalty: SolvePenalty.values.firstWhere(
          (p) => p.name == json['penalty'],
          orElse: () => SolvePenalty.none,
        ),
        scramble: json['scramble'] as String? ?? '',
        recordedAt: DateTime.tryParse(json['recordedAt'] as String? ?? '') ?? DateTime.now(),
      );

  SolveModel copyWith({
    SolvePenalty? penalty,
  }) {
    return SolveModel(
      id: id,
      userId: userId,
      profileId: profileId,
      rawTimeMs: rawTimeMs,
      penalty: penalty ?? this.penalty,
      scramble: scramble,
      recordedAt: recordedAt,
    );
  }
}
