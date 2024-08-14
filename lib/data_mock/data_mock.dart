import 'dart:io';

import 'package:analyzer_query/proj_path/dart_file.dart';
import 'package:analyzer_query/tester.dart';

import '../base/data.dart';

class DataMock {
  final List<JsonSerializeData> datas;

  late final Set<String> classNames = datas.map((e) => e.className).toSet();

  DataMock(this.datas);

  Set<String> importNames = {
    'dart:math',
  };

  List<String> methods = [];

  start() {
    String testMethod = "";
    for (var data in datas) {
      importNames.add(data.file.importName);
      final className = data.className;
      String params = "";
      for (var param in data.params) {
        ///todo:增加Map类型的随机构造？
        if (param.isStatic || param.isFinal || param.isMap) {
          continue;
        }
        String? value = _baseResolver(
            param.realType, param.isQuestion, param.isList, param.isMap);
        if (value != null) {
          params += """
            \n'${param.jsonName}' : $value,\n
            """;
        }
      }
      testMethod += """
        $className get test$className => $className.fromJson({$params})
        
        ;\n\n
        """;
      methods.add(testMethod);
    }
    String fileString = "";
    fileString += importNames.map((e) => "import '$e';").join('\n');
    fileString += """
    int get ramInt => $_intSeed;
    
    double get ramDouble => $_doubleSeed;
    
    String get ramString => $_stringSeed;
    
    bool get ramBool => $_boolSeed;
    
    extension on dynamic {
      dynamic get ramNull {
        return ramInt > 950 ? null : this;
      }
    }
    
    """;
    fileString += testMethod;
    String testFile =
        '${rootDart.config.projPath}${Platform.pathSeparator}test${Platform.pathSeparator}data.dart';
    final f = File(testFile);
    f.createSync(recursive: true);
    f.writeAsStringSync(DartFormatter().format(fileString));
  }

  String? _baseResolver(
      String realType, bool isQuestion, bool isList, bool isMap) {
    String seed = "";
    switch (realType) {
      case 'int':
        seed = 'ramInt';
        break;
      case 'double':
        seed = 'ramDouble';
        break;
      case 'bool':
        seed = 'ramBool';
        break;
      case 'String':
        seed = 'ramString';
        break;
      default:
        if (isMap) {
          seed = "{}";
        } else if (classNames.contains(realType)) {
          seed = "test$realType.toJson()";
        } else {
          return null;
        }

        break;
    }
    seed = _list(seed, isList);
    seed = _question(seed, isQuestion);
    return seed;
  }
}

String get _intSeed => "Random().nextInt(1000)";

String get _doubleSeed => "Random().nextDouble() * Random().nextInt(10000)";

String get _boolSeed => "Random().nextBool()";

String get _stringSeed => """
String.fromCharCodes(
    List.generate(
      ramInt,
      (index) => Random().nextInt(33) + 89,
    )
  )
""";

String _list(String seed, bool isList) {
  return isList ? "List.generate(ramInt, (index) => $seed)" : seed;
}

String _question(String seed, bool isQuestion) {
  return isQuestion ? "$seed.ramNull" : seed;
}
