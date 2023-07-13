import 'dart:convert';

import 'package:mason/mason.dart';

/// Created by: Erlang Parasu 2023.
List<OneParsedKlass> parseKlassListFromJsonMap(
  String inputKlassName,
  Map<String, dynamic> decodedJson,
) {
  inputKlassName = inputKlassName.pascalCase;

  final parsedKlassList = <OneParsedKlass>[];
  final parsedFieldList = <OneParsedField>[];

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

    String resFieldName = '';
    String resDataType = '';
    String resVarName = '';

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

            parsedKlassList.addAll(
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

      parsedKlassList.addAll(
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

    parsedFieldList.add(
      OneParsedField(
        fieldName: resFieldName,
        dataType: resDataType,
        varName: resVarName,
      ),
    );

    // print('DONE_1');
  }

  parsedKlassList.add(
    OneParsedKlass(
      klassName: inputKlassName,
      fieldList: parsedFieldList,
    ),
  );

  return parsedKlassList;
}

String generatePrettyJsonString(jsonObject) {
  var encoder = new JsonEncoder.withIndent("  ");
  return encoder.convert(jsonObject);
}

class OneParsedKlass {
  OneParsedKlass({
    required this.klassName,
    required this.fieldList,
  });

  final String klassName;
  final List<OneParsedField> fieldList;

  @override
  String toString() {
    return generatePrettyJsonString({
      'klassName': klassName,
      'fieldList': fieldList.map((e) => jsonDecode(e.toString())).toList(),
    }).toString();
  }
}

class OneParsedField {
  OneParsedField({
    required this.fieldName,
    required this.dataType,
    required this.varName,
  });

  final String fieldName;
  final String dataType;
  final String varName;

  @override
  String toString() {
    return generatePrettyJsonString({
      'fieldName': fieldName,
      'dataType': dataType,
      'varName': varName,
    }).toString();
  }
}
