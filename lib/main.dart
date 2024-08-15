import 'package:json_analyze/collect/collect_freeze.dart';
import 'package:json_analyze/collect/collect_json.dart';
import 'package:json_analyze/serialize/serialize_proto.dart';
import 'base/data.dart';
import 'collect/collect_proto.dart';

void main() {
  List<JsonSerializeData> datas1 = collectProtoData();
  List<JsonSerializeData> datas2 = collectJsonData();
  List<JsonSerializeData> datas3 = collectFreezeData();
  ProtoSerialize(datas1, compares: [
    ...datas1.map((e) => e.className),
    ...datas2.map((e) => e.className),
    ...datas3.map((e) => e.className),
  ]).start();
}
