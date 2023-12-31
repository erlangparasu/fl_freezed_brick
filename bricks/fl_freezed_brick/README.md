# fl_freezed_brick

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

A new brick created with the Mason CLI.

<!--
## How To Use

Example

Run in terminal:


```bash
mason make fl_freezed_brick

# ? Input the class name (may contains spaces): My Get Profile Response
```

File `my_get_profile_response.dart` will generated for you.

Contents of generated file:

```dart
import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_get_profile_response.freezed.dart';
part 'my_get_profile_response.g.dart';

@freezed
class MyGetProfileResponse with _$MyGetProfileResponse {
  @JsonSerializable(explicitToJson: true)
  const factory MyGetProfileResponse({
    @JsonKey(name: 'search') String? search,
    @JsonKey(name: 'id') String? id,
  }) = _MyGetProfileResponse;

  factory MyGetProfileResponse.fromJson(
    Map<String, Object?> json,
  ) =>
      _$MyGetProfileResponseFromJson(json);
}

FutureOr<Response<dynamic>> responseConverterForMyGetProfileResponse(
  Response<dynamic> response,
) {
  var bodyString = response.bodyString;
  if (bodyString.startsWith('[') && bodyString.endsWith(']')) {
    final modifiedBodyString = '{"data":\$bodyString}';
    bodyString = modifiedBodyString;
  }
  final jsonMap = jsonDecode(bodyString) as Map<String, dynamic>;
  final model = MyGetProfileResponse.fromJson(jsonMap);
  return response.copyWith(body: model);
}
```

-->

## About

dart, flutter, freezed, json, chopper, mason, brick.

---

Erlang Parasu @ 2023
