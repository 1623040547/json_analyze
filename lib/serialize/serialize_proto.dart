import 'dart:io';

import 'package:analyzer_query/proj_path/dart_file.dart';
import 'package:analyzer_query/tester.dart';
import 'package:json_analyze/base/example.dart';
import 'package:json_analyze/base/meta.dart';

import '../base/data.dart';

///序列化[@proto]注解下的类，
///允许序列化类型仅包含[BaseProtoExample]和[UnionProtoExample]下所展现的数据类型。
///
///在[@proto]下，关键字`final`,`const`,`static`下的变量不会被考虑到序列化之中，
///你可以通过私有变量'_'来控制变量的对外可写性
class ProtoSerialize {
  ///所有的可序列化对象
  final List<String> compares;

  final List<JsonSerializeData> datas;

  ///生成文件' .g.dart '的文本缓存
  final Map<DartFile, String> _genFileMaps = {};

  ///原始文件' .dart '的文本缓存
  final Map<DartFile, String> _fileMaps = {};

  ProtoSerialize(
    this.datas, {
    required this.compares,
  });

  void start() {
    for (var data in datas.reversed) {
      if (!_fileMaps.containsKey(data.file)) {
        _fileMaps[data.file] = data.file.fileString;
      }
      _fillMethod(data);
      generateFile(data);
    }
    for (var data in datas) {
      _fillPart(data);
    }
    _genFileMaps.forEach((key, value) {
      String fileLast = Uri.parse(key.filePath).pathSegments.last;
      String filePath =
          key.filePath.replaceAll(fileLast, '${key.fileName}.g.dart');
      String fileString = DartFormatter().format(value);
      File(filePath).writeAsStringSync(fileString);
    });

    _fileMaps.forEach((key, value) {
      String fileString = DartFormatter().format(value);
      File(key.filePath).writeAsStringSync(fileString);
    });
  }

  ///若@[proto]下尚未填写[fromJson]或[toJson]方法，则为之填充
  void _fillMethod(JsonSerializeData data) {
    String classMethod = "";
    String fileString = _fileMaps[data.file]!;
    if (data.methods
        .where((data) => data.isStatic && data.methodName == 'fromJson')
        .isEmpty) {
      classMethod +=
          "\n\nstatic ${data.className} fromJson(Map<String, dynamic> json) =>"
          "_\$${data.className}FromJson(json);\n\n\n";
    }
    if (data.methods
        .where((data) => !data.isStatic && data.methodName == 'toJson')
        .isEmpty) {
      classMethod +=
          "\n\nMap<String, dynamic> toJson() => _\$${data.className}ToJson(this);\n\n\n";
    }
    if (classMethod.isEmpty) {
      return;
    }
    int endOffset = data.classToken.end;
    fileString = fileString.substring(0, endOffset - 1) +
        classMethod +
        fileString.substring(endOffset - 1);
    _fileMaps[data.file] = fileString;
  }

  ///若@[proto]下尚未填写' .g.part '的定位符，则为之填充
  void _fillPart(JsonSerializeData data) {
    String partDirect = "";
    String partName = "${data.file.fileName}.g.dart";
    String fileString = _fileMaps[data.file]!;
    if (data.redirects
        .where((e) => e.isPart && e.redirectName == partName)
        .isEmpty) {
      partDirect += "part '$partName';\n";
    }
    if (partDirect.isEmpty) {
      return;
    }
    int endOffset = data.redirects.lastOrNull?.token.end ?? 0;
    fileString = fileString.substring(0, endOffset) +
        partDirect +
        fileString.substring(endOffset);
    _fileMaps[data.file] = fileString;
    data.redirects.add(
      JsonSerializeRedirect(
        token: TestToken(
          start: endOffset,
          end: endOffset + partDirect.length,
          name: partDirect,
          type: PartDirective,
        ),
        redirectName: partName,
        isPart: true,
      ),
    );
  }

