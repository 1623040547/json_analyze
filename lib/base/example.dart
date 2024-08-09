import 'meta.dart';

///基本数据类型的定义
@proto
class BaseProtoExample {
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
class UnionProtoExample {
  ///非空类型
  ///带默认值
  BaseProtoExample baseParam = BaseProtoExample();
  List<BaseProtoExample> baseParams = [];

  ///可空类型
  BaseProtoExample? baseParamNullable;
  List<BaseProtoExample>? baseParamsNullable;
}
