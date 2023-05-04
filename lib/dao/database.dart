import 'dart:async';
import 'package:sqflite/sqflite.dart';

class MainDBHelper {
  static Database? _db;
  static const String ID = 'id';
  static const String PROJECT_TABLE = 'project';
  static const String DATA_TABLE = 'data';
  static const String PROJECT_NAME = 'name';
  static const String PROJECT_NUMBER = 'project_code';
  static const String VERSION_NUMBER = 'version';
  static const String SYNC_DATE = 'sync_date';
  static const String PROJECT_COLUMNS =
      '$ID, $PROJECT_NAME, $PROJECT_NUMBER, $VERSION_NUMBER, $SYNC_DATE';
  static const String PROJECT_DB_NAME = 'project.db';
  static const String DATA_DB_NAME = 'data.db';
  static const String PROJECT_SQL_CREATE_TABLE =
      'CREATE TABLE $PROJECT_TABLE ($ID INTEGER PRIMARY KEY, $PROJECT_NAME TEXT NOT NULL, $PROJECT_NUMBER TEXT, $VERSION_NUMBER INTEGER, $SYNC_DATE INTEGER NOT NULL)';
  static const String DATA_SQL_CREATE_TABLE =
      'CREATE TABLE $DATA_TABLE ($ID INTEGER PRIMARY KEY AUTOINCREMENT, project_id INTEGER, machineRoom_id INTEGER, device_id INTEGER, type INTEGER, table_name TEXT, operate_type INTEGER, base_info TEXT, update_time INTEGER)';

  //初始化数据库
  static Future<Database?> getDB() async {
    if (_db == null) {
      _db =
          await openDatabase(PROJECT_DB_NAME, version: 1, onCreate: _onCreate);
    }
    return _db;
  }

  //初始化表
  static void _onCreate(Database db, int version) async {
    await db.execute(PROJECT_SQL_CREATE_TABLE);
    await db.execute(DATA_SQL_CREATE_TABLE);
  }

  //增加一个Project   传入一个Map类型（json）形式的数据
  static Future<int> addProject(Map<String, dynamic> project) async {
    var dbClient = await getDB();
    int res = await dbClient!.insert(PROJECT_TABLE, project);
    return res;
  }

  //根据id删除一个Project
  static Future<int> deleteProject(int id) async {
    var dbClient = await getDB();
    int res = await dbClient!
        .delete(PROJECT_TABLE, where: '$ID = ?', whereArgs: [id]);
    await deleteDataByProject(id); //删除该项目下的所有data
    return res;
  }

  //更新一个Project
  static Future<int> updateProject(Map<String, dynamic> project) async {
    var dbClient = await getDB();
    int res = await dbClient!.update(PROJECT_TABLE, project,
        where: '$ID = ?', whereArgs: [project[ID]]);
    return res;
  }

  //获取所有Project
  static Future<List<Map<String, dynamic>>> getAllProjects() async {
    var dbClient = await getDB();
    List<Map<String, dynamic>> projects =
        await dbClient!.rawQuery('SELECT * FROM $PROJECT_TABLE');
    return projects;
  }

  //根据id获取一个Project
  static Future<Map?> getProject(int id) async {
    var dbClient = await getDB();
    List<Map> result =
        await dbClient!.query(PROJECT_TABLE, where: '$ID = ?', whereArgs: [id]);
    if (result.length > 0) {
      return result.first;
    }
    return null;
  }

  // 清空Project表
  static Future<int> clearProjectTable() async {
    var dbClient = await getDB();
    return await dbClient!.delete('project');
  }

  // 清空data表
  static Future<int> clearDataTable() async {
    var dbClient = await getDB();
    return await dbClient!.delete('data');
  }

  //获取所有data
  static Future<List<Map<String, dynamic>>> getAllDatas() async {
    var dbClient = await getDB();
    List<Map<String, dynamic>> datas =
        await dbClient!.rawQuery('SELECT * FROM $DATA_TABLE');
    return datas;
  }

  //增加一个Data  添加机房
  static Future<int> addData(Map<String, dynamic> data) async {
    var dbClient = await getDB();
    int res = await dbClient!.insert(DATA_TABLE, data);
    return res;
  }

  //根据id删除一个Data
  static Future<int> deleteData(int id) async {
    var dbClient = await getDB();
    int res =
        await dbClient!.delete(DATA_TABLE, where: '$ID = ?', whereArgs: [id]);
    return res;
  }

