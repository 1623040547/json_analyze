import 'dart:io';

import 'package:analyzer_query/proj_path/dart_file.dart';
import 'package:analyzer_query/tester.dart';
import 'package:json_analyze/base/data.dart';

class FreezeSwitch {
  List<JsonSerializeData> datas = [];

  FreezeSwitch(this.datas);

  final Map<DartFile, String> _files = {};

  void start() {
    for (var data in datas.reversed) {
      if (!_files.containsKey(data.file)) {
        _files[data.file] = data.file.fileString;
      }
      String fileString = _files[data.file]!;
      String className = data.className;
      String unFreezedString = """
      ///${data.annotation.replaceAll('\n', '\n///')}
      @unfreezed
      class $className with _$className {
          const $className._();
          
          ${_genParams(data)}
          
          factory $className({
              ${data.params.map((e) => _getParam(e)).join('\n')}
          }) = _$className;
          
          factory $className.fromJson(Map<String, dynamic> json) =>
              _\$${className}FromJson(json);
              
          ${_genConstructors(data)}
              
          ${_genMethods(data)}
      }
      """;
      fileString = fileString.substring(0, data.classToken.start) +
          unFreezedString +
          fileString.substring(data.classToken.end);
      _files[data.file] = fileString;
    }
    for (var data in datas) {
      _fillDirective(data);
    }
    _files.forEach((key, value) {
      String fileString = DartFormatter().format(value);
      File(key.filePath).writeAsStringSync(fileString);
    });
  }

  String _getParam(JsonSerializeParam e) {
    if (e.isStatic || e.isConst) {
      return "";
    }
    String param = '';
    param += e.comment ?? '';
    param += '\n';
    if (e.annotation != null) {
      param += '///${e.annotation!.replaceAll('\n', '\n///')}\n';
    }
    if (e.defaultValue != null) {
      param += "@Default(${e.defaultValue})";
    }
    if (e.isPrivate) {
      param +=
          " ${e.type} ${e.jsonName.split('_').where((e) => e.isNotEmpty).join('_')},";
    } else {
      param += " ${e.type} ${e.name},\n";
    }
    return param;
  }

  String _genParams(JsonSerializeData d) {
    String fileString = _files[d.file]!;
    return d.params
        .where((e) => e.isStatic)
        .map((e) => fileString.substring(e.token.start, e.token.end))
        .join('\n');
  }

  String _genMethods(JsonSerializeData d) {
    String fileString = _files[d.file]!;
    return d.methods
        .where((e) => e.methodName != 'toJson' && e.methodName != 'fromJson')
        .map((e) => fileString.substring(e.token.start, e.token.end))
        .join('\n');
  }

  String _genConstructors(JsonSerializeData d) {
    String fileString = _files[d.file]!;
    return d.constructors
        .where((e) => e.isFactory)
        .map((e) => fileString.substring(e.token.start, e.token.end))
        .join('\n');
  }

  ///若@[proto]下尚未填写' .g.part '的定位符，则为之填充
  void _fillDirective(JsonSerializeData data) {
    String directs = "";
    String partName1 = "${data.file.fileName}.g.dart";
    bool gDart = data.redirects
        .where((e) => e.isPart && e.redirectName == partName1)
        .isNotEmpty;

    String partName2 = "${data.file.fileName}.freezed.dart";
    bool freezedDart = data.redirects
        .where((e) => e.isPart && e.redirectName == partName2)
        .isNotEmpty;
    String packName = "package:freezed_annotation/freezed_annotation.dart";
    bool freezedAnnotation = data.redirects
        .where((e) => e.isImport && e.redirectName == packName)
        .isEmpty;

    if (!freezedAnnotation) {
      directs += "\nimport '$packName';\n";
    }

    String fileString = _files[data.file]!;
    if (!gDart) {
      directs += "\npart '$partName1';\n";
    }
    if (!freezedDart) {
      directs += "\npart '$partName2';\n";
    }
    if (directs.isEmpty) {
      return;
    }
    int endOffset = 0;
    for (var e in data.redirects) {
      endOffset = e.token.end;
      if (e.isPart || e.isPartOf) {
        endOffset = e.token.start;
        break;
      }
    }
    fileString = fileString.substring(0, endOffset) +
        directs +
        fileString.substring(endOffset);
    _files[data.file] = fileString;

    if (!gDart) {
      data.redirects.add(
        JsonSerializeRedirect(
          token: TestToken(
            start: 0,
            end: 0,
            name: directs,
            type: PartDirective,
          ),
          redirectName: partName1,
          isPart: true,
        ),
      );
    }

    if (!freezedDart) {
      data.redirects.add(
        JsonSerializeRedirect(
          token: TestToken(
            start: 0,
            end: 0,
            name: directs,
            type: PartDirective,
          ),
          redirectName: partName2,
          isPart: true,
        ),
      );
    }

    if (!freezedAnnotation) {
      data.redirects.add(
        JsonSerializeRedirect(
          token: TestToken(
            start: 0,
            end: 0,
            name: packName,
            type: ImportDirective,
          ),
          redirectName: packName,
          isImport: true,
        ),
      );
    }
  }
}
