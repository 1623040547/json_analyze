import 'package:json_analyze/proto_to_freeze/meta.dart';

///基本数据类型的定义
@proto
class BaseParam {
  ///非空类型
  int a1 = 0;
  String a2 = "";
  double a3 = 0;
  bool a4 = true;
  List<int> b1 = [];
  List<String> b2 = ["iap"];
  List<double> b3 = [];
  List<bool> b4 = [];

  ///可空类型
  int? c1;
  String? c2;
  double? c3;
  bool? c4;
  List<int>? d1;
  List<String>? d2;
  List<double>? d3;
  List<bool>? d4;
}

///复杂数据类型的定义
@proto
class UnionParam {
  ///非空类型
  BaseParam baseParam = BaseParam();
  List<BaseParam> baseParams = [];

  ///可空类型
  BaseParam? baseParamNullable;
  List<BaseParam>? baseParamsNullable;
}
