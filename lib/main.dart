import 'package:json_analyze/serialize/serialize_proto.dart';

import 'base/data.dart';
import 'base/example.dart';
import 'collect/collect_proto.dart';

void main() {
  List<JsonSerializeData> datas = collectProtoData();
  ProtoSerialize(datas).start();
  // BaseProtoExample.fromJson({});
  // final model = BaseProtoExample.fromJson({
  //   'a1': 1,
  //   'a2': 2,
  //   'a3': 3.0,
  // });
  // print(model.toJson());
  BaseProtoExample.fromJson({}).e1;
}
