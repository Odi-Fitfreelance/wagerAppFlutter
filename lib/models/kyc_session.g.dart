// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KYCSession _$KYCSessionFromJson(Map<String, dynamic> json) => KYCSession(
  sessionId: json['sessionId'] as String?,
  status: $enumDecode(_$KYCStatusEnumMap, json['status']),
  message: json['message'] as String?,
  submittedAt: json['submitted_at'] == null
      ? null
      : DateTime.parse(json['submitted_at'] as String),
  reviewedAt: json['reviewed_at'] == null
      ? null
      : DateTime.parse(json['reviewed_at'] as String),
  rejectionReason: json['rejection_reason'] as String?,
  estimatedReviewTime: json['estimated_review_time'] as String?,
);

Map<String, dynamic> _$KYCSessionToJson(KYCSession instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'status': _$KYCStatusEnumMap[instance.status]!,
      'message': instance.message,
      'submitted_at': instance.submittedAt?.toIso8601String(),
      'reviewed_at': instance.reviewedAt?.toIso8601String(),
      'rejection_reason': instance.rejectionReason,
      'estimated_review_time': instance.estimatedReviewTime,
    };

const _$KYCStatusEnumMap = {
  KYCStatus.notSubmitted: 'not_submitted',
  KYCStatus.pending: 'pending',
  KYCStatus.completed: 'completed',
  KYCStatus.approved: 'approved',
  KYCStatus.rejected: 'rejected',
  KYCStatus.manualReview: 'manual_review',
};

KYCSubmissionRequest _$KYCSubmissionRequestFromJson(
  Map<String, dynamic> json,
) => KYCSubmissionRequest(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  dateOfBirth: json['dateOfBirth'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  address: json['address'] as String,
  city: json['city'] as String,
  state: json['state'] as String,
  zipCode: json['zipCode'] as String,
  country: json['country'] as String? ?? 'US',
);

Map<String, dynamic> _$KYCSubmissionRequestToJson(
  KYCSubmissionRequest instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'dateOfBirth': instance.dateOfBirth,
  'email': instance.email,
  'phone': instance.phone,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'zipCode': instance.zipCode,
  'country': instance.country,
};
