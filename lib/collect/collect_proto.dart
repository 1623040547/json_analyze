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
    TestFile.fromFile(
      file.filePath,
      visit: (node, token) {
        JsonSerializeData? data = _visit(node: node, file: file, token: token);
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
}) {
  if (node is! Annotation || node.name.name != "proto") return null;
  final parent = node.parent;
  if (parent is! ClassDeclaration) return null;
  String className = parent.name.toString();
  List<JsonSerializeParam> params = [];
  for (var member in parent.members) {
    assert(member is FieldDeclaration);
    if (member is! FieldDeclaration) continue;
    assert(member.fields.variables.length == 1);
    final dec = member.fields.variables.first;
    params.add(
      JsonSerializeParam(
        type: member.fields.type.toString(),
        name: dec.name.toString(),
        defaultValue: dec.initializer?.toString(),
        comment: member.documentationComment?.commentString,
        token: member.testToken(file),
      ),
    );
  }
  return JsonSerializeData(
    file: file,
    className: className,
    params: params,
    token: parent.testToken(file),
    constructors: [],
    methods: [],
    annotation: token.name,
  );
}
