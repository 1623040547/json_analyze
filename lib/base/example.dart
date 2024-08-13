import 'meta.dart';

part 'example.g.dart';

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

  int _e1 = 0;

  static BaseProtoExample fromJson(Map<String, dynamic> json) =>
      _$BaseProtoExampleFromJson(json);

  Map<String, dynamic> toJson() => _$BaseProtoExampleToJson(this);
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

  double? _e2;

  double? __e2;

  late double e3;

  late double? e4;

  static bool i = true;

  late final double k = 2.0;

  final double j = 0.0;

  static UnionProtoExample fromJson(Map<String, dynamic> json) =>
      _$UnionProtoExampleFromJson(json);

  Map<String, dynamic> toJson() => _$UnionProtoExampleToJson(this);
}
