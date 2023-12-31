import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';

import 'custom_json_parser.dart';

/// Created by: Erlang Parasu 2023.
void run(HookContext context) {
  // Read vars.
  String filename = context.vars['input_filename'];

  context.logger.info('filename: $filename');

  final File fileObj = File(filename);
  if (!fileObj.existsSync()) {
    context.logger.err('File not found: $filename');
    return;
  }

  context.logger.info('File found: $filename');

  // fileObj.absolute;

  // // Debug
  // filename = '_api_Dashboard_getScheduleInspection.md';

  // Use the `Logger` instance.
  // context.logger.info('Generating file: $filename');

  // filename.camelCase;

  // Update vars.
  // context.vars['current_year'] = DateTime.now().year;

  context.logger.info('Generating...');
  generateOneFile(filename, context);
  context.logger.info('Generating done.');
}

void generateOneFile(String filename, HookContext context) {
  context.logger.info('Reading file...');
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

  context.logger.info('Reading lines...');
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

  context.logger.info('Parsing url path...');

  /// Url path.
  String inputUri = linesInpUri.first;
  print({'inputUri': inputUri});

  context.logger.info('Parsing filename...');

  /// Response filename.
  String dartFilename = convertUriToDartFilename(inputUri);
  print({'dartFilename': dartFilename});

  context.logger.info('Parsing class name...');

  /// Response klassname.
  String dartKlassName = convertUriToDartKlassName(inputUri);
  print({'dartKlassName': dartKlassName});

  context.logger.info('Parsing folder names...');

  /// Folder names.
  final folderNames = convertUriToFolderNames(inputUri);
  print({'folderNames': folderNames});

  /// JSON data types
  // - a string
  // - a number
  // - an object (JSON object)
  // - an array
  // - a boolean
  // - null

  context.logger.info('Parsing json...');

  ///
  String jsonText = linesInpResponse.join("\n");
  if (jsonText.startsWith('[') && jsonText.endsWith(']')) {
    // jsonText = '{"my_String":"abc",'
    //     '"my_int":1,'
    //     '"my_double":0.5,'
    //     '"my_bool":true,'
    //     '"my_Null":null,'
    //     '"my_Map1":{"meta":"example"},'
    //     '"my_Map2":{"meta":2},'
    //     '"my_Map3":{"meta":true},'
    //     '"my_List_String":["a", "b", "c"],'
    //     '"my_List_int":[1, 2, 3],'
    //     '"my_List_double":[0.1, 0.2, 0.3],'
    //     '"my_List_bool":[true, true, false],'
    //     '"my_List_Null":[null, null, null],'
    //     '"my_List_Map":[{"id":1,"name":"One"}, {"id":2,"name":"Two"}],'
    //     '"data":$jsonText}';

    jsonText = '{"data":$jsonText}';
  }

  if (jsonText.startsWith('{') && jsonText.endsWith('}')) {
    // ok.
  } else {
    throw Exception('err_invalid_json_content');
  }

  context.logger.info('Decode json...');

  final Map<String, dynamic> decodedJson = jsonDecode(
    jsonText,
    // reviver: (key, value) {
    //   print({
    //     'KEY': key,
    //     'VALUE': value.toString(),
    //     'key_type': key.runtimeType,
    //     'value_type': value.runtimeType,
    //   });
    //   return value;
    // },
  );
  final prettyJsonText = generatePrettyJsonString(decodedJson);
  // print(prettyJsonText);

  context.logger.info('Parse class names...');

  final parsedKlassList = parseKlassListFromJsonMap(
    dartKlassName,
    decodedJson,
  );

  // print('---parsedKlassList---');
  // print(parsedKlassList.toString());
  // print('---/parsedKlassList---');

  /// ---parsedKlassList---
  /// [{klassName: TheRootResponseMyMap1, fieldList: [{fieldName: meta,
  /// dataType: String?, varName: meta}]}, {klassName: TheRootResponseMyMap2,
  /// fieldList: [{fieldName: meta, dataType: int?, varName: meta}]}, {
  /// klassName: TheRootResponseMyMap3, fieldList: [{fieldName: meta,
  /// dataType: bool?, varName: meta}]}, {klassName: TheRootResponseMyListMap,
  /// fieldList: [{fieldName: id, dataType: int?, varName: id}, {
  /// fieldName: name, dataType: String?, varName: name}]}, {klassName:
  /// TheRootResponseMyListMap, fieldList: [{fieldName: id, dataType: int?,
  /// varName: id}, {fieldName: name, dataType: String?, varName: name}]},
  /// {klassName: TheRootResponse, fieldList: [{fieldName: my_String,
  /// dataType: String?, varName: myString}, {fieldName: my_int, dataType:
  /// int?, varName: myInt}, {fieldName: my_double, dataType: double?, varName:
  /// myDouble}, {fieldName: my_bool, dataType: bool?, varName: myBool},
  /// {fieldName: my_Null, dataType: Object?, varName: myNull}, {fieldName:
  /// my_Map1, dataType: TheRootResponseMyMap1?, varName: myMap1}, {fieldName:
  /// my_Map2, dataType: TheRootResponseMyMap2?, varName: myMap2}, {fieldName:
  /// my_Map3, dataType: TheRootResponseMyMap3?, varName: myMap3}, {fieldName:
  /// my_List_String, dataType: List<String>?, varName: myListString},
  /// {fieldName: my_List_int, dataType: List<int>?, varName: myListInt},
  /// {fieldName: my_List_double, dataType: List<double>?, varName:
  /// myListDouble}, {fieldName: my_List_bool, dataType: List<bool>?,
  /// varName: myListBool}, {fieldName: my_List_Null, dataType: List<Object?>?,
  /// varName: myListNull}, {fieldName: my_List_Map, dataType:
  /// List<TheRootResponseMyListMap>?, varName: myListMap}]}]
  /// ---/parsedKlassList---

  final filteredParsedKlassList = <OneParsedKlass>[];
  final uniqueKlassList = <String>[];
  for (var element in parsedKlassList) {
    if (!uniqueKlassList.contains(element.klassName)) {
      filteredParsedKlassList.add(element);
      uniqueKlassList.add(element.klassName);
    }
  }

  // print('<filteredParsedKlassList>');
  // print(
  //   generatePrettyJsonString(
  //     jsonDecode(
  //       filteredParsedKlassList.toString(),
  //     ),
  //   ),
  // );
  // print('</filteredParsedKlassList>');

  // print(parsedKlassList.length);
  // print(filteredParsedKlassList.length);

  print(filteredParsedKlassList.map((e) => e.klassName).toList());

  // // print(jsonDecode('"Hello"') as Map<String, dynamic>);
  // // print(jsonDecode('95') as Map<String, dynamic>);
  // print(jsonDecode('{"status": "ok"}') as Map<String, dynamic>);
  // // print(jsonDecode('["a", "b", "c"]') as Map<String, dynamic>);
  // // print(jsonDecode('true') as Map<String, dynamic>);
  // // print(jsonDecode('null') as Map<String, dynamic>);

  ///

  context.logger.info('Parsing json fields...');

  String freezedAllString = '';
  for (var parsedKlassItem in filteredParsedKlassList) {
    final klassName = parsedKlassItem.klassName;
    final fieldsString = generateAllFieldsStringFromList(
      parsedKlassItem.fieldList,
    );

    final freezedString = generateFreezedAnnotationContent(
      klassName: klassName,
      fieldsString: fieldsString,
    );

    freezedAllString += freezedString;
  }

  context.logger.info('Generating dart file...');

  final slash = Platform.pathSeparator;
  context.logger.info(
    'Generating file: '
    'lib${slash}models/${folderNames.join('${slash}')}${slash}${dartFilename}',
  );
  final newFile = File(
      'lib${slash}models${slash}${folderNames.join('${slash}')}${slash}${dartFilename}');
  newFile.createSync(recursive: true);
  newFile.writeAsStringSync(
    generateDartFileContent(
          filenameWithoutExtension: dartFilename.replaceAll('.dart', ''),
          klassName: dartKlassName,
          freezedAllString: freezedAllString,
        ).trim() +
        "\n",
  );

  context.logger.info('Generating dart file done.');
}

