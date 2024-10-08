import 'dart:math';
import 'package:json_analyze/base/example.dart';

int get ramInt => Random().nextInt(1000);

double get ramDouble => Random().nextDouble() * Random().nextInt(10000);

String get ramString => String.fromCharCodes(List.generate(
      ramInt,
      (index) => Random().nextInt(33) + 89,
    ));

bool get ramBool => Random().nextBool();

extension on dynamic {
  dynamic get ramNull {
    return ramInt > 950 ? null : this;
  }
}

BaseProtoExample get testBaseProtoExample => BaseProtoExample.fromJson({
      'a1': ramInt,
      'a2': ramString,
      'a3': ramDouble,
      'a4': ramBool,
      'b1': List.generate(ramInt, (index) => ramInt),
      'b2': List.generate(ramInt, (index) => ramString),
      'b3': List.generate(ramInt, (index) => ramDouble),
      'b4': List.generate(ramInt, (index) => ramBool),
      'c1': ramInt.ramNull,
      'c2': ramString.ramNull,
      'c3': ramDouble.ramNull,
      'c4': ramBool.ramNull,
      'd1': List.generate(ramInt, (index) => ramInt).ramNull,
      'd2': List.generate(ramInt, (index) => ramString).ramNull,
      'd3': List.generate(ramInt, (index) => ramDouble).ramNull,
      'd4': List.generate(ramInt, (index) => ramBool).ramNull,
      'e1': ramInt,
    });

UnionProtoExample get testUnionProtoExample => UnionProtoExample.fromJson({
      'baseParam': testBaseProtoExample.toJson(),
      'baseParams':
          List.generate(ramInt, (index) => testBaseProtoExample.toJson()),
      'baseParamNullable': testBaseProtoExample.toJson().ramNull,
      'baseParamsNullable':
          List.generate(ramInt, (index) => testBaseProtoExample.toJson())
              .ramNull,
      'e2': ramDouble.ramNull,
      '_e2': ramDouble.ramNull,
      'e3': ramDouble,
      'e4': ramDouble.ramNull,
    });
