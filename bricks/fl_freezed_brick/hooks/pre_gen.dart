import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';

/// Created by: Erlang Parasu 2023.
void run(HookContext context) {
  // Read vars.
  String filename = context.vars['input_filename'];

  // Debug
  filename = '_api_Dashboard_getScheduleInspection.md';

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

  final parsedFields = <OneFieldParsed>[];
  parsedFields.add(
    OneFieldParsed(
        fieldName: 'Name', dataType: 'String', varName: 'name', children: []),
  );
  final allFieldsString = _generateAllFieldsStringFromList(parsedFields);

  final newFile =
      File('lib/models/${folderNames.join('/')}/${getDartFilename}');
  newFile.createSync(recursive: true);
  newFile.writeAsStringSync(
    _generateDartFileContent(
      filenameWithoutDart: getDartFilename.replaceAll('.dart', ''),
      className: getDartClassname,
      allFieldsString: allFieldsString,
    ),
  );

  ///
  String jsonText = linesInpResponse.join("\n");
  if (jsonText.startsWith('[') && jsonText.endsWith(']')) {
    jsonText = '{"type_String":"abc",'
        '"type_int":1,'
        '"type_double":0.5,'
        '"type_bool":true,'
        '"type_Null":null,'
        '"type_List":[1, 2, 3],'
        '"type_List2":["a", "b", "c"],'
        '"type_List3":[true, true, false],'
        '"type_Map":{"meta":"example"},'
        '"data":$jsonText}';
  }

  if (jsonText.startsWith('{') && jsonText.endsWith('}')) {
    // ok.
  } else {
    throw Exception('err_invalid_json_content');
  }

  final Map<String, dynamic> decodedJson = jsonDecode(
    jsonText,
    reviver: (key, value) {
      print({
        'KEY': key,
        'VALUE': value.toString(),
        'key_type': key.runtimeType,
        'value_type': value.runtimeType,
      });
      return value;
    },
  );
  final prettyJsonText = getPrettyJSONString(decodedJson);
  print(prettyJsonText);

  final listParsed = _parseMapJson(decodedJson);
  // print(getPrettyJSONString(jsonDecode(jsonEncode(listParsed))));
  print(listParsed.toString());

  // parseFieldName('  "document_url": ""  ');
  // parseFieldName('  "updated_by": "muhammad.aziz",  ');
  // parseFieldName('  "deferal_id": null,  ');

  final prettyLines = prettyJsonText.split("\n");
  for (var element in prettyLines) {
    // parseFieldName(element);
  }

  // print(jsonDecode('"Hello"') as Map<String, dynamic>);
  // print(jsonDecode('95') as Map<String, dynamic>);
  print(jsonDecode('{"status": "ok"}') as Map<String, dynamic>);
  // print(jsonDecode('["a", "b", "c"]') as Map<String, dynamic>);
  // print(jsonDecode('true') as Map<String, dynamic>);
  // print(jsonDecode('null') as Map<String, dynamic>);
}

List<OneFieldParsed> _parseMapJson(Map<String, dynamic> decodedJson) {
  final listParsed = <OneFieldParsed>[];

  for (var key in decodedJson.keys) {
    final value = decodedJson[key];
    print({
      'key_type': key.runtimeType,
      'key': key,
      'value_type': value.runtimeType,
      'value': value,
    });

    // required this.fieldName,
    // required this.dataType,
    // required this.varName,

    String resFieldName = "";
    String resDataType = "";
    String resVarName = "";
    final resChildren = <OneFieldParsed>[];

    ///
    if (key.runtimeType.toString() == 'String') {
      resFieldName = key;
      resVarName = key.camelCase;
    }

    ///
    if (value.runtimeType.toString().contains('String')) {
      resDataType = 'String?';
    } else if (value.runtimeType.toString().contains('int')) {
      resDataType = 'int?';
    } else if (value.runtimeType.toString().contains('double')) {
      resDataType = 'double?';
    } else if (value.runtimeType.toString().contains('bool')) {
      resDataType = 'bool?';
    } else if (value.runtimeType.toString().contains('Null')) {
      resDataType = 'Object?';
    } else if (value.runtimeType.toString().contains('List<dynamic>')) {
      final itemClassName = 'Undeclared${key.pascalCase}Item';
      resDataType = 'List<$itemClassName>?';
      final listDyn = value as List<dynamic>;
      for (var itemDyn in listDyn) {
        // if (value.runtimeType.toString().contains('String')) {}
        // _parseMapJson(value as Map<String, dynamic>);
      }
    } else if (value.runtimeType.toString().contains('Map<String, dynamic>')) {
      final childClassName = 'Undeclared${key.pascalCase}Item';
      resDataType = '${childClassName}?';
      resChildren.addAll(
        _parseMapJson(value as Map<String, dynamic>),
      );
    }

    listParsed.add(
      OneFieldParsed(
        fieldName: resFieldName,
        dataType: resDataType,
        varName: resVarName,
        children: resChildren,
      ),
    );
    print('DONE_1');
  }
  return listParsed;
}

/// JSON data types
// - a string
// - a number
// - an object (JSON object)
// - an array
// - a boolean
// - null

String getPrettyJSONString(jsonObject) {
  var encoder = new JsonEncoder.withIndent("  ");
  return encoder.convert(jsonObject);
}

String? parseFieldName(String line) {
  /// Example:
  // "document_url": "",

  // Remove empty spaces.
  String modified = line.trim();

  // Remove trailing comma.
  final indexCOmma = modified.lastIndexOf(',');
  final cList = modified.split('');
  final modCharList = <String>[];
  for (var i = 0; i < cList.length; i++) {
    if (i != indexCOmma) {
      modCharList.add(cList[i]);
    }
  }
  modified = modCharList.join('');
  print({'modified': modified});

  if (modified.contains('": [')) {
    // array
    return null;
  }
  if (modified.contains('": {')) {
    // object
    return null;
  }

  try {
    final withExtraObject = '{${modified}}';
    final decodedJson = jsonDecode(
      withExtraObject,
      reviver: (key, value) {
        if (key != null) {
          print('key=${key.runtimeType}, value=${value.runtimeType}');
        }
      },
    );
  } catch (e) {
    print({'error': e.toString()});
  }

  return null;
}

bool isJsonFieldString(String line) {
  return false;
}

bool isJsonFieldNumber(String line) {
  return false;
}

bool isJsonFieldObject(String line) {
  return false;
}

bool isJsonFieldArray(String line) {
  return false;
}

bool isJsonFieldBoolean(String line) {
  return false;
}

bool isJsonFieldNull(String line) {
  return false;
}

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

class OneFieldParsed {
  OneFieldParsed({
    required this.fieldName,
    required this.dataType,
    required this.varName,
    required this.children,
  });

  final String fieldName;
  final String dataType;
  final String varName;
  final List<OneFieldParsed> children;

  @override
  String toString() {
    return {
      'fieldName': fieldName,
      'dataType': dataType,
      'varName': varName,
      'children': children.map((e) => e.toString()).toList(),
    }.toString();
  }
}

String _generateAllFieldsStringFromList(List<OneFieldParsed> inputItems) {
  final fieldList = <String>[];
  for (var item in inputItems) {
    String aLine =
        "    @JsonKey(name: '${item.fieldName}') ${item.dataType}? ${item.varName},";
    fieldList.add(aLine);
  }
  return fieldList.join("\n");
}

String _generateDartFileContent({
  required String filenameWithoutDart,
  required String className,
  required String allFieldsString,
}) =>
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
    // @JsonKey(name: 'the_field_name') String? theFieldName,
${allFieldsString}
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
