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
    OneFieldParsed(fieldName: 'Name', dataType: 'String', varName: 'name'),
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

  /// JSON data types
  // - a string
  // - a number
  // - an object (JSON object)
  // - an array
  // - a boolean
  // - null

  ///
  String jsonText = linesInpResponse.join("\n");
  if (jsonText.startsWith('[') && jsonText.endsWith(']')) {
    jsonText = '{"my_String":"abc",'
        '"my_int":1,'
        '"my_double":0.5,'
        '"my_bool":true,'
        '"my_Null":null,'
        '"my_Map1":{"meta":"example"},'
        '"my_Map2":{"meta":2},'
        '"my_Map3":{"meta":true},'
        '"my_List_String":["a", "b", "c"],'
        '"my_List_int":[1, 2, 3],'
        '"my_List_double":[0.1, 0.2, 0.3],'
        '"my_List_bool":[true, true, false],'
        '"my_List_Null":[null, null, null],'
        '"my_List_Map":[{"id":1,"name":"One"}, {"id":2,"name":"Two"}],'
        '"data":$jsonText}';
  }

  if (jsonText.startsWith('{') && jsonText.endsWith('}')) {
    // ok.
  } else {
    throw Exception('err_invalid_json_content');
  }

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
  final prettyJsonText = getPrettyJSONString(decodedJson);
  print(prettyJsonText);

  final klassParsedList = _parseKlassListFromJsonMap(
    'the root response',
    decodedJson,
  );
  print('---klassParsedList---');
  print(klassParsedList.toString());
  print('---/klassParsedList---');

  /// ---klassParsedList---
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
  /// ---/klassParsedList---

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

List<OneKlassParsed> _parseKlassListFromJsonMap(
  String inputKlassName,
  Map<String, dynamic> decodedJson,
) {
  inputKlassName = inputKlassName.pascalCase;

  final klassParsedList = <OneKlassParsed>[];

  final fieldParsedList = <OneFieldParsed>[];
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

    ///
    if (key.runtimeType.toString() == 'String') {
      resFieldName = key;
      resVarName = key.camelCase;
    }

    ///
    if (value.runtimeType.toString().contains('List<dynamic>')) {
      String itemClassName = '${inputKlassName}${key.pascalCase}Item';
      () {
        final listDyn = value as List<dynamic>;
        for (var itemDyn in listDyn) {
          if (itemDyn.runtimeType.toString().contains('Map<String, dynamic>')) {
            final childKlassNameForList = '${inputKlassName}${key.pascalCase}';
            itemClassName = childKlassNameForList;

            klassParsedList.addAll(
              _parseKlassListFromJsonMap(
                childKlassNameForList,
                itemDyn as Map<String, dynamic>,
              ),
            );
          } else if (itemDyn.runtimeType.toString().contains('String')) {
            itemClassName = 'String';
          } else if (itemDyn.runtimeType.toString().contains('int')) {
            itemClassName = 'int';
          } else if (itemDyn.runtimeType.toString().contains('double')) {
            itemClassName = 'double';
          } else if (itemDyn.runtimeType.toString().contains('bool')) {
            itemClassName = 'bool';
          } else if (itemDyn.runtimeType.toString().contains('Null')) {
            itemClassName = 'Object?';
          } else {
            itemClassName = 'dynamic';
          }
        }
      }();
      resDataType = 'List<$itemClassName>?';
    } else if (value.runtimeType.toString().contains('Map<String, dynamic>')) {
      final childClassName = '${inputKlassName}${key.pascalCase}';
      resDataType = '${childClassName}?';

      klassParsedList.addAll(
        _parseKlassListFromJsonMap(
          childClassName,
          value as Map<String, dynamic>,
        ),
      );
    } else if (value.runtimeType.toString().contains('String')) {
      resDataType = 'String?';
    } else if (value.runtimeType.toString().contains('int')) {
      resDataType = 'int?';
    } else if (value.runtimeType.toString().contains('double')) {
      resDataType = 'double?';
    } else if (value.runtimeType.toString().contains('bool')) {
      resDataType = 'bool?';
    } else if (value.runtimeType.toString().contains('Null')) {
      resDataType = 'Object?';
    } else {
      resDataType = 'dynamic';
    }

    fieldParsedList.add(
      OneFieldParsed(
        fieldName: resFieldName,
        dataType: resDataType,
        varName: resVarName,
      ),
    );
    print('DONE_1');
  }

  klassParsedList.add(
    OneKlassParsed(
      klassName: inputKlassName,
      fieldList: fieldParsedList,
    ),
  );

  return klassParsedList;
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
      // reviver: (key, value) {
      //   if (key != null) {
      //     print('key=${key.runtimeType}, value=${value.runtimeType}');
      //   }
      // },
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

class OneKlassParsed {
  OneKlassParsed({
    required this.klassName,
    required this.fieldList,
  });

  final String klassName;
  final List<OneFieldParsed> fieldList;

  @override
  String toString() {
    return {
      'klassName': klassName,
      'fieldList': fieldList.map((e) => e.toString()).toList(),
    }.toString();
  }
}

class OneFieldParsed {
  OneFieldParsed({
    required this.fieldName,
    required this.dataType,
    required this.varName,
  });

  final String fieldName;
  final String dataType;
  final String varName;

  @override
  String toString() {
    return {
      'fieldName': fieldName,
      'dataType': dataType,
      'varName': varName,
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
