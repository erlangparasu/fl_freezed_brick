import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '{{input_filename.snakeCase()}}.freezed.dart';
part '{{input_filename.snakeCase()}}.g.dart';

@freezed
class {{input_filename.pascalCase()}} with _${{input_filename.pascalCase()}} {
  @JsonSerializable(explicitToJson: true)
  const factory {{input_filename.pascalCase()}}({
    @JsonKey(name: 'search') String? search,
    @JsonKey(name: 'id') String? id,
  }) = _{{input_filename.pascalCase()}};

  factory {{input_filename.pascalCase()}}.fromJson(
    Map<String, Object?> json,
  ) =>
      _${{input_filename.pascalCase()}}FromJson(json);
}

FutureOr<Response<dynamic>> responseConverterFor{{input_filename.pascalCase()}}(
  Response<dynamic> response,
) {
  final bodyString = response.bodyString;
  final jsonMap = jsonDecode(bodyString) as Map<String, dynamic>;
  final model = {{input_filename.pascalCase()}}.fromJson(jsonMap);
  return response.copyWith(body: model);
}
