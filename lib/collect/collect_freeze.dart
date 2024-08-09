import 'package:analyzer_query/extension.dart';
import 'package:analyzer_query/proj_path/dart_file.dart';
import 'package:analyzer_query/tester.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_analyze/base/meta.dart';

import '../base/data.dart';

///从Dart文件中获取需要的含有注解@[unfreezed]或[freezed]的数据
List<JsonSerializeData> collectFreezeData() {
  rootDart
    ..acceptPack = (pack) {
      return !pack.isThirdLib;
    }
    ..acceptDartString = (fileString) {
      return fileString.contains("freezed");
    };
  rootDart.flush();
  List<JsonSerializeData> datas = [];
  for (var file in rootDart.files) {
    final collect = FreezeCollect(file);
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

class FreezeCollect {
  final DartFile file;

  List<JsonSerializeParam> params = [];

  List<JsonSerializeMethod> methods = [];

  List<JsonSerializeConstructor> constructors = [];

  JsonSerializeData? data;

  FreezeCollect(this.file);

  void _visit(
    AstNode node,
    TestToken token,
  ) {
    if (node is! Annotation) return;
    if (node.name.name != "freezed" && node.name.name != "unfreezed") return;
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
      params.add(_handleFieldDeclarationParameter(member));
    }
    if (member is! ConstructorDeclaration || member.factoryKeyword == null) {
      return;
    }
    String? directedName = member.redirectedConstructor?.type.name2.toString();
    String constructorName = member.returnType.name;
    if (directedName == null || "_$constructorName" != directedName) return;
    for (var param in member.parameters.parameters) {
      params.add(_handleFormalParameter(param));
    }
  }

  ///处理所有类型的[FormalParameter]，
  ///它包括一下四种类型:
  ///[DefaultFormalParameter]&
  ///[FunctionTypedFormalParameter]&
  ///[FieldFormalParameter]&
  ///[SimpleFormalParameter]
  JsonSerializeParam _handleFormalParameter(FormalParameter param) {
    String? defaultValue;
    if (param is DefaultFormalParameter) {
      defaultValue = param.defaultValue?.toString();
      param = param.parameter;
    }
    if (param is SimpleFormalParameter) {
      return JsonSerializeParam(
        token: param.testToken(file),
        type: param.type?.toString() ?? '',
        name: param.name?.toString() ?? '',
        annotation: param.metadata.metaString,
        defaultValue: defaultValue ?? _handleInnerAnnotation(param.metadata),
        comment: param.documentationComment?.commentString,
        isFactory: true,
      );
    }
    if (param is FunctionTypedFormalParameter) {
      throw JsonAnalyzeException(
          "Function parameter is disabled in JsonSerializableModel");
    }
    if (param is FieldFormalParameter) {
      throw JsonAnalyzeException("Field parameter is disabled in freezed");
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
    String? defaultValue2 = _handleInnerAnnotation(dec.metadata);
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

  ///处理注解@[Default]与@[JsonKey],返回其中的[defaultValue]
  String? _handleInnerAnnotation(NodeList<Annotation> metadata) {
    for (var meta in metadata) {
      String metaName = meta.name.name;
      List<Expression>? arguments = meta.arguments?.arguments;
      if (arguments == null) return null;
      if (metaName == "Default") {
        return arguments.first.toString();
      } else if (metaName == "JsonKey") {
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
      ),
    );
  }

  void _getConstructors(ClassMember member) {
    if (member is! ConstructorDeclaration) return;
    constructors.add(
      JsonSerializeConstructor(
        token: member.testToken(file),
      ),
    );
  }
}
