class Example {
  int? code;
  String? msg;
  Data? data;

  Example({this.code, this.msg, this.data});

  Example.fromJson(Map<String, dynamic> json) {
    code = json["code"];
    msg = json["msg"];
    data = json["data"] == null ? null : Data.fromJson(json["data"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["code"] = code;
    _data["msg"] = msg;
    if (data != null) {
      _data["data"] = data?.toJson();
    }
    return _data;
  }
}

class Data {
  int? projectId;
  int? machineRoomId;
  dynamic deviceId;
  int? type;
  String? tableName;
  int? operateType;
  String? baseInfo;

  Data(
      {this.projectId,
      this.machineRoomId,
      this.deviceId,
      this.type,
      this.tableName,
      this.operateType,
      this.baseInfo});

  Data.fromJson(Map<String, dynamic> json) {
    projectId = json["projectId"];
    machineRoomId = json["machineRoomId"];
    deviceId = json["deviceId"];
    type = json["type"];
    tableName = json["tableName"];
    operateType = json["operateType"];
    baseInfo = json["baseInfo"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["projectId"] = projectId;
    _data["machineRoomId"] = machineRoomId;
    _data["deviceId"] = deviceId;
    _data["type"] = type;
    _data["tableName"] = tableName;
    _data["operateType"] = operateType;
    _data["baseInfo"] = baseInfo;
    return _data;
  }
}
