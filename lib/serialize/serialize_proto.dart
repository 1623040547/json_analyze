import 'dart:io';

import 'package:analyzer_query/proj_path/dart_file.dart';
import 'package:analyzer_query/tester.dart';

import '../base/data.dart';

class ProtoSerialize {
  final List<JsonSerializeData> datas;

  ///[DartFile] : [fileString]
  final Map<DartFile, String> _genFileMaps = {};

  ///[DartFile] : [fileString]
  final Map<DartFile, String> _fileMaps = {};

  ProtoSerialize(this.datas);

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

  void generateFile(JsonSerializeData data) {
    DartFile key = data.file;
    if (!_genFileMaps.containsKey(key)) {
      _genFileMaps[key] =
          "part of '${data.file.fileName}.dart';\n$_getList\n$_getType";
    }
    _genFileMaps[key] = _genFileMaps[key]! + _genToJson(data);
    _genFileMaps[key] = _genFileMaps[key]! + _genFromJson(data);
  }

  String _genToJson(JsonSerializeData data) {
    String className = data.className;
    String params = '';
    for (var param in data.params) {
      String paramName = param.name;
      String question = param.isQuestion ? '?' : '';
      if (param.isBaseParam) {
        params += "'$paramName':instance.$paramName,\n";
      } else if (param.isUnionParam && param.isList) {
        params +=
            "'$paramName': instance.$paramName$question.map((e) => e.toJson()).toList(),\n";
      } else {
        params += "'$paramName': instance.$paramName$question.toJson(),\n";
      }
    }
    String methodString =
        "Map<String, dynamic>  _\$${className}ToJson($className instance) => { $params }"
        "..removeWhere((key, value) => value == null);\n\n\n";
    return methodString;
  }

  String _genFromJson(JsonSerializeData data) {
    String className = data.className;
    String params = '';
    for (var param in data.params) {
      String paramName = param.name;
      String realClass = param.realType;
      if (param.isBaseParam && param.isList) {
        params += """
        List<$realClass>? $paramName = _getList<$realClass>(json['$paramName']);
        if($paramName != null) {
          instance.$paramName = $paramName;
        }
        """;
      } else if (param.isUnionParam && param.isList) {
        params += """
        List<Map<String, dynamic>>? $paramName =
            _getList<Map<String, dynamic>>(json['$paramName']);
        if($paramName != null) {
          instance.$paramName = $paramName.map((e) => $realClass.fromJson(e))
          .toList();
        }
        """;
      } else if (param.isBaseParam && !param.isList) {
        params += """
        $realClass? $paramName = 
             _getType<$realClass>(json['$paramName']);
        if ($paramName != null) {
          instance.$paramName = $paramName;
        }\n
        """;
      } else if (param.isUnionParam && !param.isList) {
        params += """
        Map<String, dynamic>? $paramName =
            _getType<Map<String, dynamic>>(json['$paramName']);
        if ($paramName != null) {
          instance.$paramName = $realClass.fromJson($paramName);
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
