import 'package:analyzer_query/extension.dart';
import 'package:analyzer_query/proj_path/dart_file.dart';
import 'package:analyzer_query/proj_path/package.dart';
import 'package:analyzer_query/tester.dart';
import 'package:json_annotation/json_annotation.dart';

import '../base/data.dart';
import '../base/meta.dart';

///@[JsonKey]
///从Dart文件中获取需要的含有注解@[JsonSerializable]的数据
List<JsonSerializeData> collectJsonData() {
  rootDart
    ..acceptPack = (pack) {
      return !pack.isThirdLib;
    }
    ..acceptDartFile = (file) {
      return !file.fullName.endsWith(".freezed.dart") &&
          !file.fullName.endsWith(".g.dart");
    }
    ..acceptDartString = (fileString) {
      return fileString.contains("JsonSerializable");
    };
  rootDart.flush();
  List<JsonSerializeData> datas = [];
  for (var file in rootDart.files) {
    final collect = JsonSerializableCollect(file);
    TestFile.fromFile(
      file.filePath,
      visit: collect._visit,
    );
    if (collect.data != null) {
      datas.add(collect.data!);
    }
  }
  return datas;
}

class JsonSerializableCollect {
  final DartFile file;

  List<JsonSerializeParam> params = [];

  List<JsonSerializeParam> fieldParams = [];

  List<JsonSerializeMethod> methods = [];

  List<JsonSerializeConstructor> constructors = [];

  JsonSerializeData? data;

  JsonSerializableCollect(this.file);

  void _visit(
    AstNode node,
    TestToken token,
  ) {
    if (node is! Annotation) return;
    if (node.name.name != "JsonSerializable") return;
    final classNode = node.parent;
    if (classNode is! ClassDeclaration) return;
    String className = classNode.name.toString();
    for (var member in classNode.members) {
      _getParams(member);
      _getMethods(member);
      _getConstructors(member);
    }
    data = JsonSerializeData(
      file: file,
      className: className,
      params: params,
      classToken: classNode.testToken(file),
      methods: methods,
      constructors: constructors,
      annotation: token.name,
    );
  }

  void _getParams(ClassMember member) {
    if (member is FieldDeclaration) {
      _handleFieldDeclarationParameter(member);
    } else if (member is ConstructorDeclaration &&
        member.factoryKeyword == null) {
      for (var param in member.parameters.parameters) {
        fieldParams.add(_handleFormalParameter(param));
      }
    }
  }

  ///获取构造器中的参数定义，在@[JsonSerializable]中，此处只匹配一种序列化写法
  ///```dart
  ///@JsonSerializable
  ///class ExampleClass {
  /// @JsonKey(defaultValue: "")
  /// String testKey1;
  /// @JsonKey()
  /// int testKey2;
  /// ExampleClass(this.testKey1, {this.testKey2 = 0});
  ///}
  /// ```
  JsonSerializeParam _handleFormalParameter(FormalParameter param) {
    String? defaultValue;
    if (param is DefaultFormalParameter) {
      defaultValue = param.defaultValue?.toString();
      param = param.parameter;
    }
    if (param is FieldFormalParameter) {
      String paramName = param.name.toString();
      return JsonSerializeParam(
        token: param.testToken(file),
        type: param.type?.toString() ?? '',
        name: paramName,
        annotation: param.metadata.metaString,
        defaultValue: defaultValue,
        comment: param.documentationComment?.commentString,
        isFactory: false,
      );
    }
    if (param is FunctionTypedFormalParameter) {
      throw JsonAnalyzeException(
          "Function parameter is disabled in JsonSerializableModel");
    }
    if (param is SimpleFormalParameter) {
      throw JsonAnalyzeException(
          "Simple parameter is useless in JsonSerializable");
    }
    throw JsonAnalyzeException("Unknown parameter type.");
  }

  JsonSerializeParam _handleFieldDeclarationParameter(FieldDeclaration dec) {
    assert(dec.fields.variables.length == 1);
    assert(dec.fields.type != null);
    if (dec.fields.variables.length != 1) {
      throw JsonAnalyzeException(
          "This plugin handle FieldDeclaration when variables' count equal 1");
    }
    String paramName = dec.fields.variables.first.name.toString();
    String? defaultValue1 = dec.fields.variables.first.initializer?.toString();
    String? defaultValue2 =
        _handleInnerAnnotation(dec.metadata, paramName: paramName);
    assert(defaultValue1 == null || defaultValue2 == null);
    return JsonSerializeParam(
      token: dec.testToken(file),
      type: dec.fields.type.toString(),
      name: paramName,
      comment: dec.documentationComment?.commentString,
      annotation: dec.metadata.metaString,
      isStatic: dec.isStatic,
      defaultValue: defaultValue1 ?? defaultValue2,
      isFactory: false,
    );
  }

  ///处理注解@[JsonKey],返回其中的[defaultValue]
  String? _handleInnerAnnotation(
    NodeList<Annotation> metadata, {
    required String paramName,
  }) {
    for (var meta in metadata) {
      String metaName = meta.name.name;
      List<Expression>? arguments = meta.arguments?.arguments;
      if (arguments == null) return null;
      if (metaName == "JsonKey") {
        List<Expression> value = arguments
            .where((e) =>
                e is NamedExpression && e.name.label.name == "defaultValue")
            .toList();
        if (value.isEmpty) return null;
        return (value.first as NamedExpression).expression.toString();
      }
    }
    return null;
  }

  void _getMethods(ClassMember member) {
    if (member is! MethodDeclaration) return;
    methods.add(
      JsonSerializeMethod(
        token: member.testToken(file),
        methodName: member.name.toString(),
        isStatic: member.isStatic,
      ),
    );
  }

  void _getConstructors(ClassMember member) {
    if (member is! ConstructorDeclaration) return;
    constructors.add(
      JsonSerializeConstructor(
        token: member.testToken(file),
        isFactory: member.factoryKeyword != null,
      ),
    );
  }
}
