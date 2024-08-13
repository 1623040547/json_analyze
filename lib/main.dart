import 'package:json_analyze/collect/collect_freeze.dart';
import 'package:json_analyze/collect/collect_json.dart';
import 'package:json_analyze/serialize/serialize_proto.dart';
import 'package:json_analyze/switch/switch_freeze.dart';

import 'base/data.dart';
import 'collect/collect_proto.dart';

void main() {
  List<JsonSerializeData> datas1 = collectProtoData();
  // List<JsonSerializeData> datas2 = collectFreezeData();
  // List<JsonSerializeData> datas3 = collectJsonData();
  // ProtoSerialize(datas1, compares: [
  //   ...datas1.map((e) => e.className),
  //   ...datas2.map((e) => e.className),
  //   ...datas3.map((e) => e.className),
  // ]).start();
  FreezeSwitch(datas1).start();
  // BaseProtoExample.fromJson({});
  // final model = BaseProtoExample.fromJson({
  //   'a1': 1,
  //   'a2': 2,
  //   'a3': 3.0,
  // });
  // print(model.toJson());
}