  ///生成' .g.part '文件
  void generateFile(JsonSerializeData data) {
    DartFile key = data.file;
    if (!_genFileMaps.containsKey(key)) {
      _genFileMaps[key] =
          "part of '${data.file.fileName}.dart';\n$_getList\n$_getType";
    }
    _genFileMaps[key] = _genFileMaps[key]! + _genToJson(data);
    _genFileMaps[key] = _genFileMaps[key]! + _genFromJson(data);
    _genFileMaps[key] = _genFileMaps[key]! + _genPrivateGetter(data);
  }

  ///生成[toJson]函数
  String _genToJson(JsonSerializeData data) {
    String className = data.className;
    String params = '';
    for (var param in data.params) {
      if (param.isStatic || param.isConst || param.isFinal) {
        continue;
      }
      if (!param.isBaseParam && !compares.contains(param.realType)) {
        throw JsonAnalyzeException("Unknown Type: ${param.realType}");
      }
      String paramName = param.name;
      String jsonName = param.jsonName;
      String question = param.isQuestion ? '?' : '';
      if (param.isBaseParam) {
        params += "'$jsonName':instance.$paramName,\n";
      } else if (param.isUnionParam && param.isList) {
        params +=
            "'$jsonName': instance.$paramName$question.map((e) => e.toJson()).toList(),\n";
      } else {
        params += "'$jsonName': instance.$paramName$question.toJson(),\n";
      }
    }
    String methodString =
        "Map<String, dynamic>  _\$${className}ToJson($className instance) => { $params }"
        "..removeWhere((key, value) => value == null);\n\n\n";
    return methodString;
  }

  ///生成[fromJson]函数
  String _genFromJson(JsonSerializeData data) {
    String className = data.className;
    String params = '';
    for (var param in data.params) {
      if (param.isStatic || param.isConst || param.isFinal) {
        continue;
      }
      if (!param.isBaseParam && !compares.contains(param.realType)) {
        throw JsonAnalyzeException("Unknown Type: ${param.realType}");
      }
      String paramName = param.name;
      String jsonName = param.jsonName;
      String realClass = param.realType;
      if (param.isBaseParam && param.isList) {
        params += """
        List<$realClass>? $jsonName = _getList<$realClass>(json['$jsonName']);
        if($jsonName != null) {
          instance.$paramName = $jsonName;
        }
        """;
      } else if (param.isUnionParam && param.isList) {
        params += """
        List<Map<String, dynamic>>? $jsonName =
            _getList<Map<String, dynamic>>(json['$jsonName']);
        if($jsonName != null) {
          instance.$paramName = $jsonName.map((e) => $realClass.fromJson(e))
          .toList();
        }
        """;
      } else if (param.isBaseParam && !param.isList) {
        params += """
        $realClass? $jsonName = 
             _getType<$realClass>(json['$jsonName']);
        if ($jsonName != null) {
          instance.$paramName = $jsonName;
        }\n
        """;
      } else if (param.isUnionParam && !param.isList) {
        params += """
        Map<String, dynamic>? $jsonName =
            _getType<Map<String, dynamic>>(json['$jsonName']);
        if ($jsonName != null) {
          instance.$paramName = $realClass.fromJson($jsonName);
        }
        """;
      }
    }
    String methodString =
        "$className _\$${className}FromJson(Map<String, dynamic> json) { "
        "$className instance = $className();\n"
        "$params"
        "return instance;"
        "}\n\n\n";
    return methodString;
  }

  String _genPrivateGetter(JsonSerializeData data) {
    String className = data.className;
    String params = '';
    for (var param in data.params) {
      if (param.isStatic || param.isConst || param.isFinal) {
        continue;
      }
      if (!param.isBaseParam && !compares.contains(param.realType)) {
        throw JsonAnalyzeException("Unknown Type: ${param.realType}");
      }
      String paramName = param.name;
      String jsonName = param.jsonName;
      String className = param.type;
      if (param.isPrivate) {
        params += '$className get $jsonName => $paramName;\n\n\n';
      }
    }
    String methodString = """
   \n\n\nextension ${className}GetExtension on $className {
        $params
    }
    \n\n\n""";
    return methodString;
  }

  final String _getList = """
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
  """;

  final String _getType = """
  T? _getType<T>(dynamic value) {
  if (value is! T) {
    return null;
  }
  return value;
} 
  """;
}

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
