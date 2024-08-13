import 'package:analyzer_query/extension.dart';
import 'package:analyzer_query/proj_path/dart_file.dart';
import 'package:analyzer_query/tester.dart';
import 'package:json_analyze/base/data.dart';

import '../base/meta.dart';

///从Dart文件中获取需要的含有注解@[proto]的数据
List<JsonSerializeData> collectProtoData() {
  rootDart
    ..acceptPack = (pack) {
      return !pack.isThirdLib;
    }
    ..acceptDartString = (fileString) {
      return fileString.contains("proto");
    };
  rootDart.flush();
  List<JsonSerializeData> datas = [];
  for (var file in rootDart.files) {
    List<JsonSerializeRedirect> redirects = [];
    TestFile.fromFile(
      file.filePath,
      visit: (node, token) {
        JsonSerializeData? data = _visit(
          node: node,
          file: file,
          token: token,
          redirects: redirects,
        );
        if (data != null) {
          datas.add(data);
        }
      },
    );
  }
  return datas;
}

/// 访问目标Dart文件,含有注解@[proto],
/// 数据格式参考@[BaseProtoExample]与@[UnionProtoExample]
JsonSerializeData? _visit({
  required DartFile file,
  required AstNode node,
  required TestToken token,
  required List<JsonSerializeRedirect> redirects,
}) {
  if (node is PartDirective) {
    redirects.add(
      JsonSerializeRedirect(
        token: node.testToken(file),
        redirectName: node.uri.stringValue.toString(),
        isPart: true,
      ),
    );
  } else if (node is ImportDirective) {
    redirects.add(
      JsonSerializeRedirect(
        token: node.testToken(file),
        redirectName: node.uri.stringValue.toString(),
        isImport: true,
      ),
    );
  } else if (node is PartOfDirective) {
    redirects.add(
      JsonSerializeRedirect(
        token: node.testToken(file),
        redirectName: node.uri.toString(),
        isPartOf: true,
      ),
    );
  }

  if (node is! Annotation || node.name.name != "proto") return null;
  final classNode = node.parent;
  if (classNode is! ClassDeclaration) return null;
  String className = classNode.name.toString();
  List<JsonSerializeParam> params = [];
  List<JsonSerializeMethod> methods = [];
  for (var member in classNode.members) {
    if (member is ConstructorDeclaration) {
      throw JsonAnalyzeException(
          "ConstructorDeclaration is not permitted in @proto");
    }
    var param = _getFieldDeclaration(member, file);
    if (param != null) {
      params.add(param);
    }
    var method = _getMethod(member, file);
    if (method != null) {
      methods.add(method);
    }
  }
  return JsonSerializeData(
    file: file,
    className: className,
    params: params,
    classToken: classNode.testToken(file),
    constructors: [],
    methods: methods,
    annotation: token.name,
    redirects: redirects,
  );
}

JsonSerializeMethod? _getMethod(ClassMember member, DartFile file) {
  if (member is! MethodDeclaration) return null;

  return JsonSerializeMethod(
    token: member.testToken(file),
    methodName: member.name.toString(),
    isStatic: member.isStatic,
  );
}

JsonSerializeParam? _getFieldDeclaration(ClassMember member, DartFile file) {
  if (member is! FieldDeclaration) return null;
  assert(member.fields.variables.length == 1);
  final dec = member.fields.variables.first;
  if (dec.isFinal) {
    throw JsonAnalyzeException("final Keyword is not permitted in @proto");
  }
  return JsonSerializeParam(
    type: member.fields.type.toString(),
    name: dec.name.toString(),
    defaultValue: dec.initializer?.toString(),
    comment: member.documentationComment?.commentString,
    token: member.testToken(file),
    isFactory: false,
  );
}
