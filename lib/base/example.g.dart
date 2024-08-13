part of 'example.dart';

List<T>? _getList<T>(dynamic value) {
  if (value is! List) {
    return null;
  }
  List<T> items = [];
  for (var e in value) {
    if (e is T) {
      items.add(e);
    }
  }
  return items;
}

T? _getType<T>(dynamic value) {
  if (value is! T) {
    return null;
  }
  return value;
}

Map<String, dynamic> _$UnionProtoExampleToJson(UnionProtoExample instance) => {
      'baseParam': instance.baseParam.toJson(),
      'baseParams': instance.baseParams.map((e) => e.toJson()).toList(),
      'baseParamNullable': instance.baseParamNullable?.toJson(),
      'baseParamsNullable':
          instance.baseParamsNullable?.map((e) => e.toJson()).toList(),
      'e2': instance._e2,
      '_e2': instance.__e2,
    }..removeWhere((key, value) => value == null);

UnionProtoExample _$UnionProtoExampleFromJson(Map<String, dynamic> json) {
  UnionProtoExample instance = UnionProtoExample();
  Map<String, dynamic>? baseParam =
      _getType<Map<String, dynamic>>(json['baseParam']);
  if (baseParam != null) {
    instance.baseParam = BaseProtoExample.fromJson(baseParam);
  }
  List<Map<String, dynamic>>? baseParams =
      _getList<Map<String, dynamic>>(json['baseParams']);
  if (baseParams != null) {
    instance.baseParams =
        baseParams.map((e) => BaseProtoExample.fromJson(e)).toList();
  }
  Map<String, dynamic>? baseParamNullable =
      _getType<Map<String, dynamic>>(json['baseParamNullable']);
  if (baseParamNullable != null) {
    instance.baseParamNullable = BaseProtoExample.fromJson(baseParamNullable);
  }
  List<Map<String, dynamic>>? baseParamsNullable =
      _getList<Map<String, dynamic>>(json['baseParamsNullable']);
  if (baseParamsNullable != null) {
    instance.baseParamsNullable =
        baseParamsNullable.map((e) => BaseProtoExample.fromJson(e)).toList();
  }
  double? e2 = _getType<double>(json['e2']);
  if (e2 != null) {
    instance._e2 = e2;
  }

  double? _e2 = _getType<double>(json['_e2']);
  if (_e2 != null) {
    instance.__e2 = _e2;
  }

  return instance;
}

extension UnionProtoExampleGetExtension on UnionProtoExample {
  double? get e2 => _e2;

  double? get _e2 => __e2;
}

Map<String, dynamic> _$BaseProtoExampleToJson(BaseProtoExample instance) => {
      'a1': instance.a1,
      'a2': instance.a2,
      'a3': instance.a3,
      'a4': instance.a4,
      'b1': instance.b1,
      'b2': instance.b2,
      'b3': instance.b3,
      'b4': instance.b4,
      'c1': instance.c1,
      'c2': instance.c2,
      'c3': instance.c3,
      'c4': instance.c4,
      'd1': instance.d1,
      'd2': instance.d2,
      'd3': instance.d3,
      'd4': instance.d4,
      'e1': instance._e1,
    }..removeWhere((key, value) => value == null);

BaseProtoExample _$BaseProtoExampleFromJson(Map<String, dynamic> json) {
  BaseProtoExample instance = BaseProtoExample();
  int? a1 = _getType<int>(json['a1']);
  if (a1 != null) {
    instance.a1 = a1;
  }

  String? a2 = _getType<String>(json['a2']);
  if (a2 != null) {
    instance.a2 = a2;
  }

  double? a3 = _getType<double>(json['a3']);
  if (a3 != null) {
    instance.a3 = a3;
  }

  bool? a4 = _getType<bool>(json['a4']);
  if (a4 != null) {
    instance.a4 = a4;
  }

  List<int>? b1 = _getList<int>(json['b1']);
  if (b1 != null) {
    instance.b1 = b1;
  }
  List<String>? b2 = _getList<String>(json['b2']);
  if (b2 != null) {
    instance.b2 = b2;
  }
  List<double>? b3 = _getList<double>(json['b3']);
  if (b3 != null) {
    instance.b3 = b3;
  }
  List<bool>? b4 = _getList<bool>(json['b4']);
  if (b4 != null) {
    instance.b4 = b4;
  }
  int? c1 = _getType<int>(json['c1']);
  if (c1 != null) {
    instance.c1 = c1;
  }

  String? c2 = _getType<String>(json['c2']);
  if (c2 != null) {
    instance.c2 = c2;
  }

  double? c3 = _getType<double>(json['c3']);
  if (c3 != null) {
    instance.c3 = c3;
  }

  bool? c4 = _getType<bool>(json['c4']);
  if (c4 != null) {
    instance.c4 = c4;
  }

  List<int>? d1 = _getList<int>(json['d1']);
  if (d1 != null) {
    instance.d1 = d1;
  }
  List<String>? d2 = _getList<String>(json['d2']);
  if (d2 != null) {
    instance.d2 = d2;
  }
  List<double>? d3 = _getList<double>(json['d3']);
  if (d3 != null) {
    instance.d3 = d3;
  }
  List<bool>? d4 = _getList<bool>(json['d4']);
  if (d4 != null) {
    instance.d4 = d4;
  }
  int? e1 = _getType<int>(json['e1']);
  if (e1 != null) {
    instance._e1 = e1;
  }

  return instance;
}

extension BaseProtoExampleGetExtension on BaseProtoExample {
  int get e1 => _e1;
}
