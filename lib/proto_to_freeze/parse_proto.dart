import 'package:analyzer_query/proj_path/dart_file.dart';
import 'package:analyzer_query/tester.dart';
import 'package:analyzer/dart/ast/ast.dart';

class ProtoData {
  final DartFile file;

  final String className;

  final List<ProtoParam> params;

  ProtoData({
    required this.file,
    required this.className,
    required this.params,
  });
}

class ProtoParam {
  final String type;
  final String name;

  final String? defaultValue;

  final String? comment;

  ProtoParam({
    required this.type,
    required this.name,
    required this.defaultValue,
    this.comment,
  });

  bool get isBaseParam {
    switch (type) {
      case "int":
      case "String":
      case "double":
      case "bool":
      case "List<int>":
      case "List<String>":
      case "List<double>":
      case "List<bool>":
        return true;
      default:
        return false;
    }
  }

  bool get isUnionParam => !isBaseParam;
}

void collectProtoData() {
  rootDart
    ..acceptPack = (pack) {
      return !pack.isThirdLib;
    }
    ..acceptDartString = (fileString) {
      return fileString.contains("proto");
    };
  rootDart.flush();
  List<ProtoData> datas = [];
  for (var file in rootDart.files) {
    TestFile.fromFile(
      file.filePath,
      visit: (node) => _visit(
        node: node,
        file: file,
      ),
    );
  }
}

void _visit({required DartFile file, required AstNode node}) {
  if (node is! Annotation || node.name.name != "proto") return;
  final parent = node.parent;
  if (parent is! ClassDeclaration) return;
  print('\n');
  print(parent.name);
  for (var member in parent.members) {
    assert(member is FieldDeclaration);
    if (member is! FieldDeclaration) continue;
    assert(member.fields.variables.length == 1);
    final dec = member.fields.variables.first;
    print(member.fields.type.toString().replaceAll('?', ''));
    print(member.fields.type?.question != null);
    print(member.documentationComment);
    print(dec.name);
    print(dec.initializer);
    print('\n');
  }
}
