import 'package:json_analyze/collect/collect_freeze.dart';
import 'package:json_analyze/collect/collect_json.dart';

import 'base/data.dart';
import 'collect/collect_proto.dart';
import 'data_mock/data_mock.dart';

void main() {
  List<JsonSerializeData> datas1 = collectProtoData();
  List<JsonSerializeData> datas2 = collectJsonData();
  List<JsonSerializeData> datas3 = collectFreezeData();
  // ProtoSerialize(datas1, compares: [
  //   ...datas1.map((e) => e.className),
  //   ...datas2.map((e) => e.className),
  //   ...datas3.map((e) => e.className),
  // ]).start();

  DataMock(datas1).start();
  // FreezeSwitch(datas1).start();
  // print(double.maxFinite);
  // print((-double.minPositive).toString());
}
