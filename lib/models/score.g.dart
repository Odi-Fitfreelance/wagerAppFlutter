// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Score _$ScoreFromJson(Map<String, dynamic> json) => Score(
  id: json['id'] as String,
  betId: json['bet_id'] as String,
  userId: json['participant_id'] as String,
  holeNumber: (json['hole_number'] as num).toInt(),
  strokes: (json['score'] as num).toInt(),
  par: (json['par'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ScoreToJson(Score instance) => <String, dynamic>{
  'id': instance.id,
  'bet_id': instance.betId,
  'participant_id': instance.userId,
  'hole_number': instance.holeNumber,
  'score': instance.strokes,
  'par': instance.par,
  'created_at': instance.createdAt.toIso8601String(),
};

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
  id: json['id'] as String,
  name: json['name'] as String,
  location: json['location'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  holeCount: (json['hole_count'] as num).toInt(),
  pars: (json['pars'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  totalPar: (json['total_par'] as num).toInt(),
  description: json['description'] as String?,
);

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'location': instance.location,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'hole_count': instance.holeCount,
  'pars': instance.pars,
  'total_par': instance.totalPar,
  'description': instance.description,
};
