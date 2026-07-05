import 'package:freezed_annotation/freezed_annotation.dart';

part 'common_dtos.freezed.dart';
part 'common_dtos.g.dart';

/// The backend's common error body:
///
/// ```json
/// { "error": "string" }
/// ```
///
/// Kept here as a shared DTO; `ErrorMapper` extracts the message directly from
/// raw response data, but this typed model is available where a decoded shape
/// is preferable.
@freezed
class ServerErrorBody with _$ServerErrorBody {
  const factory ServerErrorBody({
    @Default('') String error,
  }) = _ServerErrorBody;

  factory ServerErrorBody.fromJson(Map<String, dynamic> json) =>
      _$ServerErrorBodyFromJson(json);
}
