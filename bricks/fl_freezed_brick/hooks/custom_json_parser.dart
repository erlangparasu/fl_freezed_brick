import 'dart:convert';

import 'package:mason/mason.dart';

/// Created by: Erlang Parasu 2023.
List<OneKlassParsed> parseKlassListFromJsonMap(
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
      String itemClassName = '';
      () {
        final listDyn = value as List<dynamic>;
        for (var itemDyn in listDyn) {
          if (itemDyn.runtimeType.toString().contains('Map<String, dynamic>')) {
            final childKlassNameForList =
                '${inputKlassName}${key.pascalCase}Item';
            itemClassName = childKlassNameForList;

            klassParsedList.addAll(
              parseKlassListFromJsonMap(
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
        parseKlassListFromJsonMap(
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

class OneKlassParsed {
  OneKlassParsed({
    required this.klassName,
    required this.fieldList,
  });

  final String klassName;
  final List<OneFieldParsed> fieldList;

  @override
  String toString() {
    return getPrettyJSONString({
      'klassName': klassName,
      'fieldList': fieldList.map((e) => jsonDecode(e.toString())).toList(),
    }).toString();
  }
}

String getPrettyJSONString(jsonObject) {
  var encoder = new JsonEncoder.withIndent("  ");
  return encoder.convert(jsonObject);
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
    return getPrettyJSONString({
      'fieldName': fieldName,
      'dataType': dataType,
      'varName': varName,
    }).toString();
  }
}
