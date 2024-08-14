import 'dart:math';

import 'package:json_analyze/base/example.dart';

BaseProtoExample get testBaseProtoExample => BaseProtoExample.fromJson({})
  ..a1 = Random().nextInt(10000)
  ..a2 = String.fromCharCodes(List.generate(
    Random().nextInt(1000),
    (index) => Random().nextInt(33) + 89,
  ))
  ..a3 = Random().nextDouble() * Random().nextInt(10000)
  ..a4 = Random().nextBool()
  ..c1 = Random().nextInt(100) > 95 ? null : Random().nextInt(10000)
  ..b1 = List.generate(1000, (index) => Random().nextInt(10000));

UnionProtoExample get testUnionProtoExample =>
    UnionProtoExample.fromJson({})..baseParam = testBaseProtoExample;
