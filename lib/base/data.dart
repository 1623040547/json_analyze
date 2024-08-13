import 'package:analyzer_query/proj_path/dart_file.dart';
import 'package:analyzer_query/tester.dart';
import 'package:json_analyze/base/meta.dart';

class JsonSerializeData {
  final TestToken classToken;

  final DartFile file;

  final String className;

  final String annotation;

  final List<JsonSerializeParam> params;

  final List<JsonSerializeConstructor> constructors;

  final List<JsonSerializeMethod> methods;

  final List<JsonSerializeRedirect> redirects;

  JsonSerializeData({
    required this.file,
    required this.className,
    required this.params,
    required this.classToken,
    required this.constructors,
    required this.methods,
    required this.annotation,
    this.redirects = const [],
  });
}

class JsonSerializeRedirect {
  final TestToken token;

  final String redirectName;

  final bool isPart;

  final bool isPartOf;

  final bool isImport;

  JsonSerializeRedirect({
    required this.token,
    required this.redirectName,
    this.isPart = false,
    this.isPartOf = false,
    this.isImport = false,
  });
}

class JsonSerializeParam {
  final TestToken token;

  final String type;

  final String name;

  final String? defaultValue;

  final String? comment;

  final String? annotation;

  final bool isStatic;

  final bool isFactory;

  JsonSerializeParam({
    required this.token,
    required this.type,
    required this.name,
    required this.isFactory,
    this.defaultValue,
    this.comment,
    this.annotation,
    this.isStatic = false,
  }) {
    if (isMap) {
      throw JsonAnalyzeException("Map is not permitted in @proto");
    }
  }

  bool get isQuestion => defaultValue == null;

  bool get isUnionParam => !isBaseParam;

  bool get isList => type.startsWith('List<');

  bool get isMap => type.startsWith('Map<');

  bool get isPrivate => name.startsWith('_');

  String get realType {
    return type.replaceAll('List<', '').replaceAll('>', '').replaceAll('?', '');
  }

  String get jsonName {
    if (isPrivate) {
      return name.substring(1);
    }
    return name;
  }

  bool get isBaseParam {
    String switchType = type;
    if (switchType.endsWith('?')) {
      switchType = switchType.substring(0, switchType.length - 1);
    }
    switch (switchType) {
      case "int":
      case "String":
      case "double":
      case "bool":
      case "List<int>":
      case "List<String>":
      case "List<double>":
      case "List<bool>":
        return true;
      case "":
      case "null":

        ///检测类型声明是否遗漏
        throw JsonAnalyzeException("Param miss TypeAnnotation ${token.name}");
      default:
        return false;
    }
  }
}

class JsonSerializeMethod {
  final TestToken token;
  final String methodName;
  final bool isStatic;

  JsonSerializeMethod({
    required this.token,
    required this.methodName,
    required this.isStatic,
  });
}

class JsonSerializeConstructor {
  final TestToken token;

  JsonSerializeConstructor({
    required this.token,
  });
}
