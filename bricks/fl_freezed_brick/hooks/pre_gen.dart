import 'dart:io';

import 'package:mason/mason.dart';

void run(HookContext context) {
  // Read vars.
  String filename = context.vars['input_filename'];

  // Use the `Logger` instance.
  context.logger.info('Generating file: $filename');

  // filename.camelCase;

  // Update vars.
  context.vars['current_year'] = DateTime.now().year;

  final theFilename = filename;
  var theFile = File(theFilename);
  final lines = theFile.readAsLinesSync();

  final linesInpUri = <String>[];
  final linesInpCurl = <String>[];
  final linesInpResponse = <String>[];

  final keywordInpUriStart = '<!-- inp_uri -->';
  final keywordInpUriEnd = '<!-- /inp_uri -->';

  final keywordInpCurlStart = '<!-- inp_curl -->';
  final keywordInpCurlEnd = '<!-- /inp_curl -->';

  final keywordInpResponseStart = '<!-- inp_response -->';
  final keywordInpResponseEnd = '<!-- /inp_response -->';

  bool captureUri = false;
  bool captureCurl = false;
  bool captureResponse = false;

  for (var line in lines) {
    // context.logger.info('line: $line');

    if (line.contains(keywordInpUriEnd)) {
      captureUri = false;
    }
    if (line.contains(keywordInpCurlEnd)) {
      captureCurl = false;
    }
    if (line.contains(keywordInpResponseEnd)) {
      captureResponse = false;
    }

    ///

    if (!line.contains('```')) {
      if (captureUri) {
        linesInpUri.add(line);
      }
      if (captureCurl) {
        linesInpCurl.add(line);
      }
      if (captureResponse) {
        linesInpResponse.add(line);
      }
    }

    ///

    if (line.contains(keywordInpUriStart)) {
      captureUri = true;
    }
    if (line.contains(keywordInpCurlStart)) {
      captureCurl = true;
    }
    if (line.contains(keywordInpResponseStart)) {
      captureResponse = true;
    }
  }

  print("---URI---");
  print(linesInpUri.join("\n"));

  print("---CURL---");
  print(linesInpCurl.join("\n"));

  print("---RESPONSE---");
  print(linesInpResponse.join("\n"));

  /// Url path.
  String inputUri = linesInpUri.first;
  print({'inputUri': inputUri});

  /// Response filename.
  String getDartFilename = convertUriToDartFilename(inputUri);
  print({'getDartFilename': getDartFilename});

  /// Response classname.
  String getDartClassname = convertUriToDartClassname(inputUri);
  print({'getDartClassname': getDartClassname});

  final folderNames = convertUriToFolderNames(inputUri);
  print({'folderNames': folderNames});

  final newFile =
      File('lib/models/${folderNames.join('/')}/${getDartFilename}');
  newFile.createSync(recursive: true);
  newFile.writeAsStringSync(
    generateDartFileContent(
      getDartFilename.replaceAll('.dart', ''),
      getDartClassname,
    ),
  );
}

String convertUriToDartFilename(String uri) {
  if (!uri.startsWith('/')) {
    throw Exception('Err: URI must start with a slash "/".');
  }

  // uri = uri.replaceAll('/api/', '/');

  final List<String> segmentList = uri.split("/");
  final List<String> segmentListFiltered = segmentList
      .map((item) => item.trim())
      .where((item) => !item.isEmpty)
      .map((e) => e.pascalCase)
      .toList();
  for (var segment in segmentListFiltered) {
    print(segment);
  }

  final joined = segmentListFiltered.last;
  return joined.snakeCase + '_response.dart';

  // "/api/Dashboard/getScheduleInspection"
  // "/Api/Dashboard/GetScheduleInspection"
  // "Api_Dashboard_GetScheduleInspection"
  // "Api_Dashboard_GetScheduleInspection_Response"
  // "Api_Dashboard_GetScheduleInspection_Response.dart"
}

String convertUriToDartClassname(String uri) {
  if (!uri.startsWith('/')) {
    throw Exception('Err: URI must start with a slash "/".');
  }

  // uri = uri.replaceAll('/api/', '/');

  final List<String> segmentList = uri.split("/");
  final List<String> segmentListFiltered = segmentList
      .map((item) => item.trim())
      .where((item) => !item.isEmpty)
      .map((e) => e.pascalCase)
      .toList();

  for (var segment in segmentListFiltered) {
    print(segment);
  }

  // print(segmentListFiltered.join("U") + 'UResponse');
  // print(segmentListFiltered.join("Z") + 'ZResponse');

  // final joined = segmentListFiltered.join("Z") + 'ZResponse';
  // return joined;

  return segmentListFiltered.last + 'Response';

  // "/api/Dashboard/getScheduleInspection"
  // "/Api/Dashboard/GetScheduleInspection"
  // "Api_Dashboard_GetScheduleInspection"
  // "Api_Dashboard_GetScheduleInspection_Response"
  // "Api_Dashboard_GetScheduleInspection_Response.dart"
}

List<String> convertUriToFolderNames(String uri) {
  if (!uri.startsWith('/')) {
    throw Exception('Err: URI must start with a slash "/".');
  }

  final List<String> segmentList = uri.split("/");
  final List<String> segmentListFiltered = segmentList
      .map((item) => item.trim())
      .where((item) => !item.isEmpty)
      .map((e) => e.snakeCase)
      .toList();
  for (var segment in segmentListFiltered) {
    print(segment);
  }

  segmentListFiltered.removeLast();

  return segmentListFiltered;
}

String generateDartFileContent(
  String filenameWithoutDart,
  String className,
) =>
    '''// ignore_for_file: non_constant_identifier_names, file_names, camel_case_types

import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '${filenameWithoutDart}.freezed.dart';
part '${filenameWithoutDart}.g.dart';

/// Created by: Erlang Parasu 2023.
@freezed
class ${className} with _\$${className} {
  @JsonSerializable(explicitToJson: true)
  const factory ${className}({
    @JsonKey(name: 'id') String? id,
  }) = _${className};

  factory ${className}.fromJson(
    Map<String, dynamic> json,
  ) =>
      _\$${className}FromJson(json);
}

FutureOr<Response<dynamic>> converterFor${className}(
  Response<dynamic> response,
) {
  final bodyString = response.bodyString;
  final jsonMap = jsonDecode(bodyString) as Map<String, dynamic>;
  final model = ${className}.fromJson(jsonMap);
  return response.copyWith(body: model);
}

''';
