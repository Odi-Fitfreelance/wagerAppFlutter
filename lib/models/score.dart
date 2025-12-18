import 'package:json_annotation/json_annotation.dart';

part 'score.g.dart';

@JsonSerializable()
class Score {
  final String id;
  @JsonKey(name: 'bet_id')
  final String betId;
  @JsonKey(name: 'participant_id')
  final String userId;
  @JsonKey(name: 'hole_number')
  final int holeNumber;
  @JsonKey(name: 'score')
  final int strokes;
  final int par;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Score({
    required this.id,
    required this.betId,
    required this.userId,
    required this.holeNumber,
    required this.strokes,
    required this.par,
    required this.createdAt,
  });

  // Calculate to_par from score and par
  int get toPar => strokes - par;

  factory Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreToJson(this);

  String get scoreLabel {
    if (toPar == -3) return 'Albatross';
    if (toPar == -2) return 'Eagle';
    if (toPar == -1) return 'Birdie';
    if (toPar == 0) return 'Par';
    if (toPar == 1) return 'Bogey';
    if (toPar == 2) return 'Double Bogey';
    return '+$toPar';
  }
}

@JsonSerializable()
class Course {
  final String id;
  final String name;
  final String? location;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'hole_count')
  final int holeCount;
  final List<int>? pars;
  @JsonKey(name: 'total_par')
  final int totalPar;
  final String? description;

  Course({
    required this.id,
    required this.name,
    this.location,
    this.latitude,
    this.longitude,
    required this.holeCount,
    this.pars,
    required this.totalPar,
    this.description,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);
}