  // 根据 project_id machineRoom_id type = 1 删除一个机房
  static Future<int> deleteMachineRoom(
      int project_id, int machineRoom_id) async {
    var dbClient = await getDB();
    int res =
        await dbClient!.delete(DATA_TABLE, where: 'project_id = ? and machineRoom_id = ? and type = 1', whereArgs: [project_id,machineRoom_id]);
    return res;
  }

  //根据project_id删除一组Data
  static Future<int> deleteDataByProject(int project_id) async {
    var dbClient = await getDB();
    int res = await dbClient!
        .delete(DATA_TABLE, where: 'project_id = ?', whereArgs: [project_id]);
    return res;
  }

  //更新一个Data
  static Future<int> updateData(Map<String, dynamic> data) async {
    var dbClient = await getDB();
    int res = await dbClient!
        .update(DATA_TABLE, data, where: '$ID = ?', whereArgs: [data[ID]]);
    return res;
  }

  //更新（修改）一个机房    根据项目ID 和 机房 ID 和 type = 1
  static Future<int> updateMachineRoom(Map<String, dynamic> data) async {
    var dbClient = await getDB();
    int res = await dbClient!.update(DATA_TABLE, data,
        where: 'project_id  = ? and machineRoom_id = ? and type = ?',
        whereArgs: [data['project_id'], data['machineRoom_id'], 1]);
    return res;
  }

  //获取所有Data
  static Future<List<Map<String, dynamic>>> getAllData() async {
    var dbClient = await getDB();
    List<Map<String, dynamic>> dataList = await dbClient!
        .rawQuery('SELECT * FROM $DATA_TABLE ORDER BY update_time DESC');
    return dataList;
  }

  //根据id获取一个Data
  static Future<Map?> getData(int id) async {
    var dbClient = await getDB();
    List<Map> result =
        await dbClient!.query(DATA_TABLE, where: '$ID = ?', whereArgs: [id]);
    if (result.length > 0) {
      return result.first;
    }
    return null;
  }

  //根据project_id获取该项目下所有Data
  static Future<List<Map<String, dynamic>>> getDataByProject(
      int project_id) async {
    var dbClient = await getDB();
    List<Map<String, dynamic>> dataList = await dbClient!.rawQuery(
        'SELECT * FROM $DATA_TABLE WHERE project_id = $project_id ORDER BY update_time DESC');
    return dataList;
  }

  //根据机房id获取该机房下所有Data
  static Future<List<Map<String, dynamic>>> getDataByNotebook(
      int engineroom_id) async {
    var dbClient = await getDB();
    List<Map<String, dynamic>> dataList = await dbClient!.rawQuery(
        'SELECT * FROM $DATA_TABLE WHERE engineroom_id = $engineroom_id ORDER BY update_time DESC');
    return dataList;
  }

  //根据设备id获取该设备下所有Data
  static Future<List<Map<String, dynamic>>> getDataByDevice(
      int device_id) async {
    var dbClient = await getDB();
    List<Map<String, dynamic>> dataList = await dbClient!.rawQuery(
        'SELECT * FROM $DATA_TABLE WHERE device_id = $device_id ORDER BY update_time DESC');
    return dataList;
  }

  // 根据项目id 和 机房类型查询机房列表的信息
  static Future<List<Map<String, dynamic>>> getMachineRoomList(
      int project_id) async {
    var dbClient = await getDB();
    List<Map<String, dynamic>> dataList = await dbClient!.rawQuery(
        'SELECT * FROM $DATA_TABLE WHERE project_id = $project_id and type = 1');
    return dataList;
  }

  // 根据 项目id 和 机房id 和 类型1 查询机房下设备列表的信息
  static Future<List<Map<String, dynamic>>> getDeviceList(
      int project_id, int machineRoom_id) async {
    var dbClient = await getDB();
    List<Map<String, dynamic>> dataList = await dbClient!.rawQuery(
        'SELECT * FROM $DATA_TABLE WHERE project_id = $project_id and machineRoom_id = $machineRoom_id and type = 1');
    return dataList;
  }

  // 根据 项目id 和 机房id 查询机房下设备列表的信息
  static Future<List<Map<String, dynamic>>>
      getMachineInfoByProjectIdAndMachineRoomId(
          int project_id, int machineRoom_id) async {
    var dbClient = await getDB();
    List<Map<String, dynamic>> dataList = await dbClient!.rawQuery(
        'SELECT * FROM $DATA_TABLE WHERE project_id = $project_id and machineRoom_id = $machineRoom_id ');
    return dataList;
  }
}
