import 'package:json_annotation/json_annotation.dart';

part 'kyc_session.g.dart';

enum KYCStatus {
  @JsonValue('not_submitted')
  notSubmitted,
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('manual_review')
  manualReview,
}

@JsonSerializable()
class KYCSession {
  final String? sessionId;
  final KYCStatus status;
  final String? message;

  @JsonKey(name: 'submitted_at')
  final DateTime? submittedAt;

  @JsonKey(name: 'reviewed_at')
  final DateTime? reviewedAt;

  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;

  @JsonKey(name: 'estimated_review_time')
  final String? estimatedReviewTime;

  KYCSession({
    this.sessionId,
    required this.status,
    this.message,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
    this.estimatedReviewTime,
  });

  factory KYCSession.fromJson(Map<String, dynamic> json) =>
      _$KYCSessionFromJson(json);

  Map<String, dynamic> toJson() => _$KYCSessionToJson(this);

  /// Is KYC approved?
  bool get isApproved => status == KYCStatus.approved;

  /// Is KYC pending review?
  bool get isPending =>
      status == KYCStatus.pending || status == KYCStatus.manualReview;

  /// Is KYC rejected?
  bool get isRejected => status == KYCStatus.rejected;

  /// Can user start or retry KYC?
  bool get canRetry => status == KYCStatus.rejected || status == KYCStatus.notSubmitted;

  /// Status display text
  String get statusText {
    switch (status) {
      case KYCStatus.notSubmitted:
        return 'Not Submitted';
      case KYCStatus.pending:
        return 'Pending Review';
      case KYCStatus.completed:
        return 'Verification Complete';
      case KYCStatus.approved:
        return 'Approved ✓';
      case KYCStatus.rejected:
        return 'Rejected';
      case KYCStatus.manualReview:
        return 'Under Manual Review';
    }
  }

  /// Status color
  String get statusColor {
    switch (status) {
      case KYCStatus.notSubmitted:
        return 'grey';
      case KYCStatus.pending:
      case KYCStatus.manualReview:
        return 'orange';
      case KYCStatus.completed:
      case KYCStatus.approved:
        return 'green';
      case KYCStatus.rejected:
        return 'red';
    }
  }
}

@JsonSerializable()
class KYCSubmissionRequest {
  final String firstName;
  final String lastName;
  final String dateOfBirth; // YYYY-MM-DD format
  final String email;
  final String? phone;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  KYCSubmissionRequest({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.email,
    this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'US',
  });

  factory KYCSubmissionRequest.fromJson(Map<String, dynamic> json) =>
      _$KYCSubmissionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$KYCSubmissionRequestToJson(this);
}