/// JSON data types
// - a string
// - a number
// - an object (JSON object)
// - an array
// - a boolean
// - null

///

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
    // print(segment);
  }

  final joined = segmentListFiltered.last;
  return joined.snakeCase + '_response.dart';

  // "/api/Dashboard/getScheduleInspection"
  // "/Api/Dashboard/GetScheduleInspection"
  // "Api_Dashboard_GetScheduleInspection"
  // "Api_Dashboard_GetScheduleInspection_Response"
  // "Api_Dashboard_GetScheduleInspection_Response.dart"
}

String convertUriToDartKlassName(String uri) {
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
    // print(segment);
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
    // print(segment);
  }

  segmentListFiltered.removeLast();

  return segmentListFiltered;
}

String generateDartFileContent({
  required String filenameWithoutExtension,
  required String klassName,
  required String freezedAllString,
}) =>
    '''// ignore_for_file: non_constant_identifier_names, file_names, camel_case_types

import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '${filenameWithoutExtension}.freezed.dart';
part '${filenameWithoutExtension}.g.dart';

/// Created by: Erlang Parasu 2023.

/// NOTE: Chopper response converter.

FutureOr<Response<dynamic>> converterFor${klassName}(
  Response<dynamic> response,
) {
  var bodyString = response.bodyString;
  if (bodyString.startsWith('[') && bodyString.endsWith(']')) {
    final modifiedBodyString = '{"data":\$bodyString}';
    bodyString = modifiedBodyString;
  }
  final jsonMap = jsonDecode(bodyString) as Map<String, dynamic>;
  final model = ${klassName}.fromJson(jsonMap);
  return response.copyWith(body: model);
}

/// NOTE: Freezed clases

${freezedAllString}
''';

String generateFreezedAnnotationContent({
  required String klassName,
  required String fieldsString,
}) =>
    '''
@freezed
class ${klassName} with _\$${klassName} {
  @JsonSerializable(explicitToJson: true)
  const factory ${klassName}({
${fieldsString}
  }) = _${klassName};

  factory ${klassName}.fromJson(
    Map<String, dynamic> json,
  ) =>
      _\$${klassName}FromJson(json);
}

''';

String generateAllFieldsStringFromList(List<OneParsedField> parsedFieldList) {
  final fieldLines = <String>[];
  for (var item in parsedFieldList) {
    String aLine =
        "    @JsonKey(name: '${item.fieldName}') ${item.dataType} ${item.varName},";
    fieldLines.add(aLine);
  }
  return fieldLines.join("\n");
}
